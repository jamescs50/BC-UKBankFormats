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
        }
        field(70501; "Sender Bank Branch No."; Code[20])
        {
            Caption = 'Sender Bank Branch No.';
            ToolTip = 'Source Bank Branch no. (Sort Code)';
            DataClassification = CustomerContent;
        }
        field(70502; "Recipient IBAN"; Code[50])
        {
            Caption = 'Recipient IBAN';
            DataClassification = CustomerContent;
        }
        field(70503; "Sender IBAN"; Code[50])
        {
            Caption = 'Sender IBAN';
            DataClassification = CustomerContent;
        }
        field(70508; "Local Instrument"; code[10])
        {
            Caption = 'Local Instrument';
            DataClassification = CustomerContent;
        }

    }
}
