report 50110 "Commande Achat"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;

    // Use an RDL layout.
    DefaultLayout = RDLC;

    // Specify the name of the file that the report will use for the layout.
    RDLCLayout = 'CommandeAchat.rdl';

    dataset
    {
        dataitem("Purchase Header"; "Purchase Header")
        {
            DataItemTableView = sorting("No.", "Buy-from Vendor No.");
            RequestFilterFields = "No.";
            column(No_; "No.")
            {

            }

            column(Document_Type; "Document Type")
            {

            }




            dataitem("Purchase Line"; "Purchase Line")
            {
                DataItemLink = "No." = field("No.");

                DataItemLinkReference = "Purchase Header";


                column(Line_Amount; "Line Amount")
                {
                    // Include the caption of the "No." field in the dataset of the report.
                    //    IncludeCaption = true;

                }
                column(Line_No_; "Line No.")
                {

                }

                column(Description; Description)
                {

                }
                column(Quantity; Quantity)
                {

                }
                column(Unit_Price__LCY_; "Unit Price (LCY)")
                {

                }
                column(Allow_Invoice_Disc_; "Allow Invoice Disc.")
                {

                }
                column(Line_Discount__; "Line Discount %")
                {

                }








                trigger OnAfterGetRecord()
                begin

                end;

            }

            trigger OnAfterGetRecord()
            begin

                //CurrReport.LANGUAGE := Language.GetLanguageID("Language Code");

                CompanyInfo.GET;

                IF RespCenter.GET("Responsibility Center") THEN BEGIN
                    //FormatAddr.RespCenter(CompanyAddr, RespCenter);
                    CompanyInfo."Phone No." := RespCenter."Phone No.";
                    CompanyInfo."Fax No." := RespCenter."Fax No.";
                END ELSE
                    //FormatAddr.Company(CompanyAddr, CompanyInfo);

                DimSetEntry1.SETRANGE("Dimension Set ID", "Dimension Set ID");

                IF "Purchaser Code" = '' THEN BEGIN
                    SalesPurchPerson.INIT;
                    PurchaserText := '';
                END ELSE BEGIN
                    SalesPurchPerson.GET("Purchaser Code");
                    PurchaserText := Text000
                END;
                IF "Your Reference" = '' THEN
                    ReferenceText := ''
                ELSE
                    ReferenceText := FIELDCAPTION("Your Reference");
                IF "VAT Registration No." = '' THEN
                    VATNoText := ''
                ELSE
                    VATNoText := FIELDCAPTION("VAT Registration No.");
                IF "Currency Code" = '' THEN BEGIN
                    GLSetup.TESTFIELD("LCY Code");
                    TotalText := STRSUBSTNO(Text001, GLSetup."LCY Code");
                    TotalInclVATText := STRSUBSTNO(Text002, GLSetup."LCY Code");
                    TotalExclVATText := STRSUBSTNO(Text006, GLSetup."LCY Code");
                END ELSE BEGIN
                    TotalText := STRSUBSTNO(Text001, "Currency Code");
                    TotalInclVATText := STRSUBSTNO(Text002, "Currency Code");
                    TotalExclVATText := STRSUBSTNO(Text006, "Currency Code");
                END;

                //FormatAddr.PurchHeaderBuyFrom(BuyFromAddr, "Purchase Header");
                IF "Buy-from Vendor No." <> "Pay-to Vendor No." THEN
                    // FormatAddr.PurchHeaderPayTo(VendAddr, "Purchase Header");
                    IF "Payment Terms Code" = '' THEN
                        PaymentTerms.INIT
                    ELSE BEGIN
                        PaymentTerms.GET("Payment Terms Code");
                        PaymentTerms.TranslateDescription(PaymentTerms, "Language Code");
                    END;
                IF "Prepmt. Payment Terms Code" = '' THEN
                    PrepmtPaymentTerms.INIT
                ELSE BEGIN
                    PrepmtPaymentTerms.GET("Prepmt. Payment Terms Code");
                    PrepmtPaymentTerms.TranslateDescription(PrepmtPaymentTerms, "Language Code");
                END;
                IF "Shipment Method Code" = '' THEN
                    ShipmentMethod.INIT
                ELSE BEGIN
                    ShipmentMethod.GET("Shipment Method Code");
                    ShipmentMethod.TranslateDescription(ShipmentMethod, "Language Code");
                END;

                //FormatAddr.PurchHeaderShipTo(ShipToAddr, "Purchase Header");

                IF NOT CurrReport.PREVIEW THEN BEGIN
                    IF ArchiveDocument THEN
                        ArchiveManagement.StorePurchDocument("Purchase Header", LogInteraction);

                    IF LogInteraction THEN BEGIN
                        CALCFIELDS("No. of Archived Versions");
                        SegManagement.LogDocument(
                        13, "No.", "Doc. No. Occurrence", "No. of Archived Versions", DATABASE::Vendor, "Buy-from Vendor No.",
                        "Purchaser Code", '', "Posting Description", '');
                    END;
                END;
                PricesInclVATtxt := FORMAT("Prices Including VAT");

                TextGMnt := '';
                "Purchase Header".CALCFIELDS("Amount Including VAT");
                //CodeU."Montant DEVISE"(TextGMnt, "Purchase Header"."Amount Including VAT", "Purchase Header"."Currency Code");



                ReceiptDateTxt := '';
                //IF FORMAT("Purchase Header"."Heure Début de réception") <> '' THEN
                //    ReceiptDateTxt := STRSUBSTNO(ReceptionDateTxt, "Purchase Header"."Heure Début de réception", "Purchase Header"."Heure Fin de réception");

            end;


        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {

                }
            }
        }

        actions
        {
            area(processing)
            {
                action(ActionName)
                {
                    ApplicationArea = All;

                }
            }
        }
    }



    var

        GLSetup: Record "General Ledger Setup";
        SalesPurchPerson: Record "Sales & Receivables Setup";
        CompanyInfo: Record "Company Information";
        ShipmentMethod: Record "Shipment Method";
        PaymentTerms: Record "Payment Terms";
        PrepmtPaymentTerms: Record "Payment Terms";
        VATAmountLine: Record "VAT Amount Line";
        PrepmtVATAmountLine: Record "VAT Amount Line";
        PrePmtVATAmountLineDeduct: Record "VAT Amount Line";
        PurchLine: Record "Purchase Line";
        DimSetEntry1: Record "Dimension Set Entry";
        DimSetEntry2: Record "Dimension Set Entry";
        PrepmtDimSetEntry: Record "Dimension Set Entry";
        PrepmtInvBuf: Record "Prepayment Inv. Line Buffer";
        RespCenter: Record "Responsibility Center";
        Language: Record "Language";
        CurrExchRate: Record "Currency Exchange Rate";
        PurchSetup: Record "Purchases & Payables Setup";
        RecGCustPosGroup: Record "Customer Posting Group";
        RecGCustomer: Record "Customer";
        RecGSalesInvoiceLine: Record "Purchase Line";

        VendAddr: Text[50];
        ShipToAddr: Text[50];
        CompanyAddr: Text[50];
        BuyFromAddr: Text[50];
        PurchaserText: Text[30];
        VATNoText: Text[80];
        ReferenceText: Text[80];
        TotalText: Text[50];
        TotalInclVATText: Text[50];
        TotalExclVATText: Text[50];
        TextGMnt: Text[300];
        CopyText: Text[30];
        DimText: Text[120];
        OldDimText: Text[75];
        VALSpecLCYHeader: Text[80];
        VALExchRate: Text[50];
        PricesInclVATtxt: Text[30];
        AllowInvDisctxt: Text[30];
        ReceiptDateTxt: Text[250];
        Duplicata: Text[30];

        NoOfCopies: Integer;
        NoOfLoops: Integer;
        OutputNo: Integer;
        IntGCounter: Integer;
        IntGGroup: Integer;

        ShowInternalInfo: Boolean;
        Continue: Boolean;
        ArchiveDocument: Boolean;
        LogInteraction: Boolean;
        ArchiveDocumentEnable: Boolean;
        LogInteractionEnable: Boolean;
        MoreLines: Boolean;

        TotalInvoiceDiscountAmount: Decimal;
        VATAmount: Decimal;
        VATBaseAmount: Decimal;
        VATDiscountAmount: Decimal;
        TotalAmountInclVAT: Decimal;
        VALVATBaseLCY: Decimal;
        VALVATAmountLCY: Decimal;
        PrepmtVATAmount: Decimal;
        PrepmtVATBaseAmount: Decimal;
        PrepmtTotalAmountInclVAT: Decimal;
        PrepmtLineAmount: Decimal;
        TotalSubTotal: Decimal;
        TotalAmount: Decimal;

        PurchCountPrinted: Codeunit "Purch.Header-Printed";
        FormatAddr: Codeunit "Format Address";
        PurchPost: Codeunit "Purch.-Post";
        ArchiveManagement: Codeunit "ArchiveManagement";
        SegManagement: Codeunit "SegManagement";
        PurchPostPrepmt: Codeunit "Purchase-Post Prepayments";






        Text000: Label 'Acheteur';
        Text001: Label 'Total %1';
        Text002: Label 'Total %1 TTC';
        Text003: Label 'COPIE';
        Text004: Label 'Order%1';
        Text005: Label 'Page %1';
        Text006: Label 'Total %1 HT';
        Text007: Label 'Détail TVA dans';
        Text008: Label 'Devise société';
        Text009: Label 'Taux de change : %1/%2';


}