using { API_BUSINESS_PARTNER as external } from './external/API_BUSINESS_PARTNER';

service ExternalService {

    entity BusinessPartners as projection on external.A_BusinessPartner {
        key BusinessPartner,
        BusinessPartnerFullName
    };

}