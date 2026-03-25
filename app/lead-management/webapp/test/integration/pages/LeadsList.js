sap.ui.define(['sap/fe/test/ListReport'], function(ListReport) {
    'use strict';

    var CustomPageDefinitions = {
        actions: {},
        assertions: {}
    };

    return new ListReport(
        {
            appId: 'com.mycompany.leads.leadmanagement',
            componentId: 'LeadsList',
            contextPath: '/Leads'
        },
        CustomPageDefinitions
    );
});