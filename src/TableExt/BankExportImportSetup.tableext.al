namespace kodoo.UKBanking;

using Microsoft.Bank.Setup;

tableextension 70502 "Bank Export/Import Setup" extends "Bank Export/Import Setup"
{
    fields
    {
        field(70500; "UK Bank File Format"; Enum "UK Bank File Format")
        {
            Caption = 'UK Bank';
            ToolTip = 'Which banks specification should be followed when exporting payments?';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                case "UK Bank File Format" of
                    "UK Bank File Format"::Lloyds:
                        ;
                    "UK Bank File Format"::HSBCcsv, "UK Bank File Format"::HSBCS18:
                        begin
                            Rec."Processing Codeunit ID" := Codeunit::"UK Text Export Formats";
                        end;
                end;
            end;
        }
    }
}
