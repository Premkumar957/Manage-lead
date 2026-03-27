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
            IsMarkedForArchiving,
            CreationDate
    };

    // 2. Address
    entity BusinessPartnerAddresses as projection on external.A_BusinessPartnerAddress {
        key BusinessPartner,
        key AddressID,
            StreetName,
            HouseNumber,
            CityName,
            PostalCode,
            Region,
            Country
    };

    // 3. Role
    entity BusinessPartnerRoles as projection on external.A_BusinessPartnerRole {
        key BusinessPartner,
        key BusinessPartnerRole,
            ValidFrom,
            ValidTo
    };

}