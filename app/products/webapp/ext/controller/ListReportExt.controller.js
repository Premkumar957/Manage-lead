sap.ui.define([
	'sap/ui/core/mvc/ControllerExtension',
	'sap/m/MessageToast'
], function (ControllerExtension, MessageToast) {
	'use strict';

	return ControllerExtension.extend('com.products.products.ext.controller.ListReportExt', {
		// this section allows to extend lifecycle hooks or hooks provided by Fiori elements
		override: {
			/**
             * Called when a controller is instantiated and its View controls (if available) are already created.
             * Can be used to modify the View before it is displayed, to bind event handlers and do other one-time initialization.
             * @memberOf com.products.products.ext.controller.ListReportExt
             */
			onInit: function () {
				// you can access the Fiori elements extensionAPI via this.base.getExtensionAPI
				var oModel = this.base.getExtensionAPI().getModel();
				MessageToast.show("onInit method called");
			},
			onBeforeRendering: function () {
				MessageToast.show("onBeforeRendering method called");
			},
			onAfterRendering: function () {
				MessageToast.show("onAfterRendering method called");
			},
			onExit: function () {
				MessageToast.show("onexit method called");
			},
			
		}
	});
});
