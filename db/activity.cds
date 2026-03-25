namespace com.mycompany.leads;

using { cuid, managed } from '@sap/cds/common';



entity Activities : cuid, managed {
    accountType  : String(20);  // use enum
    activityType : String(20);  // use enum
    customer     : String(30);
    startDate    : Date;
    dueDate      : Date;
    priority     : String(20);   // use enum
    salesAdvisor : String(30);
    status       : String(20);   // use enum

    schedule     : Composition of many Scheduling on schedule.activity = $self;
    attachment   : Composition of many Attachments on attachment.activity = $self;
}



entity Scheduling : cuid {
    activity        : Association to Activities;
    startDate       : Timestamp;
    dueDate         : Timestamp;
    duration        : Integer;
    meetingLocation : String(50);
}


entity Attachments : cuid  {
    activity        : Association to Activities;
    fileName   : String(255);
    fileType   : String(100);
    uploadedBy : String(100);
    uploadedAt : DateTime;
}