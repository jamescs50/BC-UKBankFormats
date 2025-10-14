namespace kodoo.UKBanking;

using Microsoft.Finance.GeneralLedger.Journal;

pageextension 70501 "General Journal Batches" extends "General Journal Batches"
{
    layout
    {
        addlast(Control1)
        {
            field("Service Level"; Rec."Service Level")
            {
                ApplicationArea = All;
                Visible = false;
            }
        }
    }
}
