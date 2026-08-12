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
            AllowInCustomizations = AsReadWrite;
        }
        field(70501; "Payment File Type"; Enum "Payment File Type")
        {
            Caption = 'Payment File Type';
            ToolTip = 'Specifies the Type of payment file being prepared.';
            DataClassification = CustomerContent;
            AllowInCustomizations = AsReadWrite;

            trigger OnValidate()
            begin
                case "Payment File Type" of
                    Enum::"Payment File Type"::BACS:
                        "Service Level" := Enum::"Payment Service Level"::NURG;
                    Enum::"Payment File Type"::SEPA:
                        "Service Level" := Enum::"Payment Service Level"::SEPA;
                    Enum::"Payment File Type"::Intnl:
                        "Service Level" := Enum::"Payment Service Level"::URGP;
                end;
            end;
        }
    }
}
