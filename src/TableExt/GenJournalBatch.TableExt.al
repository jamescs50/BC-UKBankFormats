namespace kodoo.UKBanking;

using Microsoft.Finance.GeneralLedger.Journal;

tableextension 70501 "Gen. Journal Batch" extends "Gen. Journal Batch"
{
    fields
    {
        field(70500; "Service Level"; Enum "Payment Service Level")
        {
            Caption = 'Service Level';
            ToolTip = 'NURG = UK domestic payments, SEPA for Euro payments to SEPA area, URGP for other payments.';
            DataClassification = CustomerContent;
        }
    }
}
