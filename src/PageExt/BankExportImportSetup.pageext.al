namespace kodoo.UKBanking;

using Microsoft.Bank.Setup;

pageextension 70500 "Bank Export/Import Setup" extends "Bank Export/Import Setup"
{
    layout
    {
        addafter("Processing XMLport Name")
        {
            field(UkBank_UKBank; Rec."UK Bank File Format")
            {
                ApplicationArea = all;
            }
        }
    }
}
