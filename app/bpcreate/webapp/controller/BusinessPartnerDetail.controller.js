sap.ui.define([
    "sap/ui/core/mvc/Controller"
], function (Controller) {
    "use strict";

    return Controller.extend("com.inflexion.businesspartner.bpcreate.controller.BusinessPartnerDetail", {

        onInit: function () {
            const oRouter = this.getOwnerComponent().getRouter();
            oRouter.getRoute("BusinessPartnerDetail").attachPatternMatched(this._onObjectMatched, this);
        },

        _onObjectMatched: function (oEvent) {
            const bpId = oEvent.getParameter("arguments").bpId;

            this.getView().bindElement({
                path: "/BusinessPartners('" + bpId + "')"
            });
        }

    });
});