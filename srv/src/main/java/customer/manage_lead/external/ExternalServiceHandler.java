package customer.manage_lead.external;

import java.io.ByteArrayInputStream;
import java.io.IOException;
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
}