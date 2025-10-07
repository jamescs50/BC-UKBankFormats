namespace BCUKBankFormats.BCUKBankFormats;

using Microsoft.Finance.GeneralLedger.Journal;

tableextension 70501 "Gen. Journal Batch" extends "Gen. Journal Batch"
{
    fields
    {
        field(70500; International; Boolean)
        {
            Caption = 'International Payment';
            ToolTip = 'This batch is used for making international payments. These are usually significantly more expensive than domestic payments';
            DataClassification = CustomerContent;
        }
    }
}
