sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"com/mycompany/leads/leadmanagement/test/integration/pages/LeadsList",
	"com/mycompany/leads/leadmanagement/test/integration/pages/LeadsObjectPage"
], function (JourneyRunner, LeadsList, LeadsObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('com/mycompany/leads/leadmanagement') + '/test/flpSandbox.html#commycompanyleadsleadmanagemen-tile',
        pages: {
			onTheLeadsList: LeadsList,
			onTheLeadsObjectPage: LeadsObjectPage
        },
        async: true
    });

    return runner;
});

