namespace kodoo.UKBanking;

using Microsoft.Bank.Payment;

tableextension 70500 "Payment Export Data" extends "Payment Export Data"
{
    fields
    {
        field(70500; "Recipient Bank Branch No."; Code[20])
        {
            Caption = 'Recipient Bank Branch No.';
            ToolTip = 'Destination Bank Branch no. (Sort Code)';
            DataClassification = CustomerContent;
            AllowInCustomizations = AsReadWrite;
        }
        field(70501; "Sender Bank Branch No."; Code[20])
        {
            Caption = 'Sender Bank Branch No.';
            ToolTip = 'Source Bank Branch no. (Sort Code)';
            DataClassification = CustomerContent;
            AllowInCustomizations = AsReadWrite;
        }
        field(70502; "Recipient IBAN"; Code[50])
        {
            Caption = 'Recipient IBAN';
            DataClassification = CustomerContent;
            AllowInCustomizations = AsReadWrite;
        }
        field(70503; "Sender IBAN"; Code[50])
        {
            Caption = 'Sender IBAN';
            DataClassification = CustomerContent;
            AllowInCustomizations = AsReadWrite;
        }
        field(70508; "Local Instrument"; code[10])
        {
            Caption = 'Local Instrument';
            DataClassification = CustomerContent;
            AllowInCustomizations = AsReadWrite;
        }
        field(70509; "Service Level"; Enum "Payment Service Level")
        {
            Caption = 'Service Level';
            ToolTip = 'NURG = UK domestic payments, SEPA for Euro payments to SEPA area, URGP for other payments.';
            DataClassification = CustomerContent;
            AllowInCustomizations = AsReadWrite;
        }
        field(70510; "Intermediary Agent Name"; text[100])
        {
            Caption = 'Intermediary Agent Name';
            ToolTip = 'If the transaction requires an intermediary bank enter the name of the intermediary here.';
            DataClassification = CustomerContent;
            AllowInCustomizations = AsReadWrite;
        }
        field(70511; "Intermediary SWIFT Code"; Code[20])
        {
            Caption = 'Intermediary Agent SWIFT (BIC) Code';
            ToolTip = 'If the transaction requires an intermediary bank enter the SWIFT (BIC) code of the intermediary here.';
            DataClassification = CustomerContent;
            AllowInCustomizations = AsReadWrite;
        }

    }
}
