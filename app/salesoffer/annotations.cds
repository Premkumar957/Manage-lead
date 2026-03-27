using SalesService as service from '../../srv/sales-offer-service';
annotate service.SalesOffers with @(
    UI.FieldGroup #GeneratedGroup : {
        $Type : 'UI.FieldGroupType',
        Data : [
            {
                $Type : 'UI.DataField',
                Label : 'leadNo',
                Value : leadNo,
            },
            {
                $Type : 'UI.DataField',
                Label : 'project',
                Value : project,
            },
            {
                $Type : 'UI.DataField',
                Label : 'expectedDate',
                Value : expectedDate,
            },
            {
                $Type : 'UI.DataField',
                Label : 'property',
                Value : property,
            },
            {
                $Type : 'UI.DataField',
                Label : 'customer',
                Value : customer,
            },
            {
                $Type : 'UI.DataField',
                Value : createdAt,
            },
            {
                $Type : 'UI.DataField',
                Value : createdBy,
            },
        ],
    },
    UI.Facets : [
        {
            $Type : 'UI.ReferenceFacet',
            ID : 'GeneratedFacet1',
            Label : 'General Information',
            Target : '@UI.FieldGroup#GeneratedGroup',
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'SalessOfferItems',
            ID : 'SalessOfferItems',
            Target : 'items/@UI.LineItem#SalessOfferItems',
        },
    ],
    UI.LineItem : [
        {
            $Type : 'UI.DataField',
            Label : 'ID',
            Value : leadNo,
        },
        {
            $Type : 'UI.DataField',
            Label : 'project',
            Value : project,
        },
        {
            $Type : 'UI.DataField',
            Label : 'expectedDate',
            Value : expectedDate,
        },
        {
            $Type : 'UI.DataField',
            Label : 'property',
            Value : property,
        },
        {
            $Type : 'UI.DataField',
            Label : 'customer',
            Value : customer,
        },
        {
            $Type : 'UI.DataField',
            Value : createdAt,
        },
        {
            $Type : 'UI.DataField',
            Value : createdBy,
        },
    ],
    UI.SelectionFields : [
        expectedDate,
        leadNo,
        customer,
    ],
    UI.HeaderInfo : {
        TypeName : 'SaleOffer',
        TypeNamePlural : 'SalesOffers',
        Title : {
            $Type : 'UI.DataField',
            Value : leadNo,
        },
        Description : {
            $Type : 'UI.DataField',
            Value : property,
        },
    },
);

annotate service.SalesOffers with {
    expectedDate @Common.Label : 'expectedDate'
};

annotate service.SalesOffers with {
    leadNo @Common.Label : 'leadNo'
};

annotate service.SalesOffers with {
    customer @Common.Label : 'customer'
};

annotate service.SalesOfferItems with @(
    UI.LineItem #SalesOfferItems : [
    ],
    UI.LineItem #SalessOfferItems : [
        {
            $Type : 'UI.DataField',
            Value : unitType,
            Label : 'unitType',
        },
        {
            $Type : 'UI.DataField',
            Value : area,
            Label : 'area',
        },
        {
            $Type : 'UI.DataField',
            Value : price,
            Label : 'price',
        },
        {
            $Type : 'UI.DataField',
            Value : currency,
            Label : 'currency',
        },
        {
            $Type : 'UI.DataField',
            Value : createdAt,
        },
        {
            $Type : 'UI.DataField',
            Value : createdBy,
        },
    ],
);

annotate service.SalesOfferNotes with @(
    UI.LineItem #SalesOfferNotes : [
    ]
);

