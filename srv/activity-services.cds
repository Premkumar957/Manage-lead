using { com.mycompany.leads as db } from '../db/activity.cds';


service ActivitiesService {

    // Main entity
    @odata.draft.enabled
    entity Activities as projection on db.Activities { * } excluding { modifiedAt, modifiedBy };

    // Child entities
    entity Scheduling as projection on db.Scheduling { * } excluding { modifiedAt, modifiedBy };
    entity Attachments as projection on db.Attachments { * } excluding { modifiedAt, modifiedBy };

}