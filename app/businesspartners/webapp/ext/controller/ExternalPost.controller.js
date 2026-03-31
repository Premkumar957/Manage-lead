sap.ui.define([
    "sap/ui/core/mvc/ControllerExtension",
    "sap/m/MessageToast",
    "sap/m/MessageBox",
    "sap/ui/model/json/JSONModel",
    "sap/ui/core/Fragment"
], function (ControllerExtension, MessageToast, MessageBox, JSONModel, Fragment) {
    "use strict";

    return ControllerExtension.extend("customer.managelead.businesspartners.ext.controller.ExternalPost", {

        // 🔥 Custom button handler
        onPostExternal: async function () {
            MessageToast.show("create method invoked");

            const oView = this.base.getView(); // ✅ correct way

            // Create local model for fragment
            const oLocalModel = new JSONModel({
                BusinessPartnerFullName: "",
                BusinessPartnerCategory: "2",
                BusinessPartnerGrouping: "",
                Industry: "",
                Customer: false,
                Supplier: false,
                BusinessPartnerIsBlocked: false,
                IsMarkedForArchiving: false
            });

            oView.setModel(oLocalModel, "localModel");

            // Load fragment
            if (!this._oDialog) {
                this._oDialog = await Fragment.load({
                    name: "customer.managelead.businesspartners.ext.fragment.CreateBusinessPartner",
                    controller: this
                });
                oView.addDependent(this._oDialog);
            }

            this._oDialog.open();
        },

        // 🔥 Create button inside fragment
        onCreateBP: async function () {

            const oView = this.base.getView();
            const oData = oView.getModel("localModel").getData();
            const oModel = oView.getModel(); // OData V4 model

            if (!oModel) {
                MessageBox.error("OData model not found");
                return;
            }

            try {
                const oAction = oModel.bindContext("/createBusinessPartner(...)");

                oAction.setParameter("BusinessPartnerFullName", oData.BusinessPartnerFullName);
                oAction.setParameter("BusinessPartnerCategory", oData.BusinessPartnerCategory);
                oAction.setParameter("BusinessPartnerGrouping", oData.BusinessPartnerGrouping);
                oAction.setParameter("Industry", oData.Industry);
                oAction.setParameter("Customer", oData.Customer);
                oAction.setParameter("Supplier", oData.Supplier);
                oAction.setParameter("BusinessPartnerIsBlocked", oData.BusinessPartnerIsBlocked);
                oAction.setParameter("IsMarkedForArchiving", oData.IsMarkedForArchiving);

                await oAction.execute();

                MessageToast.show("Business Partner created successfully");
                this._oDialog.close();

                // refresh list
                oView.getModel().refresh();

            } catch (e) {
                MessageBox.error("Creation failed: " + e.message);
            }
        },

        // 🔥 Cancel button
        onCancel: function () {
            this._oDialog.close();
        }

    });
});