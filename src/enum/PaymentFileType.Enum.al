namespace kodoo.UKBanking;

enum 70502 "Payment File Type"
{
    Extensible = true;
    Caption = 'Payment File Type';

    value(0; BACS)
    {
        Caption = 'UK Domestic (BACS)';
    }
    value(1; SEPA)
    {
        Caption = 'EU Payments (SEPA)';
    }
    value(2; Intnl)
    {
        Caption = 'International Payments';
    }
}
