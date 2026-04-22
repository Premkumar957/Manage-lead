sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/model/json/JSONModel",
    "sap/ui/model/Filter",
    "sap/ui/model/FilterOperator",
    "sap/ui/model/Sorter"
], (Controller, JSONModel, Filter, FilterOperator, Sorter) => {
    "use strict";

    return Controller.extend("com.inflexion.businesspartner.bpcreate.controller.ManageBusinessPartner", {

        onInit() {
            const oModel = new JSONModel({
                BusinessPartner: "",
                BusinessPartnerFullName: "",
                BusinessPartnerCategory: "",
                BusinessPartnerGrouping: "",
                BusinessPartnerIsBlocked: "",
                FirstName: ""
            });

            this.getView().setModel(oModel, "filterModel");

            const oCountModel = new JSONModel({
                count: 0
            });

            this.getView().setModel(oCountModel, "countModel");

            const oRouter = this.getOwnerComponent().getRouter();
            oRouter.getRoute("RouteManageBusinessPartner")
                .attachPatternMatched(this._onRouteMatched, this)

            // sorting toggle flag
            this._bDescending = false;
        },

        _onRouteMatched() {

            const oTable = this.byId("bpTable");

            if (oTable) {
                const oBinding = oTable.getBinding("items");

                if (oBinding) {
                    oBinding.refresh(); // 🔥 THIS reloads data
                }
            }
        },

        onAfterRendering() {
            const oTable = this.byId("bpTable");
            const oBinding = oTable.getBinding("items");

            if (oBinding) {

                oBinding.attachChange(async () => {

                    try {
                        // 🔥 THIS is correct for OData V4
                        const iCount = await oBinding.requestLength();

                        this.getView()
                            .getModel("countModel")
                            .setProperty("/count", iCount);

                    } catch (e) {
                        console.error("Count fetch failed", e);
                    }

                });
            }
        },

         // ================= FILTER =================
        onSearch() {
            const oView = this.getView();
            const oData = oView.getModel("filterModel").getData();
            const aFilters = [];

            const addFilter = (field, value, operator = FilterOperator.Contains) => {
                if (value !== "" && value !== null && value !== undefined) {
                    aFilters.push(new Filter(field, operator, value));
                }
            };

            addFilter("BusinessPartner", oData.BusinessPartner);
            addFilter("BusinessPartnerFullName", oData.BusinessPartnerFullName);
            addFilter("BusinessPartnerCategory", oData.BusinessPartnerCategory, FilterOperator.EQ);
            addFilter("BusinessPartnerGrouping", oData.BusinessPartnerGrouping);
            addFilter("FirstName", oData.FirstName);

            // Boolean handling
            if (oData.BusinessPartnerIsBlocked !== "") {
                aFilters.push(new Filter(
                    "BusinessPartnerIsBlocked",
                    FilterOperator.EQ,
                    oData.BusinessPartnerIsBlocked === "true"
                ));
            }

            const oTable = oView.byId("bpTable");

            if (oTable && oTable.getBinding("items")) {
                oTable.getBinding("items").filter(aFilters);
            }
        },

        // ================= SORT =================
        handleSortButtonPressed() {
            const oTable = this.byId("bpTable");
            const oBinding = oTable.getBinding("items");

            this._bDescending = !this._bDescending;

            const oSorter = new Sorter(
                "BusinessPartnerFullName",
                this._bDescending
            );

            oBinding.sort(oSorter);
        },

        // ================= REFRESH =================
        onPressRefresh() {
            const oTable = this.byId("bpTable");

            if (oTable && oTable.getBinding("items")) {
                oTable.getBinding("items").refresh();
            }
        },

        // ================= PERSONALIZATION =================
        handlePersoButtonPressed() {

            if (!this._oDialog) {
                this._oDialog = new sap.m.Dialog({
                    title: "Select Columns",
                    content: [
                        new sap.m.CheckBox({
                            text: "BusinessPartner",
                            selected: true,
                            select: (e) => this._toggleColumn(0, e.getParameter("selected"))
                        }),
                        new sap.m.CheckBox({
                            text: "Full Name",
                            selected: true,
                            select: (e) => this._toggleColumn(1, e.getParameter("selected"))
                        }),
                        new sap.m.CheckBox({
                            text: "Category",
                            selected: true,
                            select: (e) => this._toggleColumn(2, e.getParameter("selected"))
                        }),
                        new sap.m.CheckBox({
                            text: "Grouping",
                            selected: true,
                            select: (e) => this._toggleColumn(3, e.getParameter("selected"))
                        }),
                        new sap.m.CheckBox({
                            text: "Blocked",
                            selected: true,
                            select: (e) => this._toggleColumn(4, e.getParameter("selected"))
                        })
                    ],
                    endButton: new sap.m.Button({
                        text: "Close",
                        press: () => this._oDialog.close()
                    })
                });
            }

            this._oDialog.open();
        },

        _toggleColumn(index, visible) {
            const oTable = this.byId("bpTable");
            const aColumns = oTable.getColumns();

            if (aColumns[index]) {
                aColumns[index].setVisible(visible);
            }
        },

        // ================= EXPORT =================
        onPressExport() {
            const oTable = this.byId("bpTable");
            const aItems = oTable.getItems();

            let csv = "BP ID,Full Name,Category,Grouping,Blocked\n";

            aItems.forEach(item => {
                const cells = item.getCells();
                csv += `${cells[0].getText()},${cells[1].getText()},${cells[2].getText()},${cells[3].getText()},${cells[4].getText()}\n`;
            });

            const blob = new Blob([csv], { type: "text/csv" });
            const url = URL.createObjectURL(blob);

            const a = document.createElement("a");
            a.href = url;
            a.download = "BusinessPartners.csv";
            a.click();
        },

        onCreateBP() {
            this.getOwnerComponent().getRouter().navTo("CreateBP");
        },

        onListItemPress: function (oEvent) {

            const oItem = oEvent.getSource();
            const oContext = oItem.getBindingContext();

            const bpId = oContext.getProperty("BusinessPartner");

            this.getOwnerComponent().getRouter().navTo("BusinessPartnerDetail", {
                bpId: bpId
            });
        },


        onCreatePress: function () {
            this.getOwnerComponent().getRouter().navTo("CreateBusinessPartner", {});
        }

    });
});