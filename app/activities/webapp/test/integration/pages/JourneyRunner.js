sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"com/mycompany/activities/activities/test/integration/pages/ActivitiesList",
	"com/mycompany/activities/activities/test/integration/pages/ActivitiesObjectPage"
], function (JourneyRunner, ActivitiesList, ActivitiesObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('com/mycompany/activities/activities') + '/test/flpSandbox.html#commycompanyactivitiesactiviti-tile',
        pages: {
			onTheActivitiesList: ActivitiesList,
			onTheActivitiesObjectPage: ActivitiesObjectPage
        },
        async: true
    });

    return runner;
});

