sap.ui.define([
    "sap/ui/core/mvc/ControllerExtension",
    "sap/m/MessageToast",
    "sap/m/MessageBox",
    "sap/ui/core/Fragment"
], function (ControllerExtension, MessageToast, MessageBox, Fragment) {
    "use strict";

    return ControllerExtension.extend("com.mycompany.leads.leadmanagement.ext.controller.ListReportExt", {

        onInit: function () {
            console.log("ListReportExt initialized");
        },

        onImportExcel: async function () {
            if (!this._oDialog) {
                this._oDialog = await Fragment.load({
                    name: "com.mycompany.leads.leadmanagement.ext.fragment.UploadExcel",
                    controller: this
                });
                this.base.getView().addDependent(this._oDialog); // ✅ Fix
            }
            this._file = null;
            this._oDialog.open();
        },

        onFileChange: function (oEvent) {
            this._file = oEvent.getParameter("files")[0];
            console.log("File selected:", this._file?.name);
        },

        onUploadExcel: function () {
            if (!this._file) {
                MessageToast.show("Please select an Excel file first");
                return;
            }

            const reader = new FileReader();

            reader.onload = async (e) => {
                const base64 = e.target.result; // full base64 with prefix

                try {
                    const response = await fetch("/odata/v4/LeadService/UploadExcel", {
                        method: "POST",
                        headers: { "Content-Type": "application/json" },
                        body: JSON.stringify({ file: base64 })
                    });

                    if (!response.ok) {
                        const errText = await response.text();
                        console.error("Server error:", errText);
                        MessageBox.error("Upload failed:\n" + errText);
                        return;
                    }

                    const result = await response.json();
                    const data = result.value ?? result;

                    MessageToast.show(
                        `Imported: ${data.imported}, Skipped: ${data.skipped}`
                    );

                    this._oDialog.close();

                    // ✅ Fix
                    this.base.getView().getModel().refresh();

                } catch (err) {
                    console.error("Fetch error:", err);
                    MessageBox.error("Upload failed: " + err.message);
                }
            };

            reader.readAsDataURL(this._file);
        },

        onCloseDialog: function () {
            this._oDialog.close();
        },

    });
});