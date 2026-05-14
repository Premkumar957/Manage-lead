namespace com.mycompany.leads;
using { cuid, managed } from '@sap/cds/common';

// ── TYPES ──

type LeadType : String @assert.range enum {
    Person       = 'Person';
    Organization = 'Organization';
}

type LeadCategory : String @assert.range enum {
    Hot  = 'Hot';
    Warm = 'Warm';
    Cold = 'Cold';
}

type SourceOfLead : String @assert.range enum {
    Agent         = 'Agent';
    Website       = 'Website';
    Advertisement = 'Advertisement';
    Friends       = 'Friends';
    Referral      = 'Referral';
}

type ProspectType : String @assert.range enum {
    Client   = 'Client';
    Partner  = 'Partner';
    Investor = 'Investor';
    Vendor   = 'Vendor';
}

type LeadStatus : String @assert.range enum {
    New       = 'New';
    Completed = 'Completed';
    InProcess = 'InProcess';
    Active    = 'Active';
    Inactive  = 'Inactive';
}

type ActivityType : String @assert.range enum {
    Call    = 'Call';
    Email   = 'Email';
    Meeting = 'Meeting';
    Demo    = 'Demo';
}

type ActivityStatus : String @assert.range enum {
    Planned   = 'Planned';
    Completed = 'Completed';
    Cancelled = 'Cancelled';
}

// ── ENTITIES ──

entity Leads : cuid, managed {
    name         : String(100)  @mandatory @title: 'Name';
    leadType     : LeadType     @title: 'Lead Type';
    leadCategory : LeadCategory @title: 'Lead Category';
    sourceOfLead : SourceOfLead @title: 'Source of Lead';
    prospectType : ProspectType @title: 'Prospect Type';
    salesAdvisor : String(100)  @mandatory @title: 'Sales Advisor';
    status       : LeadStatus   @title: 'Status';

    // ── Compositions ──
    activities   : Composition of many LeadActivities     on activities.lead = $self;
    contacts     : Composition of many LeadContactPersons on contacts.lead   = $self;
    notes        : Composition of many LeadNotes          on notes.lead      = $self;
    attachments  : Composition of many LeadAttachments    on attachments.lead = $self;
}

entity LeadActivities : cuid, managed {
    lead         : Association to Leads;
    activityType : ActivityType   @title: 'Activity Type';
    subject      : String(200)    @mandatory @title: 'Subject';
    scheduledAt  : DateTime       @title: 'Scheduled At';
    completedAt  : DateTime       @title: 'Completed At';
    status_code  : String(20) @title : 'Status';
    status       : Association to ActivityStatuses
                    on status.code = status_code;
}

entity LeadContactPersons : cuid, managed {
    lead      : Association to Leads;
    firstName : String(50)   @mandatory @title: 'First Name';
    lastName  : String(50)   @title: 'Last Name';
    email     : String(100)  @mandatory @title: 'Email';
    phone     : String(20)   @mandatory @title: 'Phone';
    isPrimary : Boolean      @title: 'Primary Contact';
}

entity LeadNotes : cuid, managed {
    lead   : Association to Leads;
    note   : String(1000)  @mandatory @title: 'Note';
    noteBy : String(100)   @title: 'Note By';
    noteAt : DateTime      @mandatory @title: 'Note Date';
}


entity LeadAttachments : cuid {
    lead       : Association to Leads;
    fileName   : String(255);
    fileType   : String(100) @Core.IsMediaType;
    content    : LargeBinary @Core.MediaType                  : fileType
                             @Core.AcceptableMediaTypes       : ['application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'] 
                             @Core.ContentDisposition.Filename: fileName;
    uploadedBy : String(100);
    uploadedAt : DateTime;
}




// for drop down
entity LeadStatuses {
    key code : String;
    name     : String;
}


entity LeadTypes {
    key code : String;
    name     : String;
}

entity LeadCategories {
    key code : String;
    name     : String;
}

entity SourceOfLeads {
    key code : String;
    name     : String;
}

entity ProspectTypes {
    key code : String;
    name     : String;
}

entity ActivityTypes {
    key code : String;
    name     : String;
}
entity ActivityStatuses {
    key code : String(20);
    name     : String(50);
    criticality : Integer; // for UI color
}



entity Products @(Common.SemanticKey: [ID]) : managed {
    key ID        : String(10);

    // Tree Structure
    // Self-association each product can point to it's parent
    // Root noeds  -> parent is null
    parent        : Association to Products;

    // Business Fields 
    identifier    : String(20);
    title         : String(100);
    description   : String(500);

    // Hierarchy computed fields
    // it's not for cap data - just for runtime only

    @Core.Computed: true 
    LimitedDescendantCount  : Integer64;  // How many visible children/grandchildren this node has // → Shows as badge: "▼ P10 (4)"

    @Core.Computed: true
    DistanceFromRoot        : Integer64;  // 0 = root,  1 = first child , 2 = grandchild

    @Core.Computed: true
    DrillState              : String;  //  "expanded" = node is open (show ▼), "collapsed" = node has children but closed  (show ▶), "leaf" = no children at all (no toggle shown)

    @Core.Computed: true
    Matched                 : Boolean;    // → true if THIS row matches the active search text

    @Core.Computed: true
    MatchedDescendantCount  : Integer64;  // How many childre/ grandchildren match the search,  Even if parent doesn't match, it stays visible



}