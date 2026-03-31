using ActivitiesService as service from '../../srv/activity-services';
using from '../../srv/business-partner-service';
using from '../../srv/external/API_BUSINESS_PARTNER';

annotate ExternalService.BusinessPartners with @(
    UI.SelectionFields : [
        BusinessPartnerCategory,
        BusinessPartnerIsBlocked,
    ],
    UI.LineItem : [
        {
            $Type : 'UI.DataField',
            Value : BusinessPartner,
            Label : 'BusinessPartner',
        },
        {
            $Type : 'UI.DataField',
            Value : BusinessPartnerFullName,
            Label : 'BusinessPartnerFullName',
        },
        {
            $Type : 'UI.DataField',
            Value : BusinessPartnerCategory,
        },
        {
            $Type : 'UI.DataField',
            Value : BusinessPartnerGrouping,
            Label : 'BusinessPartnerGrouping',
        },
        {
            $Type : 'UI.DataField',
            Value : BusinessPartnerIsBlocked,
        },
        {
            $Type : 'UI.DataField',
            Value : Customer,
            Label : 'Customer',
        },
        {
            $Type : 'UI.DataField',
            Value : Supplier,
            Label : 'Supplier',
        },
    ],
    UI.Facets : [
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'General Information',
            ID : 'GeneralInformation',
            Target : '@UI.FieldGroup#GeneralInformation',
        },
    ],
    UI.FieldGroup #GeneralInformation : {
        $Type : 'UI.FieldGroupType',
        Data : [
            {
                $Type : 'UI.DataField',
                Value : BusinessPartner,
                Label : 'BusinessPartner',
            },
            {
                $Type : 'UI.DataField',
                Value : BusinessPartnerCategory,
            },
            {
                $Type : 'UI.DataField',
                Value : BusinessPartnerFullName,
                Label : 'BusinessPartnerFullName',
            },
            {
                $Type : 'UI.DataField',
                Value : BusinessPartnerGrouping,
                Label : 'BusinessPartnerGrouping',
            },
            {
                $Type : 'UI.DataField',
                Value : BusinessPartnerIsBlocked,
            },
            {
                $Type : 'UI.DataField',
                Value : CreationDate,
                Label : 'CreationDate',
            },
            {
                $Type : 'UI.DataField',
                Value : Customer,
                Label : 'Customer',
            },
            {
                $Type : 'UI.DataField',
                Value : Industry,
                Label : 'Industry',
            },
            {
                $Type : 'UI.DataField',
                Value : IsMarkedForArchiving,
                Label : 'IsMarkedForArchiving',
            },
            {
                $Type : 'UI.DataField',
                Value : Supplier,
                Label : 'Supplier',
            },
        ],
    },
);

annotate ExternalService.BusinessPartners with {
    BusinessPartnerCategory @Common.Label : 'BusinessPartnerCategory'
};

annotate ExternalService.BusinessPartners with {
    BusinessPartnerIsBlocked @Common.Label : 'BusinessPartnerIsBlocked'
};

