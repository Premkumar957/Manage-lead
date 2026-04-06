package customer.manage_lead.external;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.net.CookieManager;
import java.net.URI;
import java.net.http.*;
import java.util.*;
import java.util.zip.GZIPInputStream;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.*;
import com.sap.cds.ResultBuilder;
import com.sap.cds.ql.cqn.CqnAnalyzer;
import com.sap.cds.reflect.CdsModel;
import com.sap.cds.services.cds.CdsDeleteEventContext;
import com.sap.cds.services.cds.CdsReadEventContext;
import com.sap.cds.services.handler.EventHandler;
import com.sap.cds.services.handler.annotations.*;
import com.sap.cds.services.EventContext;

@Component
@ServiceName("ExternalService")
public class ExternalServiceHandler implements EventHandler {

    @Autowired
    private CdsModel model;

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

        // 1. Use Analyzer to get keys from the request
        CqnAnalyzer analyzer = CqnAnalyzer.create(model);
        Map<String, Object> keys = analyzer.analyze(context.getCqn()).targetKeys();
        
        String bpId = (String) keys.get("BusinessPartner");

        String url;
        if (bpId != null && !bpId.isEmpty()) {
            // ✅ FIXED: Corrected single-quote wrapping for OData V2 String Keys
            url = BASE_URL + "/A_BusinessPartner('" + bpId + "')?$select=BusinessPartner,BusinessPartnerFullName,"
                    + "BusinessPartnerCategory,BusinessPartnerGrouping,Industry,Customer,Supplier,BusinessPartnerIsBlocked,IsMarkedForArchiving";
        } else {
            // Collection (List Report)
            url = BASE_URL + "/A_BusinessPartner?$select=BusinessPartner,BusinessPartnerFullName,"
                    + "BusinessPartnerCategory,BusinessPartnerGrouping,Industry,Customer,Supplier,BusinessPartnerIsBlocked,IsMarkedForArchiving";
        }

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
        String encoding = response.headers().firstValue("Content-Encoding").orElse("");

        if ("gzip".equalsIgnoreCase(encoding)) {
            try (GZIPInputStream gis = new GZIPInputStream(new ByteArrayInputStream(response.body()))) {
                responseBody = new String(gis.readAllBytes());
            }
        } else {
            responseBody = new String(response.body());
        }

        JsonNode root = mapper.readTree(responseBody);
        JsonNode dNode = root.path("d");

        List<Map<String, Object>> rows = new ArrayList<>();

        // ✅ FIXED: Logic to handle both Array (List Report) and Object (Object Page)
        if (dNode.path("results").isArray()) {
            // Case: List Report
            rows = mapper.convertValue(dNode.path("results"), new TypeReference<>() {});
        } else if (!dNode.isMissingNode() && !dNode.isNull()) {
            // Case: Object Page (Single Record)
            Map<String, Object> singleRow = mapper.convertValue(dNode, new TypeReference<>() {});
            rows.add(singleRow);
        }

