namespace com.mycompany.leads;

using { cuid, managed } from '@sap/cds/common';


entity SalesOffers : cuid, managed {
    leadNo : String(20);
    project : String;
    expectedDate : Date;
    property : String(255);
    customer : String(50);

    items : Composition of many SalesOfferItems on items.offer = $self;
    notes : Composition of many SalesOfferNotes on notes.offer = $self;
}


entity SalesOfferItems : cuid, managed {
    offer      : Association to SalesOffers;   // 🔗 parent link
    unitType   : String(50);                  // Flat / Villa / Plot
    area       : Decimal(10,2);               // sqft
    price      : Decimal(15,2);
    currency   : String(3);                   // INR, USD
}



entity SalesOfferNotes : cuid, managed {
    offer    : Association to SalesOffers;   // 🔗 parent link
    note     : String(1000);
    noteBy   : String(100);
    noteDate : DateTime;
}