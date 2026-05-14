namespace com.mycompany;

using { cuid, managed } from '@sap/cds/common';


entity Employees :cuid, managed {
    firstName   : String(50);
    lastName    : String(30);
    email       : String(100);
    department  : String(50);
    phoneNumber : String(10);
    salary      : Decimal(15, 2);
}