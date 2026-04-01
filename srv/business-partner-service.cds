using { API_BUSINESS_PARTNER as external } from './external/API_BUSINESS_PARTNER';

service ExternalService {

    // Main entity
    entity BusinessPartners as projection on external.A_BusinessPartner {
        key BusinessPartner,
            BusinessPartnerFullName,
            BusinessPartnerCategory,    // 1=Person | 2=Organization | 3=Group
            BusinessPartnerGrouping,

            FirstName,
            LastName,

            OrganizationBPName1,
            GroupBusinessPartnerName1,

            CorrespondenceLanguage,    // 1.EN  2.DE  3.FR
            BusinessPartnerIsBlocked,
            IsMarkedForArchiving
    };

    action createBusinessPartner(
        BusinessPartnerCategory  : String,
        BusinessPartnerGrouping  : String,
        FirstName                : String,   // ✅ must exist
        LastName                 : String,   // ✅ must exist
        OrganizationBPName1      : String,
        GroupBusinessPartnerName1: String,
        CorrespondenceLanguage   : String
    ) returns String;

}

