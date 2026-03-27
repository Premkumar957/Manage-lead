package customer.manage_lead.external;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.net.URI;
import java.net.http.*;
import java.util.*;
import java.util.zip.GZIPInputStream;

import org.springframework.stereotype.Component;

import com.fasterxml.jackson.databind.*;
import com.sap.cds.Result;
import com.sap.cds.ResultBuilder;
import com.sap.cds.services.cds.CdsReadEventContext;
import com.sap.cds.services.handler.EventHandler;
import com.sap.cds.services.handler.annotations.*;

@Component
@ServiceName("ExternalService")
public class ExternalServiceHandler implements EventHandler {

    private static final String URL =
        "https://sandbox.api.sap.com/s4hanacloud/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner?$top=5&$inlinecount=allpages";

    private static final String API_KEY = "PyEKIqtO6jMczj1yyn3xctK2QETvlqGn";

    @On(event = "READ", entity = "ExternalService.BusinessPartners")
    public Result onReadBusinessPartners(CdsReadEventContext context)
            throws IOException, InterruptedException {

        HttpClient client = HttpClient.newHttpClient();

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(URL))
                .header("APIKey", API_KEY)
                .header("Accept", "application/json")
                .header("Content-Type", "application/json")
                .header("Accept-Encoding", "gzip")
                .GET()
                .build();

        HttpResponse<byte[]> response =
                client.send(request, HttpResponse.BodyHandlers.ofByteArray());

        if (response.statusCode() != 200) {
            throw new RuntimeException("API failed: " + response.statusCode()
                    + " | " + new String(response.body()));
        }

        // ✅ Handle gzip
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

        ObjectMapper mapper = new ObjectMapper();
        JsonNode root = mapper.readTree(responseBody);

        // ✅ OData V2 structure
        JsonNode dNode = root.path("d");
        JsonNode resultsNode = dNode.path("results");

        List<Map<String, Object>> rows = mapper.convertValue(
                resultsNode,
                new com.fasterxml.jackson.core.type.TypeReference<List<Map<String, Object>>>() {}
        );

        // ✅ Extract count (OData V2)
        int count = rows.size(); // fallback

        if (dNode.has("__count")) {
            try {
                count = Integer.parseInt(dNode.get("__count").asText());
            } catch (Exception e) {
                count = rows.size();
            }
        }

        return ResultBuilder.selectedRows(rows)
                .inlineCount(count)
                .result();
    }
}