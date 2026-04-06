namespace com.mycompany.leads;

using { cuid, managed } from '@sap/cds/common';


entity SalesOffers : cuid, managed {
    leadNo : String(20) @mandatory @title : 'Lead No';
    project : String @mandatory @title : 'Project';
    expectedDate : Date @title : 'Expected Date';
    property : String(255) @title : 'Property';
    customer : String(50) @mandatory @title : 'Customer';

    items : Composition of many SalesOfferItems on items.offer = $self;
    notes : Composition of many SalesOfferNotes on notes.offer = $self;
}


entity SalesOfferItems : cuid, managed {
    offer      : Association to SalesOffers;   // 🔗 parent link
    unitType   : String(50) @mandatory @title : 'Unit Type';                  // Flat / Villa / Plot
    area       : Decimal(10,2) @mandatory @title : 'Area';               // sqft
    price      : Decimal(15,2) @mandatory @title : 'Price';
    currency   : String(3) @mandatory @title : 'Currency';                   // INR, USD
}



entity SalesOfferNotes : cuid, managed {
    offer    : Association to SalesOffers;   // 🔗 parent link
    note     : String(1000);
    noteBy   : String(100);
    noteDate : DateTime;
}