using LeadService as service from '../../srv/services';
annotate service.Leads with @(
    UI.FieldGroup #GeneratedGroup : {
        $Type : 'UI.FieldGroupType',
        Data : [
            {
                $Type : 'UI.DataField',
                Value : name,
            },
            {
                $Type : 'UI.DataField',
                Value : leadType,
            },
            {
                $Type : 'UI.DataField',
                Value : leadCategory,
            },
            {
                $Type : 'UI.DataField',
                Value : sourceOfLead,
            },
            {
                $Type : 'UI.DataField',
                Value : prospectType,
            },
            {
                $Type : 'UI.DataField',
                Value : salesAdvisor,
            },
            {
                $Type : 'UI.DataField',
                Value : status,
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
            Label : 'Activities',
            ID : 'Activities',
            Target : 'activities/@UI.LineItem#Activities',
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Contacts',
            ID : 'Contacts',
            Target : 'contacts/@UI.LineItem#Contacts',
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Notes',
            ID : 'Notes',
            Target : 'notes/@UI.LineItem#Notes',
        },
    ],
    UI.LineItem : [
        {
            $Type : 'UI.DataField',
            Value : name,
        },
        {
            $Type : 'UI.DataField',
            Value : leadType,
        },
        {
            $Type : 'UI.DataField',
            Value : leadCategory,
        },
        {
            $Type : 'UI.DataField',
            Value : sourceOfLead,
        },
        {
            $Type : 'UI.DataField',
            Value : prospectType,
        },
        {
            $Type : 'UI.DataField',
            Value : salesAdvisor,
        },
        {
            $Type : 'UI.DataField',
            Value : status,
        }
    ],
    UI.HeaderInfo : {
        TypeName : 'Lead',
        TypeNamePlural : 'Leads',
        Title : {
            $Type : 'UI.DataField',
            Value : name,
        },
        Description : {
            $Type : 'UI.DataField',
            Value : leadType,
        },
        TypeImageUrl : 'sap-icon://account',
    },
    UI.SelectionFields : [
        leadType,
        leadCategory,
        status,
    ],
);

annotate service.LeadActivities with @(
    UI.LineItem #Activities : [
        {
            $Type : 'UI.DataField',
            Value : subject,
        },
        {
            $Type : 'UI.DataField',
            Value : activityType,
        },
        {
            $Type : 'UI.DataField',
            Value : status,
        },
        {
            $Type : 'UI.DataField',
            Value : scheduledAt,
        },
        {
            $Type : 'UI.DataField',
            Value : completedAt,
        },
    ]
);

annotate service.LeadContactPersons with @(
    UI.LineItem #Contacts : [
        {
            $Type : 'UI.DataField',
            Value : firstName,
        },
        {
            $Type : 'UI.DataField',
            Value : lastName,
        },
        {
            $Type : 'UI.DataField',
            Value : phone,
        },
        {
            $Type : 'UI.DataField',
            Value : email,
        },
        {
            $Type : 'UI.DataField',
            Value : isPrimary,
        },
    ]
);

annotate service.LeadNotes with @(
    UI.LineItem #Notes : [
        {
            $Type : 'UI.DataField',
            Value : note,
        },
        {
            $Type : 'UI.DataField',
            Value : noteAt,
        },
        {
            $Type : 'UI.DataField',
            Value : noteBy,
        },
    ]
);


