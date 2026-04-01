sap.ui.define([
    "sap/ui/core/mvc/ControllerExtension",
    "sap/m/MessageToast",
    "sap/m/MessageBox",
    "sap/ui/model/json/JSONModel",
    "sap/ui/core/Fragment"
], function (ControllerExtension, MessageToast, MessageBox, JSONModel, Fragment) {
    "use strict";

    return ControllerExtension.extend("customer.managelead.businesspartners.ext.controller.ExternalPost", {

        onPostExternal: async function () {
            const oView = this.base.getView();

            if (!this._oDialog) {
                this._oDialog = await Fragment.load({
                    id: oView.getId(),
                    name: "customer.managelead.businesspartners.ext.fragment.CreateBusinessPartner",
                    controller: this
                });
                oView.addDependent(this._oDialog);
            }

            // ✅ Reset model fresh every time dialog opens
            const oLocalModel = new JSONModel({
                BusinessPartnerCategory: "1",
                BusinessPartnerGrouping: "",
                CorrespondenceLanguage: "EN",
                FirstName: "",
                LastName: "",
                OrganizationBPName1: "",
                GroupBusinessPartnerName1: ""
            });

            oLocalModel.setDefaultBindingMode("TwoWay");
            oView.setModel(oLocalModel, "localModel");

            this._oDialog.open();
        },

        onCreateBP: async function () {
            const oView = this.base.getView();
            const oLocalModel = oView.getModel("localModel");
            const oModel = oView.getModel();

            const oData = {
                BusinessPartnerCategory:   oLocalModel.getProperty("/BusinessPartnerCategory"),
                BusinessPartnerGrouping:   oLocalModel.getProperty("/BusinessPartnerGrouping"),
                FirstName:                 oLocalModel.getProperty("/FirstName"),
                LastName:                  oLocalModel.getProperty("/LastName"),
                OrganizationBPName1:       oLocalModel.getProperty("/OrganizationBPName1"),
                GroupBusinessPartnerName1: oLocalModel.getProperty("/GroupBusinessPartnerName1"),
                CorrespondenceLanguage:    oLocalModel.getProperty("/CorrespondenceLanguage")
            };

            console.log("FINAL DATA:", oData);

            // Validation
            if (!oData.BusinessPartnerGrouping) {
                MessageBox.error("Grouping is required");
                return;
            }

            let payload = {
                BusinessPartnerCategory: oData.BusinessPartnerCategory,
                BusinessPartnerGrouping: oData.BusinessPartnerGrouping,
                CorrespondenceLanguage:  oData.CorrespondenceLanguage
            };

            if (oData.BusinessPartnerCategory === "1") {
                if (!oData.FirstName || !oData.LastName) {
                    MessageBox.error("First Name and Last Name are required");
                    return;
                }
                payload.FirstName = oData.FirstName;
                payload.LastName  = oData.LastName;
            }

            if (oData.BusinessPartnerCategory === "2") {
                if (!oData.OrganizationBPName1) {
                    MessageBox.error("Organization Name is required");
                    return;
                }
                payload.OrganizationBPName1 = oData.OrganizationBPName1;
            }

            if (oData.BusinessPartnerCategory === "3") {
                if (!oData.GroupBusinessPartnerName1) {
                    MessageBox.error("Group Name is required");
                    return;
                }
                payload.GroupBusinessPartnerName1 = oData.GroupBusinessPartnerName1;
            }

            try {
                const oAction = oModel.bindContext("/createBusinessPartner(...)");

                Object.keys(payload).forEach(k => {
                    oAction.setParameter(k, payload[k]);
                });

                await oAction.execute();

                // ✅ Success
                MessageToast.show("Business Partner created successfully!");
                this._oDialog.close();
                oModel.refresh();

            } catch (e) {
                // ✅ FIXED: S/4HANA may return a "false failure" when BP is actually created.
                // Check if the error message contains PartnerGUID — if so, treat as success.
                const sMsg = e.message || "";
                if (sMsg.includes("PartnerGUID")) {
                    MessageToast.show("Business Partner created successfully!");
                    this._oDialog.close();
                    oModel.refresh();
                } else {
                    MessageBox.error("Creation failed: " + sMsg);
                }
            }
        },

        onCancel: function () {
            this._oDialog.close();
        }
    });
});