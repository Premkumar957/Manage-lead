sap.ui.define([
	'sap/ui/core/mvc/ControllerExtension',
	'sap/m/MessageToast',
	"sap/ui/core/Fragment"
], function (ControllerExtension, MessageToast, Fragment) {
	'use strict';

	return ControllerExtension.extend('com.mycompany.leads.leadmanagement.ext.controller.ObjectPageExt', {
		// this section allows to extend lifecycle hooks or hooks provided by Fiori elements
		override: {
			/**
			 * Called when a controller is instantiated and its View controls (if available) are already created.
			 * Can be used to modify the View before it is displayed, to bind event handlers and do other one-time initialization.
			 * @memberOf com.mycompany.leads.leadmanagement.ext.controller.ObjectPageExt
			 */
			onInit: function () {
				// you can access the Fiori elements extensionAPI via this.base.getExtensionAPI
				var oModel = this.base.getExtensionAPI().getModel();
			}

		},

		onOpenDialog: async function () {
			if (!this._oDialog) {
				this._oDialog = await Fragment.load({
					name: "com.mycompany.leads.leadmanagement.ext.fragment.OpenAndClose",
					controller: this
				});
				this.base.getView().addDependent(this._oDialog); // ✅ Fix
			}
			this._file = null;
			this._oDialog.open();
		},

		onUploadDialogInput: function () {
			alert("Become the programmer you are meant to be!");
			MessageToast.show("onUploadDialogInput Method triggered!!!");
		},

		onCloseDialogInput: function () {
			MessageToast.show("onCloseDialogInput Method triggered!!!");
			this._oDialog.close();
		}
	});
});
