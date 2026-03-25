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


    action UploadExcel(file : String) returns UploadExcelResult;

}




