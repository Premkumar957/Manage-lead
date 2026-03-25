sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"com/mycompany/salesoffer/salesoffer/test/integration/pages/SalesOffersList",
	"com/mycompany/salesoffer/salesoffer/test/integration/pages/SalesOffersObjectPage"
], function (JourneyRunner, SalesOffersList, SalesOffersObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('com/mycompany/salesoffer/salesoffer') + '/test/flpSandbox.html#commycompanysalesoffersalesoff-tile',
        pages: {
			onTheSalesOffersList: SalesOffersList,
			onTheSalesOffersObjectPage: SalesOffersObjectPage
        },
        async: true
    });

    return runner;
});

