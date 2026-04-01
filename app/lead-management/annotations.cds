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
    ]
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
    ],
    UI.HeaderInfo : {
        TypeName : 'Activity',
        TypeNamePlural : 'Activities',
        Title : {
            $Type : 'UI.DataField',
            Value : lead_ID,
        },
        Description : {
            $Type : 'UI.DataField',
            Value : status,
        },
        TypeImageUrl : 'sap-icon://activity-items',
    },
    UI.Facets : [
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Activity Information',
            ID : 'ActivityInformation',
            Target : '@UI.FieldGroup#ActivityInformation',
        },
    ],
    UI.FieldGroup #ActivityInformation : {
        $Type : 'UI.FieldGroupType',
        Data : [
            {
                $Type : 'UI.DataField',
                Value : ID,
                Label : 'ID',
            },
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



annotate service.Leads with {
    status @(
        Common.ValueList : {
            $Type : 'Common.ValueListType',
            CollectionPath : 'LeadStatuses',
            Parameters : [
                {
                    $Type : 'Common.ValueListParameterInOut',
                    LocalDataProperty : status,
                    ValueListProperty : 'code',
                },
            ],
            Label : 'Select Status',
        },
        Common.ValueListWithFixedValues : false,
)};

annotate service.LeadStatuses with {
    code @(
        Common.Text : name,
        Common.Text.@UI.TextArrangement : #TextFirst,
    )
};

annotate service.Leads with {
    leadType @(
        Common.ValueList : {
            $Type : 'Common.ValueListType',
            CollectionPath : 'LeadTypes',
            Parameters : [
                {
                    $Type : 'Common.ValueListParameterInOut',
                    LocalDataProperty : leadType,
                    ValueListProperty : 'code',
                },
            ],
            Label : 'Lead Type',
        },
        Common.ValueListWithFixedValues : true,
)};

annotate service.Leads with {
    leadCategory @(
        Common.ValueList : {
            $Type : 'Common.ValueListType',
            CollectionPath : 'LeadCategories',
            Parameters : [
                {
                    $Type : 'Common.ValueListParameterInOut',
                    LocalDataProperty : leadCategory,
                    ValueListProperty : 'code',
                },
            ],
            Label : 'Lead Category',
        },
        Common.ValueListWithFixedValues : true,
)};

annotate service.Leads with {
    sourceOfLead @(
        Common.ValueList : {
            $Type : 'Common.ValueListType',
            CollectionPath : 'SourceOfLeads',
            Parameters : [
                {
                    $Type : 'Common.ValueListParameterInOut',
                    LocalDataProperty : sourceOfLead,
                    ValueListProperty : 'code',
                },
            ],
            Label : 'Source of Lead',
        },
        Common.ValueListWithFixedValues : false,
)};

annotate service.Leads with {
    prospectType @(
        Common.ValueList : {
            $Type : 'Common.ValueListType',
            CollectionPath : 'ProspectTypes',
            Parameters : [
                {
                    $Type : 'Common.ValueListParameterInOut',
                    LocalDataProperty : prospectType,
                    ValueListProperty : 'code',
                },
            ],
            Label : 'Prospect Type',
        },
        Common.ValueListWithFixedValues : true,
)};

annotate service.LeadActivities with {
    activityType @(
        Common.ValueList : {
            $Type : 'Common.ValueListType',
            CollectionPath : 'ActivityTypes',
            Parameters : [
                {
                    $Type : 'Common.ValueListParameterInOut',
                    LocalDataProperty : activityType,
                    ValueListProperty : 'code',
                },
            ],
            Label : 'Activity Type',
        },
        Common.ValueListWithFixedValues : false,
)};

annotate service.LeadActivities with {
    status @(
        Common.ValueList : {
            $Type : 'Common.ValueListType',
            CollectionPath : 'ActivityStatuses',
            Parameters : [
                {
                    $Type : 'Common.ValueListParameterInOut',
                    LocalDataProperty : status,
                    ValueListProperty : 'code',
                },
            ],
            Label : 'Status',
        },
        Common.ValueListWithFixedValues : true,
)};

