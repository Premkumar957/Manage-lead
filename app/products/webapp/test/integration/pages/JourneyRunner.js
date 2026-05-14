sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"com/products/products/test/integration/pages/ProductsList",
	"com/products/products/test/integration/pages/ProductsObjectPage"
], function (JourneyRunner, ProductsList, ProductsObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('com/products/products') + '/test/flpSandbox.html#comproductsproducts-tile',
        pages: {
			onTheProductsList: ProductsList,
			onTheProductsObjectPage: ProductsObjectPage
        },
        async: true
    });

    return runner;
});

