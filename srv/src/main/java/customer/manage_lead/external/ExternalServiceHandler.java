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
        "https://sandbox.api.sap.com/s4hanacloud/sap/opu/odata/sap/API_BUSINESS_PARTNER";

    private static final String API_KEY = "PyEKIqtO6jMczj1yyn3xctK2QETvlqGn";

    private final ObjectMapper mapper = new ObjectMapper()
            .configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);

    // ================= BUSINESS PARTNERS =================
    @On(event = "READ", entity = "ExternalService.BusinessPartners")
    public void onReadBusinessPartners(CdsReadEventContext context)
            throws IOException, InterruptedException {

        String url = BASE_URL + "/A_BusinessPartner?$select=BusinessPartner,BusinessPartnerFullName,"
                + "BusinessPartnerCategory,BusinessPartnerGrouping,Industry,Customer,Supplier,"
                + "BusinessPartnerIsBlocked,IsMarkedForArchiving,CreationDate";

        fetchAndSetResult(url, context);
    }

    // ================= ADDRESSES =================
    @On(event = "READ", entity = "ExternalService.BusinessPartnerAddresses")
    public void onReadBusinessPartnerAddresses(CdsReadEventContext context)
            throws IOException, InterruptedException {

        String url = BASE_URL + "/A_BusinessPartnerAddress?$select=BusinessPartner,AddressID,"
                + "StreetName,HouseNumber,CityName,PostalCode,Region,Country";

        fetchAndSetResult(url, context);
    }

    // ================= ROLES =================
    @On(event = "READ", entity = "ExternalService.BusinessPartnerRoles")
    public void onReadBusinessPartnerRoles(CdsReadEventContext context)
            throws IOException, InterruptedException {

        String url = BASE_URL + "/A_BusinessPartnerRole?$select=BusinessPartner,"
                + "BusinessPartnerRole,ValidFrom,ValidTo";

        fetchAndSetResult(url, context);
    }

    // ================= COMMON FETCH =================
    private void fetchAndSetResult(String baseUrl, CdsReadEventContext context)
            throws IOException, InterruptedException {

        // ✅ STATIC pagination (safe baseline)
        String url = baseUrl + "&$top=30&$skip=0&$inlinecount=allpages";

        HttpClient client = HttpClient.newHttpClient();

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("APIKey", API_KEY)
                .header("Accept", "application/json")
                .header("Accept-Encoding", "gzip")
                .GET()
                .build();

        HttpResponse<byte[]> response =
                client.send(request, HttpResponse.BodyHandlers.ofByteArray());

        if (response.statusCode() != 200) {
            throw new RuntimeException(
                    "API call failed: HTTP " + response.statusCode()
            );
        }

        // ===== HANDLE GZIP =====
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

        // ===== PARSE JSON =====
        JsonNode root = mapper.readTree(responseBody);
        JsonNode dNode = root.path("d");
        JsonNode resultsNode = dNode.path("results");

        List<Map<String, Object>> rows = new ArrayList<>();

        // ✅ HANDLE BOTH ARRAY + SINGLE OBJECT
        if (resultsNode.isArray()) {
            rows = mapper.convertValue(resultsNode, new TypeReference<>() {});
        } else if (!dNode.isMissingNode()) {
            Map<String, Object> single = mapper.convertValue(dNode, Map.class);
            rows.add(single);
        }

        // ===== CLEAN METADATA =====
        for (Map<String, Object> row : rows) {
            row.remove("__metadata");
            row.remove("__deferred");
        }

        // ===== HANDLE COUNT =====
        long count = rows.size();

        if (dNode.has("__count")) {
            try {
                count = Long.parseLong(dNode.get("__count").asText());
            } catch (Exception ignored) {}
        }

        // ✅ CORRECT CAP RESPONSE
        context.setResult(
            ResultBuilder
                .selectedRows(rows)
                .inlineCount(count)
                .result()
        );
    }


    // create new business partner
    @On(event = "createBusinessPartner")
    public void createBusinessPartner(EventContext ctx) {

        // 🔥 1. Read ALL parameters from UI
        String name = (String) ctx.get("BusinessPartnerFullName");
        String category = (String) ctx.get("BusinessPartnerCategory");
        String grouping = (String) ctx.get("BusinessPartnerGrouping");

        Boolean isBlocked = (Boolean) ctx.get("BusinessPartnerIsBlocked");
        Boolean isArchived = (Boolean) ctx.get("IsMarkedForArchiving");

        // ⚠️ Not directly usable in BP API (explained below)
        Boolean customer = (Boolean) ctx.get("Customer");
        Boolean supplier = (Boolean) ctx.get("Supplier");
        String industry = (String) ctx.get("Industry");

        try {
            // 🔥 2. Create HTTP client with cookies (MANDATORY for CSRF)
            CookieManager cookieManager = new CookieManager();
            HttpClient client = HttpClient.newBuilder()
                    .cookieHandler(cookieManager)
                    .build();

            // 🔥 3. Fetch CSRF token
            HttpRequest tokenRequest = HttpRequest.newBuilder()
                    .uri(URI.create(BASE_URL + "/A_BusinessPartner"))
                    .header("APIKey", API_KEY)
                    .header("x-csrf-token", "fetch")
                    .GET()
                    .build();

            HttpResponse<String> tokenResponse =
                    client.send(tokenRequest, HttpResponse.BodyHandlers.ofString());

            String csrfToken = tokenResponse.headers()
                    .firstValue("x-csrf-token")
                    .orElseThrow(() -> new RuntimeException("CSRF token not found"));

            // 🔥 4. Build payload (ONLY valid fields for BP API)
            String payload;

            if ("1".equals(category)) {
                // Person
                payload = "{"
                        + "\"BusinessPartnerCategory\":\"1\","
                        + "\"BusinessPartnerGrouping\":\"" + grouping + "\","
                        + "\"FirstName\":\"" + name + "\""
                        + "}";
            } else {
                // Organization (default safe)
                payload = "{"
                        + "\"BusinessPartnerCategory\":\"2\","
                        + "\"BusinessPartnerGrouping\":\"" + grouping + "\","
                        + "\"OrganizationBPName1\":\"" + name + "\""
                        + "}";
            }

            // 🔥 5. POST request with CSRF token
            HttpRequest postRequest = HttpRequest.newBuilder()
                    .uri(URI.create(BASE_URL + "/A_BusinessPartner"))
                    .header("APIKey", API_KEY)
                    .header("Content-Type", "application/json")
                    .header("x-csrf-token", csrfToken)
                    .POST(HttpRequest.BodyPublishers.ofString(payload))
                    .build();

            HttpResponse<String> postResponse =
                    client.send(postRequest, HttpResponse.BodyHandlers.ofString());

            // 🔥 6. Handle response
            if (postResponse.statusCode() >= 200 && postResponse.statusCode() < 300) {
                ctx.put("result", postResponse.body());
            } else {
                throw new RuntimeException("S/4 Error: " + postResponse.body());
            }

        } catch (Exception e) {
            throw new RuntimeException("External POST failed: " + e.getMessage());
        }
    }

}