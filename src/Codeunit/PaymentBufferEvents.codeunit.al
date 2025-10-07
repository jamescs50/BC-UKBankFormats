namespace kodoo.UKBanking;

using Microsoft.Bank.Payment;
using Microsoft.Bank.BankAccount;
using Microsoft.Sales.Customer;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Bank.DirectDebit;
using Microsoft.HumanResources.Employee;
using Microsoft.Purchases.Vendor;
codeunit 70501 UKBank_PaymentBufferEvents
{

    [EventSubscriber(ObjectType::Table, database::"Payment Export Data", OnAfterSetBankAsSenderBank, '', false, false)]
    local procedure PaymentExportData_OnAfterSetBankAsSenderBank(var sender: Record "Payment Export Data"; BankAccount: Record "Bank Account")
    begin
        if BankRules.UKBankType(BankAccount) = "UK Bank File Format"::None then
            exit;
        sender."Sender Bank Branch No." := BankAccount."Bank Branch No.";
        sender."Sender Bank Account No." := BankAccount."Bank Account No.";
        sender."Sender IBAN" := BankAccount.IBAN;
    end;

    [EventSubscriber(ObjectType::Table, database::"Payment Export Data", OnAfterSetCustomerAsRecipient, '', false, false)]
    local procedure PaymentExportData_OnAfterSetCustomerAsRecipient(var PaymentExportData: Record "Payment Export Data"; var CustomerBankAccount: Record "Customer Bank Account");
    begin
        if BankRules.UKBankType(PaymentExportData) = "UK Bank File Format"::None then
            exit;

        PaymentExportData."Recipient Bank Branch No." := CustomerBankAccount."Bank Branch No.";
        PaymentExportData."Recipient Bank Acc. No." := CustomerBankAccount."Bank Account No.";
        PaymentExportData."Recipient IBAN" := CustomerBankAccount.IBAN;
    end;

    [EventSubscriber(ObjectType::Table, database::"Payment Export Data", OnAfterSetEmployeeAsRecipient, '', false, false)]
    local procedure PaymentExportData_OnAfterSetEmployeeAsRecipient(var sender: Record "Payment Export Data"; Employee: Record Employee)
    begin
        if BankRules.UKBankType(sender) = "UK Bank File Format"::None then
            exit;

        sender."Recipient Bank Branch No." := Employee."Bank Branch No.";
        sender."Recipient Bank Acc. No." := Employee."Bank Account No.";
        sender."Recipient IBAN" := Employee.IBAN;
    end;

    [EventSubscriber(ObjectType::Table, database::"Payment Export Data", OnAfterSetVendorAsRecipient, '', false, false)]
    local procedure PaymentExportData_OnAfterSetVendorAsRecipient(var PaymentExportData: Record "Payment Export Data"; var Vendor: Record Vendor; var VendorBankAccount: Record "Vendor Bank Account");
    begin
        if BankRules.UKBankType(PaymentExportData) = "UK Bank File Format"::None then
            exit;

        PaymentExportData."Recipient Bank Branch No." := VendorBankAccount."Bank Branch No.";
        PaymentExportData."Recipient Bank Acc. No." := VendorBankAccount."Bank Account No.";
        PaymentExportData."Recipient IBAN" := VendorBankAccount.IBAN;
    end;

    [EventSubscriber(ObjectType::Table, database::"Payment Export Data", OnAfterSetBankAsRecipient, '', false, false)]
    local procedure PaymentExportData_OnAfterSetBankAsRecipient(var BankAccount: Record "Bank Account"; var PaymentExportData: Record "Payment Export Data")
    begin
        if BankRules.UKBankType(PaymentExportData) = "UK Bank File Format"::None then
            exit;
        PaymentExportData."Recipient Bank Branch No." := BankAccount."Bank Branch No.";
        PaymentExportData."Recipient Bank Acc. No." := BankAccount."Bank Account No.";
        PaymentExportData."Recipient IBAN" := BankAccount.IBAN;
    end;


    [EventSubscriber(ObjectType::Codeunit, codeunit::"SEPA CT-Fill Export Buffer", OnFillExportBufferOnBeforeInsertPaymentExportData, '', false, false)]
    local procedure PaymentExportData_OnFillExportBufferOnBeforeInsertPaymentExportData(var PaymentExportData: Record "Payment Export Data"; var TempGenJnlLine: Record "Gen. Journal Line" temporary)
    var
        GenJnlBatch: Record "Gen. Journal Batch";
    begin
        if not GenJnlBatch.get(TempGenJnlLine."Journal Template Name", TempGenJnlLine."Journal Batch Name") then
            GenJnlBatch.Init();
        PaymentExportData.International := GenJnlBatch.International;
        PaymentExportData."SEPA Batch Booking" := true;  //indicates that we want one entry on our 

    end;


    var
        BankRules: Codeunit "Bank Export Rules";
}
