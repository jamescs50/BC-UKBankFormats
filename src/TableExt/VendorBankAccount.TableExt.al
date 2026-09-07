namespace kodoo.UKBanking;

using Microsoft.Purchases.Vendor;

tableextension 70504 "Vendor Bank Account" extends "Vendor Bank Account"
{
    fields
    {
        field(70500; "Account Name"; Text[100])
        {
            Caption = 'Account Name';
            ToolTip = 'if populated this value will overwrite the vendor name when creating payment files.';
            DataClassification = CustomerContent;
            AllowInCustomizations = AsReadWrite;
        }
        field(70501; "Intermediary Agent Name"; text[100])
        {
            Caption = 'Intermediary Agent Name';
            ToolTip = 'If the transaction requires an intermediary bank enter the name of the intermediary here.';
            DataClassification = CustomerContent;
            AllowInCustomizations = AsReadWrite;
        }
        field(70502; "Intermediary SWIFT Code"; Code[20])
        {
            Caption = 'Intermediary Agent SWIFT (BIC) Code';
            ToolTip = 'If the transaction requires an intermediary bank enter the SWIFT (BIC) code of the intermediary here.';
            DataClassification = CustomerContent;
            AllowInCustomizations = AsReadWrite;
        }
    }
}
