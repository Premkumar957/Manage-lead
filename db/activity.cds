namespace com.mycompany.leads;

using { cuid, managed } from '@sap/cds/common';



entity Activities : cuid, managed {
    accountType  : String(20) @mandatory @title : 'Account Type';  // use enum
    activityType : String(20) @title : 'Activity Type';  // use enum
    customer     : String(30) @title : 'Customer';
    startDate    : Date @mandatory @title : 'Start Date';
    dueDate      : Date @mandatory @title : 'Due Date';
    priority     : String(20) @mandatory @title : 'Priority';   // use enum
    salesAdvisor : String(30) @title : 'Sales Advisor';
    status       : String(20) @title : 'Status';   // use enum

    schedule     : Composition of many Scheduling on schedule.activity = $self;
    attachment   : Composition of many Attachments on attachment.activity = $self;
}



entity Scheduling : cuid {
    activity        : Association to Activities;
    startDate       : Timestamp @mandatory @title : 'Start Date';
    dueDate         : Timestamp @mandatory @title : 'Due Date';
    duration        : Integer @title : 'Duration';
    meetingLocation : String(50) @mandatory @title : 'Meeting Location';
}


entity Attachments : cuid  {
    activity        : Association to Activities;
    fileName   : String(255);
    fileType   : String(100);
    uploadedBy : String(100);
    uploadedAt : DateTime;
}