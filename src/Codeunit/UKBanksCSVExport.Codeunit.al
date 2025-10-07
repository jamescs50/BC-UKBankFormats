namespace kodoo.UKBanking;

using Microsoft.Bank.DirectDebit;
using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Payment;
using Microsoft.Finance.GeneralLedger.Journal;
using System.IO;
using System.Utilities;
using Microsoft.Foundation.Company;
using System.Text;
using Microsoft.Bank.Setup;
codeunit 70503 "UK Text Export Formats"
{

    #region code copied and modified from CU1220
    Permissions = TableData "Data Exch. Field" = rimd;
    TableNo = "Gen. Journal Line";

    trigger OnRun()
    var
        BankAccount: Record "Bank Account";
        BankExport: Record "Bank Export/Import Setup";
        ExpUserFeedbackGenJnl: Codeunit "Exp. User Feedback Gen. Jnl.";
    begin
        Rec.LockTable();
        BankAccount.Get(Rec."Bal. Account No.");
        BankAccount.GetBankExportImportSetup(BankExport);
        if Export(Rec, BankExport) then
            ExpUserFeedbackGenJnl.SetExportFlagOnGenJnlLine(Rec);
    end;

    var
        ExportToServerFile: Boolean;
        FeatureNameTxt: label 'SEPA Credit Transfer Export', locked = true;

    internal procedure FeatureName(): Text
    begin
        exit(FeatureNameTxt)
    end;

    procedure Export(var GenJnlLine: Record "Gen. Journal Line"; BankExport: Record "Bank Export/Import Setup") Result: Boolean
    var
        CreditTransferRegister: Record "Credit Transfer Register";
        TempPaymentExport: Record "Payment Export Data" temporary;
        TempBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
        SEPACTFillExportBuffer: Codeunit "SEPA CT-Fill Export Buffer";
        OutStr: OutStream;
        UseCommonDialog: Boolean;
        FileCreated: Boolean;
        IsHandled: Boolean;
        FileNameTemplate: Text;
        CSVFileTok: Label '%1.CSV', Comment = '%1 is the file name';
        TxtFileTok: Label '%1.txt', Comment = '%1 is the file name';
        NotSupportedErr: Label 'Export %1 is not supported by this codeunit', Comment = '%1 is the export type';
    begin
        IsHandled := false;
        OnBeforeExtport(GenJnlLine, Result, IsHandled);
        if IsHandled then
            exit(Result);

        TempBlob.CreateOutStream(OutStr);
        //XMLPORT.Export(XMLPortID, OutStr, GenJnlLine);

        SEPACTFillExportBuffer.FillExportBuffer(GenJnlLine, TempPaymentExport);
        case BankExport."UK Bank File Format" of
            "UK Bank File Format"::HSBCcsv:
                begin
                    ExportHSBCCSV(OutStr, TempPaymentExport);
                    FileNameTemplate := CSVFileTok;
                end;
            "UK Bank File Format"::HSBCS18:
                begin
                    ExportHSBCStd18(OutStr, TempPaymentExport);
                    FileNameTemplate := TxtFileTok;
                end;
            else
                Error(ErrorInfo.Create(StrSubstNo(NotSupportedErr, BankExport."UK Bank File Format")));
        end;

        CreditTransferRegister.FindLast();
        UseCommonDialog := not ExportToServerFile;
        OnBeforeBLOBExport(TempBlob, CreditTransferRegister, UseCommonDialog, FileCreated, IsHandled);
        if not IsHandled then
            FileCreated :=
                FileManagement.BLOBExport(TempBlob, StrSubstNo(FileNameTemplate, CreditTransferRegister.Identifier), UseCommonDialog) <> '';
        if FileCreated then
            SetCreditTransferRegisterToFileCreated(CreditTransferRegister, TempBlob);

        exit(CreditTransferRegister.Status = CreditTransferRegister.Status::"File Created");
    end;


    local procedure SetCreditTransferRegisterToFileCreated(var CreditTransferRegister: Record "Credit Transfer Register"; var TempBlob: Codeunit "Temp Blob")
    var
        RecordRef: RecordRef;
    begin
        CreditTransferRegister.Status := CreditTransferRegister.Status::"File Created";
        RecordRef.GetTable(CreditTransferRegister);
        TempBlob.ToRecordRef(RecordRef, CreditTransferRegister.FieldNo("Exported File"));
        RecordRef.SetTable(CreditTransferRegister);
        CreditTransferRegister.Modify();
    end;

    procedure EnableExportToServerFile()
    begin
        ExportToServerFile := true;
    end;

    #endregion

    #region Bank Specific formats

    local procedure ExportHSBCCSV(var OutStr: OutStream; var PaymentExport: Record "Payment Export Data")
    var
        CompanyInfo: Record "Company Information";
        StrConvMgt: Codeunit StringConversionManagement;
        Formatter: Codeunit UKBank_PaymentLineValidator;
        CSVBuffer: list of [Text];
        RemittanceText: text;
    begin
        CompanyInfo.Get();

        CSVBuffer.Add('Transaction Type');
        CSVBuffer.add('Remitter Batch Reference');
        CSVBuffer.add('Customer Reference');
        CSVBuffer.add('DebtorAgent ClearingMmbrId');
        CSVBuffer.add('Debit Account Number');
        CSVBuffer.add('Beneficiary Name');
        CSVBuffer.add('CreditorAgent ClearingMmbrId');
        CSVBuffer.add('Beneficiary Account Number');
        CSVBuffer.add('Transaction Amount');
        CSVBuffer.add('Payment Currency');
        CSVBuffer.add('Requested Processing Date');
        OutStr.WriteText(WriteBufferToCSV(CSVBuffer));
        OutStr.WriteText(); //crlf
        if PaymentExport.findset() then
            repeat
                Clear(CSVBuffer);

                if PaymentExport."Recipient Reference" <> '' then
                    RemittanceText := Format(StrConvMgt.WindowsToASCII(PaymentExport."Recipient Reference"), -18)
                else
                    RemittanceText := Format(StrConvMgt.WindowsToASCII(CompanyInfo.Name), -18);

                CSVBuffer.Add('NURG');
                CSVBuffer.add('');  //Payment batch ref
                CSVBuffer.add(RemittanceText);
                CSVBuffer.add(Formatter.FormatSortCodeAsNumeric(PaymentExport."Sender Bank Branch No."));
                CSVBuffer.add(PaymentExport."Sender Bank Account No.");
                CSVBuffer.add(format(PaymentExport."Recipient Name", -18));
                CSVBuffer.add(Formatter.FormatSortCodeAsNumeric(PaymentExport."Recipient Bank Branch No."));
                CSVBuffer.add(PaymentExport."Recipient Bank Acc. No.");
                CSVBuffer.add(Format(PaymentExport.Amount, 13, 1));
                CSVBuffer.add(PaymentExport."Currency Code");
                CSVBuffer.add(format(PaymentExport."Transfer Date", 0, 9));
                OutStr.WriteText(WriteBufferToCSV(CSVBuffer));
                OutStr.WriteText(); //crlf
            until PaymentExport.Next() = 0;
    end;

    local procedure ExportHSBCStd18(var OutStr: OutStream; var PaymentExport: Record "Payment Export Data")
    var
        CompanyInfo: Record "Company Information";
        BankAccount: Record "Bank Account";
        StrConvMgt: Codeunit StringConversionManagement;
        BankRules: Codeunit "Bank Export Rules";
        Formatter: Codeunit UKBank_PaymentLineValidator;
        RemittanceText: Text[18];
        SerialNo: Text[6];
        CountText: text[7];
        PaymentTotal: Decimal;
        DebitCount: Integer;
        LineText: text;

    begin
        CompanyInfo.Get();
        BankAccount.get(PaymentExport."Sender Bank Account Code");

        SerialNo := CopyStr(PaymentExport."Message ID", StrLen(PaymentExport."Message ID") - 5);
        SerialNo := SerialNo.PadLeft(6, '0');

        //VOL Record

        clear(LineText);
        LineText := LineText.PadRight(80, ' ');
        LineText := InsStr(LineText, 'VOL', 1);
        LineText := InsStr(LineText, '1', 4);
        LineText := InsStr(LineText, SerialNo, 5);
        LineText := InsStr(LineText, 'HSBC  ', 32);
        LineText := InsStr(LineText, '1', 80);
        OutStr.WriteText(format(LineText, 80));
        OutStr.WriteText();

        //HDR1 record
        Clear(LineText);
        LineText := LineText.PadRight(80, ' ');
        InsertText(LineText, 1, 'HDR');
        InsertText(LineText, 4, '1');
        InsertText(LineText, 5, 'A');
        InsertText(LineText, 12, 'S');
        InsertText(LineText, 22, SerialNo);
        InsertText(LineText, 28, '0001');
        InsertText(LineText, 32, '0001');
        InsertText(LineText, 43, Date2YYDDD(Today));  //Creation Date NB position 42 must be a blank space
        InsertText(LineText, 49, Date2YYDDD(Today + 5));
        InsertText(LineText, 55, '000000');
        OutStr.WriteText(format(LineText, 80));
        OutStr.WriteText();

        //HDR2 record
        Clear(LineText);
        LineText := LineText.PadRight(80, ' ');

        InsertText(LineText, 1, 'HDR');
        InsertText(LineText, 4, '2');
        InsertText(LineText, 5, 'F');
        InsertText(LineText, 6, '02000');
        InsertText(LineText, 11, '00100');  //= single day files
        InsertText(LineText, 51, '00');
        OutStr.WriteText(format(LineText, 80));
        OutStr.WriteText();

        //UHL record
        Clear(LineText);
        LineText := LineText.PadRight(80, ' ');

        InsertText(LineText, 1, 'UHL');
        InsertText(LineText, 4, '1');
        InsertText(LineText, 6, Date2YYDDD(PaymentExport."Transfer Date"));  // Bacs processing day 5=blank
        InsertText(LineText, 11, '999999   ');  // Identifying number of receiving party
        InsertText(LineText, 21, '00');  //Currency Code
        InsertText(LineText, 23, '000000');  //Country Code
                                             //work code 1bDAILYbb = BACS, 4bMULTIbb = multi day, 2bFPSbbbb = faster payments
        InsertText(LineText, 29, '1 DAILY  ');
        InsertText(LineText, 38, CopyStr(PaymentExport."Message ID", StrLen(PaymentExport."Message ID") - 2));  //3 digit sequence no.
        OutStr.WriteText(format(LineText, 80));
        OutStr.WriteText();

        //standard records
        if PaymentExport.FindSet() then
            repeat
                BankRules.AdjustPaymentBuffer(PaymentExport);  //formats sort code
                if PaymentExport."Recipient Reference" <> '' then
                    RemittanceText := Format(StrConvMgt.WindowsToASCII(PaymentExport."Recipient Reference"), -18)
                else
                    RemittanceText := Format(StrConvMgt.WindowsToASCII(CompanyInfo.Name), -18);

                Clear(LineText);
                LineText := LineText.PadRight(106, ' ');

                InsertText(LineText, 1, Formatter.FormatSortCodeAsNumeric(PaymentExport."Recipient Bank Branch No."));
                InsertText(LineText, 7, PaymentExport."Recipient Bank Acc. No.");
                InsertText(LineText, 15, '0');
                InsertText(LineText, 16, '99'); //Transaction code - 99 = BGC
                InsertText(LineText, 18, Formatter.FormatSortCodeAsNumeric(PaymentExport."Sender Bank Branch No."));
                InsertText(LineText, 24, PaymentExport."Sender Bank Account No.");
                InsertText(LineText, 36, Format(PaymentExport.Amount * 100, 0, '<Integer>').PadLeft(11, '0'));  //amount in pence
                InsertText(LineText, 47, Format(StrConvMgt.WindowsToASCII(CompanyInfo.Name), -18));
                InsertText(LineText, 65, RemittanceText);
                InsertText(LineText, 83, Format(StrConvMgt.WindowsToASCII(PaymentExport."Recipient Name"), -18));
                InsertText(LineText, 102, Date2YYDDD(PaymentExport."Transfer Date"));
                OutStr.WriteText(format(LineText, 106));
                OutStr.WriteText();

                PaymentTotal += PaymentExport.Amount;
                DebitCount += 1;
            until PaymentExport.Next() = 0;

        //Contra Record
        Clear(LineText);
        LineText := LineText.PadRight(106, ' ');

        InsertText(LineText, 1, Formatter.FormatSortCodeAsNumeric(PaymentExport."Sender Bank Branch No."));
        InsertText(LineText, 7, PaymentExport."Sender Bank Account No.");
        InsertText(LineText, 15, '0');
        InsertText(LineText, 16, '17'); //Transaction code - 99 = BGC Debit, 17 = Credit
        InsertText(LineText, 18, Formatter.FormatSortCodeAsNumeric(PaymentExport."Sender Bank Branch No."));
        InsertText(LineText, 24, PaymentExport."Sender Bank Account No.");
        InsertText(LineText, 36, Format(PaymentTotal * 100, 0, '<Integer>').PadLeft(11, '0'));  //amount in pence
        InsertText(LineText, 47, PaymentExport."Message ID");
        InsertText(LineText, 65, format('CONTRA', 18));
        InsertText(LineText, 83, Format(StrConvMgt.WindowsToASCII(CompanyInfo.Name), -18));
        InsertText(LineText, 102, Date2YYDDD(PaymentExport."Transfer Date"));
        OutStr.WriteText(format(LineText, 106));
        OutStr.WriteText();


        //EOF1 record
        Clear(LineText);
        LineText := LineText.PadRight(80, ' ');

        InsertText(LineText, 1, 'EOF');
        InsertText(LineText, 4, '1');
        InsertText(LineText, 5, 'A');
        InsertText(LineText, 12, 'S');
        InsertText(LineText, 22, SerialNo);
        InsertText(LineText, 28, '0001');
        InsertText(LineText, 32, '0001');
        InsertText(LineText, 43, Date2YYDDD(Today));  //Creation Date NB position 42 must be a blank space
        InsertText(LineText, 49, Date2YYDDD(Today + 5));
        InsertText(LineText, 55, '000000');
        OutStr.WriteText(format(LineText, 80));
        OutStr.WriteText();

        //EOF2 record
        Clear(LineText);
        LineText := LineText.PadRight(80, ' ');

        InsertText(LineText, 1, 'EOF');
        InsertText(LineText, 4, '2');
        InsertText(LineText, 5, 'F');
        InsertText(LineText, 6, '02000');
        InsertText(LineText, 11, '00100');  //= single day files
        InsertText(LineText, 51, '00');
        OutStr.WriteText(format(LineText, 80));
        OutStr.WriteText();

        //UTL1 record
        Clear(LineText);
        LineText := LineText.PadRight(80, ' ');

        InsertText(LineText, 1, 'UTL');
        InsertText(LineText, 4, '1');
        InsertText(LineText, 5, Format(PaymentTotal * 100, 0, '<Integer>').PadLeft(13, '0'));  //total Credits (contra) collected
        InsertText(LineText, 18, Format(PaymentTotal * 100, 0, '<Integer>').PadLeft(13, '0'));  //total amount debit in pence
        CountText := '1';
        InsertText(LineText, 31, CountText.PadLeft(7, '0'));
        CountText := format(DebitCount);
        InsertText(LineText, 38, CountText.PadLeft(7, '0'));
        OutStr.WriteText(format(LineText, 80));
        OutStr.WriteText();


    end;

    #endregion

    #region utility

    local procedure InsertText(var LineText: Text; Position: integer; NewText: text)
    begin
        LineText := InsStr(LineText, NewText, Position);
    end;

    local procedure WriteBufferToCSV(CSVBuffer: list of [Text]) Output: Text
    var
        i: Integer;
    begin
        for i := 1 to CSVBuffer.Count do begin
            if Output <> '' then
                Output := Output + ',';
            Output := Output + CSVBuffer.Get(i);
        end;
    end;

    local procedure Date2YYDDD(DateVar: Date): Text[5]
    var
        EndOfPriorYear: Date;
        Year: Integer;
        DayofYear: Integer;

        YYDDDFormatTok: Label '%1%2', Comment = '%1 = Year, %2 = Day of Year', Locked = true;
    begin

        Year := Date2DMY(DateVar, 3) mod 100;
        EndOfPriorYear := DMY2Date(1, 1, Date2DMY(DateVar, 3)) - 1;
        DayofYear := DateVar - EndOfPriorYear;
        exit(StrSubstNo(YYDDDFormatTok, PadStr('', 2 - StrLen(Format(Year)), '0') + Format(Year), PadStr('', 3 - StrLen(Format(DayofYear)), '0') + Format(DayofYear)));
    end;

    #endregion

    #region integration publishers
    [IntegrationEvent(false, false)]
    local procedure OnBeforeBLOBExport(var TempBlob: Codeunit "Temp Blob"; CreditTransferRegister: Record "Credit Transfer Register"; UseComonDialog: Boolean; var FieldCreated: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeExtport(var GenJnlLine: Record "Gen. Journal Line"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;
    #endregion

}

