namespace kodoo.UKBanking;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Payment;
using Microsoft.Bank.Setup;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Foundation.Company;

codeunit 70500 "Bank Export Rules"
{
    #region xmlport triggers
    procedure SetExportFormat(var GenJnlLine: Record "Gen. Journal Line")
    var
        GenJnlLine2: Record "Gen. Journal Line";
        GenJnlBatch: Record "Gen. Journal Batch";
        BankExpImpSetup: Record "Bank Export/Import Setup";
    begin
        GenJnlLine2.CopyFilters(GenJnlLine);
        GenJnlLine2.FindFirst();
        GenJnlBatch.get(GenJnlLine2."Journal Template Name", GenJnlLine2."Journal Batch Name");
        this.PaymentFileType := GenJnlBatch."Payment File Type";
        this.BankAccount.Get(GenJnlLine2."Bal. Account No.");
        BankExpImpSetup.Get(BankAccount."Payment Export Format");
        this.BankFormat := BankExpImpSetup."UK Bank File Format";
    end;

    procedure SuppressChargeBearer(): Boolean
    begin
        exit(BankFormat in [BankFormat::Lloyds, BankFormat::HSBCcsv, BankFormat::HSBCSXML]);
    end;

    procedure SuppressLocalInstrument(): Boolean
    begin
        exit(BankFormat <> BankFormat::Lloyds);
    end;

    procedure SuppressBICIBAN(): Boolean
    begin
        exit(this.PaymentFileType = enum::"Payment File Type"::BACS);
    end;

    procedure SuppressSortCodeAccountNo(): Boolean
    begin
        exit(this.PaymentFileType <> enum::"Payment File Type"::BACS);
    end;

    procedure OrganisationID(): Text[20]
    var
        CompanyInfo: Record "Company Information";
    begin
        if this.BankAccount."Organisation ID" = '' then begin
            CompanyInfo.get();
            exit(CompanyInfo."VAT Registration No.");
        end else
            exit(this.BankAccount."Organisation ID");
    end;

    procedure ServiceUserNumber(): code[6]
    begin
        exit(this.BankAccount."BACS Id");
    end;

    procedure SuppressCdtTrfTxInfPmtTpInf(): Boolean
    begin
        exit(BankFormat <> BankFormat::HSBCSXML);
    end;

    procedure GetDbtrAcctOthrId(paymentexportdatagroup: Record "Payment Export Data"): Text
    begin
        case this.BankFormat of
            this.BankFormat::Lloyds:
                exit(StrSubstNo('%1-%2', paymentexportdatagroup."Sender Bank Branch No.", paymentexportdatagroup."Sender Bank Account No."));
            this.BankFormat::HSBCcsv:
                exit(paymentexportdatagroup."Sender Bank Account No.");
            this.BankFormat::HSBCSXML:
                if paymentexportdatagroup."Service Level" = Enum::"Payment Service Level"::NURG then
                    exit(paymentexportdatagroup."Sender Bank Account No.")  //only return bank account for uk payments
                else
                    exit('');
            else
                exit('');
        end;
    end;

    procedure GetServiceLevelCode(paymentexportdatagroup: Record "Payment Export Data"): code[10]
    begin
        case BankFormat of
            BankFormat::Lloyds, BankFormat::HSBCSXML:
                exit(Format(paymentexportdatagroup."Service Level"));
            else
                exit('NURG');
        end;
    end;

    procedure AdjustCompanyInfo(var CompanyInfo: Record "Company Information")
    begin
        case BankFormat of
            BankFormat::HSBCcsv:
                CompanyInfo.Name := Format(CompanyInfo, -18);  //truncate company name
        end;
        OnAfterAdjustCompanyInfo(CompanyInfo);
    end;

    procedure AdjustPaymentBuffer(var PaymentExportData: Record "Payment Export Data")
    begin
        if PaymentExportData."Recipient Bank Branch No." <> '' then
            PaymentExportData."Recipient Bank Branch No." := FormatSortCodeAsNumeric(PaymentExportData."Recipient Bank Branch No.");
        if PaymentExportData."Sender Bank Branch No." <> '' then
            PaymentExportData."Sender Bank Branch No." := FormatSortCodeAsNumeric(PaymentExportData."Sender Bank Branch No.");
        if PaymentExportData."Sender IBAN" <> '' then
            PaymentExportData."Sender IBAN" := DelChr(PaymentExportData."Sender IBAN", '=');
        if PaymentExportData."Recipient IBAN" <> '' then
            PaymentExportData."Recipient IBAN" := DelChr(PaymentExportData."Recipient IBAN", '=');
    end;

    procedure FormatSortCodeAsNumeric(BranchNo: Text) SortCode: Code[6]
    var
        i: Integer;
        TempCode: Text[20];
        IncorrectSortCodeErr: Label '%1 is not a valid sort code. Sort codes must contain exactly 6 numeric characters.', Comment = '%1 = Bank Branch No.';
    begin
        for i := 1 to StrLen(BranchNo) do
            if BranchNo[i] in [48 .. 57] then
                TempCode := TempCode + BranchNo[i];

        if StrLen(TempCode) <> 6 then
            Error(IncorrectSortCodeErr, BranchNo);

        SortCode := Format(TempCode, 6);
    end;
    #endregion




    #region UKBankType
    procedure UKBankType(GenJnlLine: Record "Gen. Journal Line"): Enum "UK Bank File Format"
    var
        NewBankAccount: Record "Bank Account";
    begin
        NewBankAccount.Get(GenJnlLine."Bal. Account No.");
        exit(UKBankType(NewBankAccount));
    end;

    procedure UKBankType(PaymentExportData: Record "Payment Export Data"): Enum "UK Bank File Format"
    var
        NewBankAccount: Record "Bank Account";
    begin
        NewBankAccount.Get(PaymentExportData."Sender Bank Account Code");
        exit(UKBankType(NewBankAccount));
    end;

    procedure UKBankType(NewBankAccount: Record "Bank Account"): Enum "UK Bank File Format"
    var
        BankExpImpSetup: Record "Bank Export/Import Setup";
    begin
        BankExpImpSetup.Get(NewBankAccount."Payment Export Format");
        exit(BankExpImpSetup."UK Bank File Format");
    end;
    #endregion



    var
        BankAccount: Record "Bank Account";
        BankFormat: Enum "UK Bank File Format";
        PaymentFileType: Enum "Payment File Type";

    [IntegrationEvent(true, false)]
    local procedure OnAfterAdjustCompanyInfo(var CompanyInfo: Record "Company Information")
    begin
    end;
}
