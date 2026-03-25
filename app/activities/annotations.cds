using ActivitiesService as service from '../../srv/activity-services';
annotate service.Activities with @(
    UI.FieldGroup #GeneratedGroup : {
        $Type : 'UI.FieldGroupType',
        Data : [
            {
                $Type : 'UI.DataField',
                Label : 'accountType',
                Value : accountType,
            },
            {
                $Type : 'UI.DataField',
                Label : 'activityType',
                Value : activityType,
            },
            {
                $Type : 'UI.DataField',
                Label : 'customer',
                Value : customer,
            },
            {
                $Type : 'UI.DataField',
                Label : 'startDate',
                Value : startDate,
            },
            {
                $Type : 'UI.DataField',
                Label : 'dueDate',
                Value : dueDate,
            },
            {
                $Type : 'UI.DataField',
                Label : 'priority',
                Value : priority,
            },
            {
                $Type : 'UI.DataField',
                Label : 'salesAdvisor',
                Value : salesAdvisor,
            },
            {
                $Type : 'UI.DataField',
                Label : 'status',
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
            Label : 'Scheduling',
            ID : 'Scheduling',
            Target : 'schedule/@UI.LineItem#Scheduling',
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Attachments',
            ID : 'Attachments',
            Target : 'attachment/@UI.LineItem#Attachments',
        },
    ],
    UI.LineItem : [
        {
            $Type : 'UI.DataField',
            Label : 'accountType',
            Value : accountType,
        },
        {
            $Type : 'UI.DataField',
            Label : 'activityType',
            Value : activityType,
        },
        {
            $Type : 'UI.DataField',
            Label : 'customer',
            Value : customer,
        },
        {
            $Type : 'UI.DataField',
            Label : 'startDate',
            Value : startDate,
        },
        {
            $Type : 'UI.DataField',
            Label : 'dueDate',
            Value : dueDate,
        },
        {
            $Type : 'UI.DataField',
            Value : ID,
            Label : 'ID',
        },
        {
            $Type : 'UI.DataField',
            Value : priority,
            Label : 'priority',
        },
        {
            $Type : 'UI.DataField',
            Value : status,
            Label : 'status',
        },
        {
            $Type : 'UI.DataField',
            Value : createdBy,
        },
        {
            $Type : 'UI.DataField',
            Value : createdAt,
        },
        {
            $Type : 'UI.DataField',
            Value : salesAdvisor,
        },
    ],
    UI.SelectionFields : [
        accountType,
        startDate,
        dueDate,
        salesAdvisor,
    ],
    UI.HeaderInfo : {
        TypeName : 'Activity',
        TypeNamePlural : 'Activities',
        Title : {
            $Type : 'UI.DataField',
            Value : customer,
        },
    },
    UI.FieldGroup #Attachments : {
        $Type : 'UI.FieldGroupType',
        Data : [
        ],
    },
);

annotate service.Activities with {
    accountType @Common.Label : 'accountType'
};

annotate service.Activities with {
    startDate @Common.Label : 'startDate'
};

annotate service.Activities with {
    dueDate @Common.Label : 'dueDate'
};

annotate service.Activities with {
    salesAdvisor @Common.Label : 'salesAdvisor'
};

annotate service.Scheduling with @(
    UI.LineItem #Scheduling : [
    ]
);

annotate service.Attachments with @(
    UI.LineItem #Attachments : [
    ]
);

