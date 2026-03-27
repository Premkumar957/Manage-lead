using {com.mycompany.leads as db} from '../db/schema';


type UploadExcelResult {
    imported : Integer;
    skipped  : Integer;
    message  : String;
}



service LeadService {

    // Main Entity
    @odata.draft.enabled
    entity Leads as projection on db.Leads { * } excluding { modifiedAt, modifiedBy };

    // Child Entities
    entity LeadActivities as projection on db.LeadActivities { * } excluding { modifiedAt, modifiedBy };

    entity LeadContactPersons as projection on db.LeadContactPersons { * } excluding { modifiedAt, modifiedBy };

    entity LeadNotes as projection on db.LeadNotes { * } excluding { modifiedAt, modifiedBy };

    // for dropdown
    entity LeadStatuses as projection on db.LeadStatuses;
    entity LeadTypes as projection on db.LeadTypes;
    entity LeadCategories as projection on db.LeadCategories;
    entity SourceOfLeads as projection on db.SourceOfLeads;
    entity ProspectTypes as projection on db.ProspectTypes;
    entity ActivityTypes as projection on db.ActivityTypes;
    entity ActivityStatuses as projection on db.ActivityStatuses;

    action UploadExcel(file : String) returns UploadExcelResult;

}




