using { API_BUSINESS_PARTNER as external } from './external/API_BUSINESS_PARTNER';

service ExternalService {

    // Main entity
    entity BusinessPartners as projection on external.A_BusinessPartner {
        key BusinessPartner,
            BusinessPartnerFullName,
            BusinessPartnerCategory,    // 1=Person | 2=Organization | 3=Group
            BusinessPartnerGrouping,
            Industry,
            Customer,
            Supplier,
            BusinessPartnerIsBlocked,
            IsMarkedForArchiving
    };

    action createBusinessPartner(
        BusinessPartnerFullName : String,
        BusinessPartnerCategory : String,
        BusinessPartnerGrouping : String,
        Industry : String,
        Customer : Boolean,
        Supplier : Boolean,
        BusinessPartnerIsBlocked : Boolean,
        IsMarkedForArchiving : Boolean
    ) returns String;

}