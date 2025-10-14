namespace kodoo.UKBanking;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Bank.Payment;
using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Setup;
using Microsoft.Foundation.Company;

codeunit 70500 "Bank Export Rules"
{
    #region xmlport triggers
    procedure SetExportFormat(var GenJnlLine: Record "Gen. Journal Line")
    var
        GenJnlLine2: Record "Gen. Journal Line";
        BankAccount: Record "Bank Account";
        BankExpImpSetup: Record "Bank Export/Import Setup";
    begin
        GenJnlLine2.CopyFilters(GenJnlLine);
        GenJnlLine2.FindFirst();
        BankAccount.Get(GenJnlLine2."Bal. Account No.");
        BankExpImpSetup.Get(BankAccount."Payment Export Format");
        BankFormat := BankExpImpSetup."UK Bank File Format";
    end;

    procedure SuppressChargeBearer(): Boolean
    begin
        exit(BankFormat in [BankFormat::Lloyds, BankFormat::HSBCcsv, BankFormat::HSBCSXML]);
    end;

    procedure SupressIBAN(): Boolean
    begin
        exit(BankFormat in [BankFormat::Lloyds]);
    end;

    procedure SuppressLocalInstrument(): Boolean
    begin
        exit(BankFormat <> BankFormat::Lloyds);
    end;

    procedure SuppressCdtTrfTxInfPmtTpInf(): Boolean
    begin
        exit(BankFormat <> BankFormat::HSBCSXML);
    end;

    procedure GetdbtracctOthrId(paymentexportdatagroup: Record "Payment Export Data"): Text
    begin
        case BankFormat of
            BankFormat::Lloyds:
                exit(StrSubstNo('%1-%2', paymentexportdatagroup."Sender Bank Branch No.", paymentexportdatagroup."Sender Bank Account No."));
            BankFormat::HSBCcsv:
                exit(paymentexportdatagroup."Sender Bank Account No.");
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
        BankAccount: Record "Bank Account";
    begin
        BankAccount.Get(GenJnlLine."Bal. Account No.");
        exit(UKBankType(BankAccount));
    end;

    procedure UKBankType(PaymentExportData: Record "Payment Export Data"): Enum "UK Bank File Format"
    var
        BankAccount: Record "Bank Account";
    begin
        BankAccount.Get(PaymentExportData."Sender Bank Account Code");
        exit(UKBankType(BankAccount));
    end;

    procedure UKBankType(BankAccount: Record "Bank Account"): Enum "UK Bank File Format"
    var
        BankExpImpSetup: Record "Bank Export/Import Setup";
    begin
        BankExpImpSetup.Get(BankAccount."Payment Export Format");
        exit(BankExpImpSetup."UK Bank File Format");
    end;
    #endregion



    var
        BankFormat: Enum "UK Bank File Format";

    [IntegrationEvent(true, false)]
    local procedure OnAfterAdjustCompanyInfo(var CompanyInfo: Record "Company Information")
    begin
    end;
}
