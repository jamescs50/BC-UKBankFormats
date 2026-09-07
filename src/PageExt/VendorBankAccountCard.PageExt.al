namespace Kodoo.BCUKBankFormats;

using Microsoft.Purchases.Vendor;

pageextension 70503 "Vendor Bank Account Card" extends "Vendor Bank Account Card"
{
    layout
    {
        addafter("Bank Account No.")
        {
            field("Account Name"; Rec."Account Name")
            {
                ApplicationArea = All;
                Importance = Additional;
            }
        }
        addlast(Transfer)
        {
            field("Intermediary Agent Name"; Rec."Intermediary Agent Name")
            {
                ApplicationArea = All;
                Importance = Additional;
            }
            field("Intermediary SWIFT Code"; Rec."Intermediary SWIFT Code")
            {
                ApplicationArea = All;
                Importance = Additional;
            }
        }
    }
}