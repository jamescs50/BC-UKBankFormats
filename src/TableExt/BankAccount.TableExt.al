namespace Kodoo.UKBanking;

using Microsoft.Bank.BankAccount;

tableextension 70503 "Bank Account" extends "Bank Account"
{
    fields
    {
        field(70500; "Organisation ID"; Code[20])
        {
            Caption = 'Organisation ID';
            ToolTip = 'Identifier relating to the company issued by the bank. This will be quoted in payment files as the Organisation ID.';
            DataClassification = CustomerContent;
            AllowInCustomizations = AsReadWrite;
        }
        field(70501; "BACS Id"; code[6])
        {
            Caption = 'BACS ID';
            ToolTip = 'Specifies the BACS Id also know as the SUN (Service User Number)';
            DataClassification = CustomerContent;
            AllowInCustomizations = AsReadWrite;
        }
    }
}
