using LeadService as service from '../../srv/services';

//////////////////////////////////////////
// LEADS
//////////////////////////////////////////

annotate service.Leads with @(
    UI.FieldGroup #GeneratedGroup : {
        $Type : 'UI.FieldGroupType',
        Data : [
            { $Type : 'UI.DataField', Value : name },
            { $Type : 'UI.DataField', Value : leadType },
            { $Type : 'UI.DataField', Value : leadCategory },
            { $Type : 'UI.DataField', Value : sourceOfLead },
            { $Type : 'UI.DataField', Value : prospectType },
            { $Type : 'UI.DataField', Value : salesAdvisor },
            { $Type : 'UI.DataField', Value : status }
        ]
    },

    UI.Facets : [
        {
            $Type : 'UI.ReferenceFacet',
            ID : 'GeneralInformation',
            Label : 'General Information',
            Target : '@UI.FieldGroup#GeneratedGroup'
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID : 'Activities',
            Label : 'Activities',
            Target : 'activities/@UI.LineItem#Activities'
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID : 'Contacts',
            Label : 'Contacts',
            Target : 'contacts/@UI.LineItem#Contacts'
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID : 'Notes',
            Label : 'Notes',
            Target : 'notes/@UI.LineItem#Notes'
        }
    ],

    UI.LineItem : [
        { $Type : 'UI.DataField', Value : name },
        { $Type : 'UI.DataField', Value : leadType },
        { $Type : 'UI.DataField', Value : leadCategory },
        { $Type : 'UI.DataField', Value : sourceOfLead },
        { $Type : 'UI.DataField', Value : prospectType },
        { $Type : 'UI.DataField', Value : salesAdvisor },
        { $Type : 'UI.DataField', Value : status }
    ],

    UI.HeaderInfo : {
        TypeName : 'Lead',
        TypeNamePlural : 'Leads',
        Title : { $Type : 'UI.DataField', Value : name },
        Description : { $Type : 'UI.DataField', Value : leadType }
    },

    UI.SelectionFields : [
        leadType,
        leadCategory,
        status
    ]
);

//////////////////////////////////////////
// LEAD ACTIVITIES (FIXED PART)
//////////////////////////////////////////

annotate service.LeadActivities with @(

    UI.LineItem #Activities : [
        { $Type : 'UI.DataField', Value : subject },
        { $Type : 'UI.DataField', Value : activityType },

        // ✅ FIXED STATUS
        {
            $Type : 'UI.DataField',
            Value : status_code,
            Criticality : status.criticality,
            Label : 'Status'
        },

        { $Type : 'UI.DataField', Value : scheduledAt },
        { $Type : 'UI.DataField', Value : completedAt }
    ],

    UI.HeaderInfo : {
        TypeName : 'Activity',
        TypeNamePlural : 'Activities',
        Title : { $Type : 'UI.DataField', Value : subject },

        // ✅ FIXED
        Description : { $Type : 'UI.DataField', Value : status_code }
    },

    UI.Facets : [
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Activity Information',
            ID : 'ActivityInformation',
            Target : '@UI.FieldGroup#ActivityInformation'
        }
    ],

    UI.FieldGroup #ActivityInformation : {
        $Type : 'UI.FieldGroupType',
        Data : [
            { $Type : 'UI.DataField', Value : ID, Label : 'ID' },
            { $Type : 'UI.DataField', Value : subject },
            { $Type : 'UI.DataField', Value : activityType },

            // ✅ FIXED STATUS FIELD
            {
                $Type : 'UI.DataField',
                Value : status_code,
                Criticality : status.criticality
            },

            { $Type : 'UI.DataField', Value : scheduledAt },
            { $Type : 'UI.DataField', Value : completedAt },
            { $Type : 'UI.DataField', Value : createdAt },
            { $Type : 'UI.DataField', Value : createdBy }
        ]
    }
);

//////////////////////////////////////////
// CONTACTS
//////////////////////////////////////////

annotate service.LeadContactPersons with @(
    UI.LineItem #Contacts : [
        { $Type : 'UI.DataField', Value : firstName },
        { $Type : 'UI.DataField', Value : lastName },
        { $Type : 'UI.DataField', Value : phone },
        { $Type : 'UI.DataField', Value : email },
        { $Type : 'UI.DataField', Value : isPrimary }
    ]
);

//////////////////////////////////////////
// NOTES
//////////////////////////////////////////

annotate service.LeadNotes with @(
    UI.LineItem #Notes : [
        { $Type : 'UI.DataField', Value : note },
        { $Type : 'UI.DataField', Value : noteAt },
        { $Type : 'UI.DataField', Value : noteBy }
    ]
);

//////////////////////////////////////////
// VALUE HELP - LEADS (UNCHANGED)
//////////////////////////////////////////

annotate service.LeadStatuses with {
    code @(
        Common.Text : name,
        Common.Text.@UI.TextArrangement : #TextFirst
    )
};

//////////////////////////////////////////
// VALUE HELP - ACTIVITY TYPE
//////////////////////////////////////////

annotate service.LeadActivities with {
    activityType @(
        Common.ValueList : {
            $Type : 'Common.ValueListType',
            CollectionPath : 'ActivityTypes',
            Parameters : [
                {
                    $Type : 'Common.ValueListParameterInOut',
                    LocalDataProperty : activityType,
                    ValueListProperty : 'code'
                }
            ]
        }
    )
};

//////////////////////////////////////////
// ✅ FINAL STATUS CONFIG (ONLY THIS ONE)
//////////////////////////////////////////

annotate service.LeadActivities with {

  status_code @(
    Common.Text : status.name,
    Common.TextArrangement : #TextOnly,

    Common.ValueList : {
      $Type : 'Common.ValueListType',
      CollectionPath : 'ActivityStatuses',
      Parameters : [
        {
          $Type : 'Common.ValueListParameterInOut',
          LocalDataProperty : status_code,
          ValueListProperty : 'code'
        }
      ]
    }
  );

  status_code @UI.Criticality : status.criticality;

};