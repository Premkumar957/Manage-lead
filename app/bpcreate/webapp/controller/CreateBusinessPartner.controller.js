sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/model/json/JSONModel",
    "sap/m/MessageToast"
], function (Controller, JSONModel, MessageToast) {
    "use strict";

    return Controller.extend("com.inflexion.businesspartner.bpcreate.controller.CreateBusinessPartner", {

        onInit() {

            const oModel = new JSONModel({
                BusinessPartnerCategory: "1",
                BusinessPartnerGrouping: "",
                FirstName: "",
                LastName: "",
                OrganizationBPName1: "",
                GroupBusinessPartnerName1: "",
                CorrespondenceLanguage: "EN",
                BusinessPartnerIsBlocked: false,
                IsMarkedForArchiving: false
            });

            this.getView().setModel(oModel, "createModel");
        },

        // ✅ VALIDATION
        _validate: function () {

            const oData = this.getView().getModel("createModel").getData();
            let isValid = true;

            const check = (id, value) => {
                const field = this.byId(id);

                if (!field || (field.getVisible && !field.getVisible())) return;

                if (!value) {
                    field.setValueState("Error");
                    field.setValueStateText("This field is required");
                    isValid = false;
                } else {
                    field.setValueState("None");
                }
            };

            check("categorySelect", oData.BusinessPartnerCategory);
            check("groupingInput", oData.BusinessPartnerGrouping);

            if (oData.BusinessPartnerCategory === "1") {
                check("firstNameInput", oData.FirstName);
                check("lastNameInput", oData.LastName);
            }

            if (oData.BusinessPartnerCategory === "2") {
                check("orgNameInput", oData.OrganizationBPName1);
            }

            if (oData.BusinessPartnerCategory === "3") {
                check("groupNameInput", oData.GroupBusinessPartnerName1);
            }

            return isValid;
        },

        // 🔥 CREATE
       onCreate: async function () {

        if (!this._validate()) {
            sap.m.MessageToast.show("Please fill all required fields");
            return;
        }

        const oData = this.getView().getModel("createModel").getData();

        try {

            // ✅ CLEAN PAYLOAD (MATCH BACKEND)
            let payload = {
                BusinessPartnerCategory: oData.BusinessPartnerCategory,
                BusinessPartnerGrouping: oData.BusinessPartnerGrouping,
                CorrespondenceLanguage: oData.CorrespondenceLanguage
            };

            // ✅ CATEGORY LOGIC
            if (oData.BusinessPartnerCategory === "1") {
                payload.FirstName = oData.FirstName;
                payload.LastName = oData.LastName;
            } 
            else if (oData.BusinessPartnerCategory === "2") {
                payload.OrganizationBPName1 = oData.OrganizationBPName1;
            } 
            else if (oData.BusinessPartnerCategory === "3") {
                payload.GroupBusinessPartnerName1 = oData.GroupBusinessPartnerName1;
            }

     
            payload.BusinessPartnerIsBlocked = oData.BusinessPartnerIsBlocked;
            payload.IsMarkedForArchiving = oData.IsMarkedForArchiving;

            console.log("Final Payload:", payload);

            // ✅ DIRECT ENTITY CALL
            const response = await fetch("/odata/v4/ExternalService/BusinessPartners", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify(payload)
            });

            if (!response.ok) {
                const errText = await response.text();
                throw new Error(errText);
            }

            const result = await response.json();
            console.log("Response:", result);

            // ✅ CLEAN NAVIGATION FLOW
            sap.m.MessageToast.show("Business Partner Created", {
                onClose: () => {
                    this.getOwnerComponent()
                        .getRouter()
                        .navTo("RouteManageBusinessPartner");
                }
            });

        } catch (error) {
            console.error(error);
            sap.m.MessageToast.show(error.message || "Creation Failed");
        }
    },

        onCancel() {
            this.getOwnerComponent().getRouter().navTo("RouteManageBusinessPartner");
        }

    });
});