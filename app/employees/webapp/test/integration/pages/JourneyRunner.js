sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"com/mycompany/employees/test/integration/pages/EmployeesList",
	"com/mycompany/employees/test/integration/pages/EmployeesObjectPage"
], function (JourneyRunner, EmployeesList, EmployeesObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('com/mycompany/employees') + '/test/flpSandbox.html#commycompanyemployees-tile',
        pages: {
			onTheEmployeesList: EmployeesList,
			onTheEmployeesObjectPage: EmployeesObjectPage
        },
        async: true
    });

    return runner;
});

