namespace kodoo.UKBanking;
using Microsoft.Bank.DirectDebit;
using Microsoft.HumanResources.Employee;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Finance.GeneralLedger.Journal;

codeunit 70502 UKBank_PaymentLineValidator
{


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SEPA CT-Check Line", OnBeforeCheckCustVendEmpl, '', false, false)]
    local procedure SEPACTCheckLine_OnBeforeCheckCustVendEmpl(var GenJournalLine: Record "Gen. Journal Line"; var IsHandled: Boolean)
    var
        GenJnlBatch: Record "Gen. Journal Batch";
        Customer: Record Customer;
        CustomerBankAccount: Record "Customer Bank Account";
        Vendor: Record Vendor;
        VendorBankAccount: Record "Vendor Bank Account";
        Employee: Record Employee;
        BankRules: Codeunit "Bank Export Rules";
        ErrorText: Text;
        CountryErr: Label 'Country code must be specified on account %1', Comment = '%1';
    begin
        if BankRules.UKBankType(GenJournalLine) = "UK Bank File Format"::none then
            exit;
        if not GenJnlBatch.get(GenJournalLine."Journal Template Name", GenJournalLine."Journal Batch Name") then
            GenJnlBatch.Init();

        case GenJournalLine."Account Type" of
            GenJournalLine."Account Type"::Customer:
                begin
                    Customer.Get(GenJournalLine."Account No.");

                    if Customer.Name = '' then
                        AddFieldEmptyError(GenJournalLine, Customer.TableCaption(), Customer.FieldCaption(Name), GenJournalLine."Account No.");

                    if GenJournalLine."Recipient Bank Account" <> '' then begin
                        CustomerBankAccount.Get(Customer."No.", GenJournalLine."Recipient Bank Account");
                        if GenJnlBatch."Service Level" = "Payment Service Level"::NURG then begin
                            if CustomerBankAccount."Bank Branch No." = '' then
                                AddFieldEmptyError(
                                GenJournalLine, CustomerBankAccount.TableCaption(), CustomerBankAccount.FieldCaption("Bank Branch No."), GenJournalLine."Recipient Bank Account")
                            else
                                if not IsValidBankSortCode(CustomerBankAccount."Bank Branch No.", ErrorText) then
                                    GenJournalLine.InsertPaymentFileError(ErrorText);
                            if CustomerBankAccount."Bank Account No." = '' then
                                AddFieldEmptyError(
                                  GenJournalLine, CustomerBankAccount.TableCaption(), CustomerBankAccount.FieldCaption("Bank Account No."), GenJournalLine."Recipient Bank Account")
                            else begin
                                if not IsValidBankAccountNo(CustomerBankAccount."Bank Account No.", ErrorText) then
                                    GenJournalLine.InsertPaymentFileError(ErrorText);
                                if BankRules.UKBankType(GenJournalLine) = "UK Bank File Format"::HSBCSXML then
                                    if CustomerBankAccount."Country/Region Code" = '' then
                                        GenJournalLine.InsertPaymentFileError(StrSubstNo(CountryErr, CustomerBankAccount.Code));
                            end;
                        end;
                    end;
                end;
            GenJournalLine."Account Type"::Vendor:
                begin
                    Vendor.Get(GenJournalLine."Account No.");

                    if Vendor.Name = '' then
                        AddFieldEmptyError(GenJournalLine, Vendor.TableCaption(), Vendor.FieldCaption(Name), GenJournalLine."Account No.");

                    if GenJnlBatch."Service Level" = "Payment Service Level"::NURG then begin
                        if GenJournalLine."Recipient Bank Account" <> '' then begin
                            VendorBankAccount.Get(Vendor."No.", GenJournalLine."Recipient Bank Account");
                            if VendorBankAccount.IBAN = '' then begin
                                if VendorBankAccount."Bank Branch No." = '' then
                                    AddFieldEmptyError(
                                    GenJournalLine, VendorBankAccount.TableCaption(), VendorBankAccount.FieldCaption("Bank Branch No."), GenJournalLine."Recipient Bank Account")
                                else
                                    if not IsValidBankSortCode(VendorBankAccount."Bank Branch No.", ErrorText) then
                                        GenJournalLine.InsertPaymentFileError(ErrorText);

                                if VendorBankAccount."Bank Account No." = '' then
                                    AddFieldEmptyError(
                                    GenJournalLine, VendorBankAccount.TableCaption(), VendorBankAccount.FieldCaption("Bank Account No."), GenJournalLine."Recipient Bank Account")
                                else begin
                                    if not IsValidBankAccountNo(VendorBankAccount."Bank Account No.", ErrorText) then
                                        GenJournalLine.InsertPaymentFileError(ErrorText);
                                    if BankRules.UKBankType(GenJournalLine) = "UK Bank File Format"::HSBCSXML then
                                        if VendorBankAccount."Country/Region Code" = '' then
                                            GenJournalLine.InsertPaymentFileError(StrSubstNo(CountryErr, VendorBankAccount.Code));
                                end;
                            end;
                        end;
                    end;
                end;
            GenJournalLine."Account Type"::Employee:
                begin
                    Employee.Get(GenJournalLine."Account No.");

                    if Employee.FullName() = '' then
                        AddFieldEmptyError(GenJournalLine, Employee.TableCaption(), Employee.FieldCaption("First Name"), GenJournalLine."Account No.");
                    if GenJnlBatch."Service Level" = "Payment Service Level"::NURG then begin
                        if GenJournalLine."Recipient Bank Account" <> '' then begin
                            if Employee."Bank Branch No." = '' then
                                AddFieldEmptyError(
                                  GenJournalLine, Employee.TableCaption(), Employee.FieldCaption("Bank Branch No."), GenJournalLine."Recipient Bank Account")
                            else
                                if not IsValidBankSortCode(Employee."Bank Branch No.", ErrorText) then
                                    GenJournalLine.InsertPaymentFileError(ErrorText);

                            if Employee."Bank Account No." = '' then
                                AddFieldEmptyError(
                                  GenJournalLine, Employee.TableCaption(), Employee.FieldCaption("Bank Account No."), GenJournalLine."Recipient Bank Account")
                            else begin
                                if not IsValidBankAccountNo(Employee."Bank Account No.", ErrorText) then
                                    GenJournalLine.InsertPaymentFileError(ErrorText);
                                if BankRules.UKBankType(GenJournalLine) = "UK Bank File Format"::HSBCSXML then
                                    if Employee."Country/Region Code" = '' then
                                        GenJournalLine.InsertPaymentFileError(StrSubstNo(CountryErr, Employee."No."));
                            end;
                        end;
                    end;
                end;
        end;

        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SEPA CT-Check Line", OnAfterCheckGenJnlLine, '', false, false)]
    local procedure SEPACTCheckLine_OnAfterCheckGenJnlLine(var GenJournalLine: Record "Gen. Journal Line")
    var
        GenJnlBatch: Record "Gen. Journal Batch";
        CurrencyPaymentErr: Label 'Currency payments can only be made in an international payments batch.';
    begin
        if GenJournalLine."Currency Code" = '' then
            exit;
        GenJnlBatch.Get(GenJournalLine."Journal Template Name", GenJournalLine."Journal Batch Name");
        if GenJnlBatch."Service Level" = "Payment Service Level"::NURG then
            GenJournalLine.InsertPaymentFileError(CurrencyPaymentErr);
    end;

    local procedure AddFieldEmptyError(var GenJnlLine: Record "Gen. Journal Line"; TableCaption2: Text; FieldCaption: Text; KeyValue: Text)
    var
        ErrorText: Text;
        FieldKeyBlankErr: Label '%1 must have a value in %2 %3.', Comment = '%1 = Table name, %2 = Key field value, %3 = Field name. Example: Customer 10000 must have a value in Name.';
    begin
        ErrorText := StrSubstNo(FieldKeyBlankErr, FieldCaption, TableCaption2, KeyValue);
        GenJnlLine.InsertPaymentFileError(ErrorText);
    end;

    local procedure IsValidBankSortCode(SortCode: Text; var ErrorText: Text): Boolean
    var
        CurrentChar: Integer;
        TempCode: Text;
        IncorrectSortCodeErr: Label '%1 is not a valid sort code. Sort codes must contain exactly 6 numeric characters.', Comment = '%1 = Sort code';
    begin
        ErrorText := '';

        for CurrentChar := 1 to StrLen(SortCode) do
            if SortCode[CurrentChar] in [48 .. 57] then // ASCII 0-9
                TempCode := TempCode + SortCode[CurrentChar];

        if StrLen(TempCode) <> 6 then begin
            ErrorText := StrSubstNo(IncorrectSortCodeErr, SortCode);
            exit(false);
        end;

        exit(true);
    end;

    local procedure IsValidBankAccountNo(AccountNo: Text; var ErrorText: Text): Boolean
    var
        CurrentChar: Integer;
        IncorrectBankAccountErr: Label '%1 is not a valid UK bank account number. Bank account numbers must contain exactly 8 numeric characters.', Comment = '%1 = Account No.';
    begin
        ErrorText := '';

        if StrLen(AccountNo) <> 8 then begin
            ErrorText := StrSubstNo(IncorrectBankAccountErr, AccountNo);
            exit(false);
        end;

        for CurrentChar := 1 to StrLen(AccountNo) do
            if not (AccountNo[CurrentChar] in [48 .. 57]) then begin // ASCII 0-9
                ErrorText := StrSubstNo(IncorrectBankAccountErr, AccountNo);
                exit(false);
            end;

        exit(true);
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

}
