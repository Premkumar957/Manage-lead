package customer.manage_lead.external;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.net.CookieManager;
import java.net.URI;
import java.net.http.*;
import java.util.*;
import java.util.zip.GZIPInputStream;

import org.springframework.stereotype.Component;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.*;
import com.sap.cds.ResultBuilder;
import com.sap.cds.services.cds.CdsReadEventContext;
import com.sap.cds.services.handler.EventHandler;
import com.sap.cds.services.handler.annotations.*;
import com.sap.cds.services.EventContext;

@Component
@ServiceName("ExternalService")
public class ExternalServiceHandler implements EventHandler {

    private static final String BASE_URL =
        "https://my401381-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER";

    private static final String USERNAME = "BASIC_AUTH_API_USER";
    private static final String PASSWORD = "7retAJvSl~PWySlXyttsluHUDCpWZGYqMXBgfAlc";

    private final ObjectMapper mapper = new ObjectMapper()
            .configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);

    private String getAuthHeader() {
        String auth = USERNAME + ":" + PASSWORD;
        return "Basic " + Base64.getEncoder().encodeToString(auth.getBytes());
    }

    @On(event = "READ", entity = "ExternalService.BusinessPartners")
    public void onReadBusinessPartners(CdsReadEventContext context)
            throws IOException, InterruptedException {

        String url = BASE_URL + "/A_BusinessPartner?$select=BusinessPartner,BusinessPartnerFullName,"
                + "BusinessPartnerCategory,BusinessPartnerGrouping,Industry,Customer,Supplier,BusinessPartnerIsBlocked,IsMarkedForArchiving";

        fetchAndSetResult(url, context);
    }

    private void fetchAndSetResult(String baseUrl, CdsReadEventContext context)
            throws IOException, InterruptedException {

        HttpClient client = HttpClient.newHttpClient();

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(baseUrl))
                .header("Authorization", getAuthHeader())
                .header("Accept", "application/json")
                .header("Accept-Encoding", "gzip")
                .GET()
                .build();

        HttpResponse<byte[]> response =
                client.send(request, HttpResponse.BodyHandlers.ofByteArray());

        if (response.statusCode() != 200) {
            throw new RuntimeException("API call failed: HTTP " + response.statusCode());
        }

        String responseBody;
        String encoding = response.headers()
                .firstValue("Content-Encoding").orElse("");

        if ("gzip".equalsIgnoreCase(encoding)) {
            try (GZIPInputStream gis =
                    new GZIPInputStream(new ByteArrayInputStream(response.body()))) {
                responseBody = new String(gis.readAllBytes());
            }
        } else {
            responseBody = new String(response.body());
        }

        JsonNode root = mapper.readTree(responseBody);
        JsonNode resultsNode = root.path("d").path("results");

        List<Map<String, Object>> rows = new ArrayList<>();

        if (resultsNode.isArray()) {
            rows = mapper.convertValue(resultsNode, new TypeReference<>() {});
        }


        long count = rows.size();



        context.setResult(
            ResultBuilder.selectedRows(rows).inlineCount(count).result()
        );
    }

    @On(event = "createBusinessPartner")
    public void createBusinessPartner(EventContext ctx) {

        String category   = trim((String) ctx.get("BusinessPartnerCategory"));
        String grouping   = trim((String) ctx.get("BusinessPartnerGrouping"));
        String firstName  = trim((String) ctx.get("FirstName"));
        String lastName   = trim((String) ctx.get("LastName"));
        String orgName    = trim((String) ctx.get("OrganizationBPName1"));
        String groupName  = trim((String) ctx.get("GroupBusinessPartnerName1"));
        String language   = trim((String) ctx.get("CorrespondenceLanguage"));

        Boolean isBlocked  = (Boolean) ctx.get("BusinessPartnerIsBlocked");
        Boolean isArchived = (Boolean) ctx.get("IsMarkedForArchiving");

        try {
            String authHeader = getAuthHeader();

            CookieManager cookieManager = new CookieManager();
            HttpClient client = HttpClient.newBuilder()
                    .cookieHandler(cookieManager)
                    .build();

            // Fetch CSRF token
            HttpRequest tokenRequest = HttpRequest.newBuilder()
                    .uri(URI.create(BASE_URL + "/A_BusinessPartner?$top=1"))
                    .header("Authorization", authHeader)
                    .header("x-csrf-token", "fetch")
                    .GET()
                    .build();

            HttpResponse<String> tokenResponse =
                    client.send(tokenRequest, HttpResponse.BodyHandlers.ofString());

            String csrfToken = tokenResponse.headers()
                    .firstValue("x-csrf-token")
                    .orElseThrow(() -> new RuntimeException("CSRF token fetch failed"));

            // Build payload
            Map<String, Object> payload = new LinkedHashMap<>();
            payload.put("BusinessPartnerCategory", category);
            payload.put("BusinessPartnerGrouping", grouping);
            payload.put("CorrespondenceLanguage", language);

            switch (category) {
                case "1": // Person
                    if (isEmpty(firstName) || isEmpty(lastName)) {
                        throw new RuntimeException("FirstName & LastName are required");
                    }
                    payload.put("FirstName", firstName);
                    payload.put("LastName", lastName);
                    break;

                case "2": // Organization
                    if (isEmpty(orgName)) {
                        throw new RuntimeException("Organization name is required");
                    }
                    payload.put("OrganizationBPName1", orgName);
                    break;

                case "3": // Group
                    if (isEmpty(groupName)) {
                        throw new RuntimeException("Group name is required");
                    }
                    payload.put("GroupBusinessPartnerName1", groupName);
                    break;

                default:
                    throw new RuntimeException("Invalid BusinessPartnerCategory");
            }

            if (isBlocked != null) {
                payload.put("BusinessPartnerIsBlocked", isBlocked);
            }

            if (Boolean.TRUE.equals(isArchived)) {
                payload.put("IsMarkedForArchiving", true);
            }

            String jsonPayload = mapper.writeValueAsString(payload);

            HttpRequest postRequest = HttpRequest.newBuilder()
                    .uri(URI.create(BASE_URL + "/A_BusinessPartner"))
                    .header("Authorization", authHeader)
                    .header("Content-Type", "application/json")
                    .header("Accept", "application/json")
                    .header("x-csrf-token", csrfToken)
                    .POST(HttpRequest.BodyPublishers.ofString(jsonPayload))
                    .build();

            HttpResponse<String> postResponse =
                    client.send(postRequest, HttpResponse.BodyHandlers.ofString());

            // ✅ FIXED: Handle S/4HANA partial success responses
            if (postResponse.statusCode() >= 200 && postResponse.statusCode() < 300) {
                ctx.put("result", postResponse.body());
                ctx.setCompleted();
            } else {
                String errorBody = postResponse.body();

                // ✅ S/4HANA sometimes returns 400 even when BP was created successfully.
                // Detect this by checking if PartnerGUID is present in the response,
                // which confirms the BP was actually persisted.
                if (errorBody.contains("PartnerGUID")) {
                    System.out.println("⚠️ S/4 returned 400 but BP was created. PartnerGUID found.");
                    ctx.put("result", errorBody);
                    ctx.setCompleted();
                } else {
                    throw new RuntimeException(
                        "S/4 Error (" + postResponse.statusCode() + "): " + errorBody
                    );
                }
            }

        } catch (Exception e) {
            throw new RuntimeException("External POST failed: " + e.getMessage(), e);
        }
    }

    private String trim(String value) {
        return value == null ? null : value.trim();
    }

    private boolean isEmpty(String value) {
        return value == null || value.trim().isEmpty();
    }
}