        context.setResult(ResultBuilder.selectedRows(rows).inlineCount(rows.size()).result());
    }

    @On(event = "createBusinessPartner")
    public void createBusinessPartner(EventContext ctx) {
        // ... (Keep your existing Create logic as it is) ...
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
            HttpClient client = HttpClient.newBuilder().cookieHandler(cookieManager).build();

            HttpRequest tokenRequest = HttpRequest.newBuilder()
                    .uri(URI.create(BASE_URL + "/A_BusinessPartner?$top=1"))
                    .header("Authorization", authHeader)
                    .header("x-csrf-token", "fetch")
                    .GET()
                    .build();

            HttpResponse<String> tokenResponse = client.send(tokenRequest, HttpResponse.BodyHandlers.ofString());
            String csrfToken = tokenResponse.headers().firstValue("x-csrf-token").orElseThrow(() -> new RuntimeException("CSRF token fetch failed"));

            Map<String, Object> payload = new LinkedHashMap<>();
            payload.put("BusinessPartnerCategory", category);
            payload.put("BusinessPartnerGrouping", grouping);
            payload.put("CorrespondenceLanguage", language);

            if ("1".equals(category)) {
                payload.put("FirstName", firstName);
                payload.put("LastName", lastName);
            } else if ("2".equals(category)) {
                payload.put("OrganizationBPName1", orgName);
            } else if ("3".equals(category)) {
                payload.put("GroupBusinessPartnerName1", groupName);
            }

            if (isBlocked != null) payload.put("BusinessPartnerIsBlocked", isBlocked);
            if (Boolean.TRUE.equals(isArchived)) payload.put("IsMarkedForArchiving", true);

            String jsonPayload = mapper.writeValueAsString(payload);

            HttpRequest postRequest = HttpRequest.newBuilder()
                    .uri(URI.create(BASE_URL + "/A_BusinessPartner"))
                    .header("Authorization", authHeader)
                    .header("Content-Type", "application/json")
                    .header("Accept", "application/json")
                    .header("x-csrf-token", csrfToken)
                    .POST(HttpRequest.BodyPublishers.ofString(jsonPayload))
                    .build();

            HttpResponse<String> postResponse = client.send(postRequest, HttpResponse.BodyHandlers.ofString());

            if (postResponse.statusCode() >= 200 && postResponse.statusCode() < 300) {
                ctx.put("result", postResponse.body());
                ctx.setCompleted();
            } else {
                String errorBody = postResponse.body();
                if (errorBody.contains("PartnerGUID")) {
                    ctx.put("result", errorBody);
                    ctx.setCompleted();
                } else {
                    throw new RuntimeException("S/4 Error (" + postResponse.statusCode() + "): " + errorBody);
                }
            }
        } catch (Exception e) {
            throw new RuntimeException("External POST failed: " + e.getMessage(), e);
        }
    }


    @On(event = "DELETE", entity = "ExternalService.BusinessPartners")
    public void onDeleteBusinessPartner(CdsDeleteEventContext context) throws IOException, InterruptedException {
        // 1. Extract the ID of the record to be deleted
        CqnAnalyzer analyzer = CqnAnalyzer.create(model);
        Map<String, Object> keys = analyzer.analyze(context.getCqn()).targetKeys();
        String bpId = (String) keys.get("BusinessPartner");

        if (bpId == null || bpId.isEmpty()) {
            throw new RuntimeException("Business Partner ID is missing for deletion.");
        }

        // 2. Setup HttpClient with Cookie Management (Necessary for CSRF)
        CookieManager cookieManager = new CookieManager();
        HttpClient client = HttpClient.newBuilder()
                .cookieHandler(cookieManager)
                .build();

        String authHeader = getAuthHeader();
        String deleteUrl = BASE_URL + "/A_BusinessPartner('" + bpId + "')";

        // 3. Fetch CSRF Token (S/4HANA requirement)
        HttpRequest tokenRequest = HttpRequest.newBuilder()
                .uri(URI.create(BASE_URL + "/A_BusinessPartner?$top=1"))
                .header("Authorization", authHeader)
                .header("x-csrf-token", "fetch")
                .GET()
                .build();

        HttpResponse<String> tokenResponse = client.send(tokenRequest, HttpResponse.BodyHandlers.ofString());
        String csrfToken = tokenResponse.headers().firstValue("x-csrf-token")
                .orElseThrow(() -> new RuntimeException("Could not fetch CSRF token for deletion"));

        // 4. Execute the DELETE Request
        HttpRequest deleteRequest = HttpRequest.newBuilder()
                .uri(URI.create(deleteUrl))
                .header("Authorization", authHeader)
                .header("x-csrf-token", csrfToken)
                .header("Accept", "application/json")
                .DELETE() // Method is DELETE
                .build();

        HttpResponse<String> deleteResponse = client.send(deleteRequest, HttpResponse.BodyHandlers.ofString());

        // 5. Check Result (OData V2 usually returns 204 No Content on success)
        if (deleteResponse.statusCode() >= 200 && deleteResponse.statusCode() < 300) {
            context.setCompleted(); // Successfully deleted in S/4HANA
        } else {
            throw new RuntimeException("S/4 Delete Failed (" + deleteResponse.statusCode() + "): " + deleteResponse.body());
        }
    }

    private String trim(String value) { return value == null ? null : value.trim(); }
    private boolean isEmpty(String value) { return value == null || value.trim().isEmpty(); }
}