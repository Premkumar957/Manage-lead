using { com.mycompany.leads as db} from '../db/sales-offer';


service SalesService {

    // Main Entity
    @odata.draft.enabled
    entity SalesOffers as projection on db.SalesOffers { * } excluding { modifiedAt, modifiedBy };

    // Child Entities
    entity SalesOfferItems as projection on db.SalesOfferItems { * } excluding { modifiedAt, modifiedBy };
    entity SalesOfferNotes as projection on db.SalesOfferNotes { * } excluding { modifiedAt, modifiedBy };
}