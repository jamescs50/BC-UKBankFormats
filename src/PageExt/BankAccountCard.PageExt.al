namespace Kodoo.UKBanking;

using Microsoft.Bank.BankAccount;

pageextension 70502 "Bank Account Card" extends "Bank Account Card"
{
    layout
    {
        addbefore("Creditor No.")
        {
            field("Organisation ID"; Rec."Organisation ID")
            {
                ApplicationArea = All;
            }
        }
    }
}
