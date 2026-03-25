package customer.manage_lead.handlers;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;
import java.util.Set;
import java.util.UUID;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.sap.cds.ql.Insert;
import com.sap.cds.services.handler.EventHandler;
import com.sap.cds.services.handler.annotations.On;
import com.sap.cds.services.handler.annotations.ServiceName;
import com.sap.cds.services.persistence.PersistenceService;

import cds.gen.UploadExcelResult;
import cds.gen.leadservice.UploadExcelContext;
import cds.gen.leadservice.Leads;
import cds.gen.leadservice.Leads_;

@Component
@ServiceName("LeadService")
public class LeadServiceHandler implements EventHandler {

        @Autowired
        PersistenceService db;

        private static final Set<String> VALID_LEAD_TYPE = Set.of("Person", "Organization");
        private static final Set<String> VALID_LEAD_CATEGORY = Set.of("Hot", "Warm", "Cold");
        private static final Set<String> VALID_SOURCE = Set.of("Agent", "Website", "Advertisement", "Friends",
                        "Referral");
        private static final Set<String> VALID_PROSPECT = Set.of("Client", "Partner", "Investor", "Vendor");
        private static final Set<String> VALID_STATUS = Set.of("New", "Completed", "InProcess", "Active", "Inactive");

        @On(event = "UploadExcel")
        public void uploadExcel(UploadExcelContext context) {

                int imported = 0;
                int skipped = 0;
                List<String> errors = new ArrayList<>();

                // ✅ Now receiving String (base64), not byte[]
                String base64File = context.getFile();

                if (base64File == null || base64File.isBlank()) {
                        context.setResult(buildResult(0, 0, "No file received"));
                        return;
                }

                // ✅ Decode base64 → byte[]
                byte[] fileBytes;
                try {
                        // Strip data URI prefix if present: "data:...;base64,XXXX"
                        String base64Data = base64File.contains(",")
                                        ? base64File.split(",")[1]
                                        : base64File;

                        fileBytes = Base64.getDecoder().decode(base64Data);
                } catch (IllegalArgumentException e) {
                        context.setResult(buildResult(0, 0, "Invalid base64 file data"));
                        return;
                }

                // Parse Excel
                try (
                                ByteArrayInputStream bis = new ByteArrayInputStream(fileBytes);
                                Workbook workbook = new XSSFWorkbook(bis)) {
                        Sheet sheet = workbook.getSheetAt(0);

                        for (int i = 1; i <= sheet.getLastRowNum(); i++) {

                                Row row = sheet.getRow(i);
                                if (row == null) {
                                        skipped++;
                                        continue;
                                }

                                try {
                                        String name = getCellValue(row, 0);
                                        String leadType = getCellValue(row, 1);
                                        String leadCategory = getCellValue(row, 2);
                                        String sourceOfLead = getCellValue(row, 3);
                                        String prospectType = getCellValue(row, 4);
                                        String salesAdvisor = getCellValue(row, 5);
                                        String status = getCellValue(row, 6);

                                        if (name == null || name.isBlank()) {
                                                skipped++;
                                                errors.add("Row " + (i + 1) + ": name is required");
                                                continue;
                                        }

                                        if (!leadType.isEmpty() && !VALID_LEAD_TYPE.contains(leadType)) {
                                                skipped++;
                                                errors.add("Row " + (i + 1) + ": invalid leadType '" + leadType + "'");
                                                continue;
                                        }
                                        if (!leadCategory.isEmpty() && !VALID_LEAD_CATEGORY.contains(leadCategory)) {
                                                skipped++;
                                                errors.add("Row " + (i + 1) + ": invalid leadCategory '" + leadCategory
                                                                + "'");
                                                continue;
                                        }
                                        if (!sourceOfLead.isEmpty() && !VALID_SOURCE.contains(sourceOfLead)) {
                                                skipped++;
                                                errors.add("Row " + (i + 1) + ": invalid sourceOfLead '" + sourceOfLead
                                                                + "'");
                                                continue;
                                        }
                                        if (!prospectType.isEmpty() && !VALID_PROSPECT.contains(prospectType)) {
                                                skipped++;
                                                errors.add("Row " + (i + 1) + ": invalid prospectType '" + prospectType
                                                                + "'");
                                                continue;
                                        }
                                        if (!status.isEmpty() && !VALID_STATUS.contains(status)) {
                                                skipped++;
                                                errors.add("Row " + (i + 1) + ": invalid status '" + status + "'");
                                                continue;
                                        }

                                        Leads lead = Leads.create();
                                        lead.setId(UUID.randomUUID().toString());
                                        lead.put("name", name);
                                        lead.put("leadType", leadType.isEmpty() ? null : leadType);
                                        lead.put("leadCategory", leadCategory.isEmpty() ? null : leadCategory);
                                        lead.put("sourceOfLead", sourceOfLead.isEmpty() ? null : sourceOfLead);
                                        lead.put("prospectType", prospectType.isEmpty() ? null : prospectType);
                                        lead.put("salesAdvisor", salesAdvisor.isEmpty() ? null : salesAdvisor);
                                        lead.put("status", status.isEmpty() ? null : status);

                                        db.run(Insert.into(Leads_.class).entry(lead));
                                        imported++;

                                } catch (Exception rowEx) {
                                        skipped++;
                                        errors.add("Row " + (i + 1) + ": " + rowEx.getMessage());
                                }
                        }

                } catch (IOException e) {
                        context.setResult(buildResult(0, 0, "Failed to parse Excel: " + e.getMessage()));
                        return;
                }

                String message = errors.isEmpty()
                                ? "Upload completed"
                                : "Upload completed with issues:\n" + String.join("\n", errors);

                context.setResult(buildResult(imported, skipped, message));
        }

        private String getCellValue(Row row, int colIndex) {
                Cell cell = row.getCell(colIndex, Row.MissingCellPolicy.RETURN_BLANK_AS_NULL);
                if (cell == null)
                        return "";

                switch (cell.getCellType()) {
                        case STRING:
                                return cell.getStringCellValue().trim();
                        case NUMERIC:
                                double val = cell.getNumericCellValue();
                                return (val == Math.floor(val)) ? String.valueOf((long) val) : String.valueOf(val);
                        case BOOLEAN:
                                return String.valueOf(cell.getBooleanCellValue());
                        case FORMULA:
                                try {
                                        return cell.getStringCellValue().trim();
                                } catch (Exception ex) {
                                        return String.valueOf((long) cell.getNumericCellValue());
                                }
                        default:
                                return "";
                }
        }

        private UploadExcelResult buildResult(int imported, int skipped, String message) {
                UploadExcelResult result = UploadExcelResult.create();
                result.setImported(imported);
                result.setSkipped(skipped);
                result.setMessage(message);
                return result;
        }
}