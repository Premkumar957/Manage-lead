sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"customer/managelead/businesspartners/test/integration/pages/BusinessPartnersList",
	"customer/managelead/businesspartners/test/integration/pages/BusinessPartnersObjectPage"
], function (JourneyRunner, BusinessPartnersList, BusinessPartnersObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('customer/managelead/businesspartners') + '/test/flpSandbox.html#customermanageleadbusinesspart-tile',
        pages: {
			onTheBusinessPartnersList: BusinessPartnersList,
			onTheBusinessPartnersObjectPage: BusinessPartnersObjectPage
        },
        async: true
    });

    return runner;
});

