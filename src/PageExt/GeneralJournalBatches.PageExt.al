namespace kodoo.UKBanking;

using Microsoft.Finance.GeneralLedger.Journal;

pageextension 70501 "General Journal Batches" extends "General Journal Batches"
{
    layout
    {
        addlast(Control1)
        {
            field(International; Rec.International)
            {
                ApplicationArea = all;
            }
        }
    }
}
