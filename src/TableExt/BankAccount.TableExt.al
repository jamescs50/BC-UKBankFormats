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
        }
    }
}
