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
    name         : String(100)  @title: 'Name';
    leadType     : LeadType     @title: 'Lead Type';
    leadCategory : LeadCategory @title: 'Lead Category';
    sourceOfLead : SourceOfLead @title: 'Source of Lead';
    prospectType : ProspectType @title: 'Prospect Type';
    salesAdvisor : String(100)  @title: 'Sales Advisor';
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
    subject      : String(200)    @title: 'Subject';
    scheduledAt  : DateTime       @title: 'Scheduled At';
    completedAt  : DateTime       @title: 'Completed At';
    status       : ActivityStatus @title: 'Status';
}

entity LeadContactPersons : cuid, managed {
    lead      : Association to Leads;
    firstName : String(50)   @title: 'First Name';
    lastName  : String(50)   @title: 'Last Name';
    email     : String(100)  @title: 'Email';
    phone     : String(20)   @title: 'Phone';
    isPrimary : Boolean      @title: 'Primary Contact';
}

entity LeadNotes : cuid, managed {
    lead   : Association to Leads;
    note   : String(1000)  @title: 'Note';
    noteBy : String(100)   @title: 'Note By';
    noteAt : DateTime      @title: 'Note Date';
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