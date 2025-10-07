namespace kodoo.UKBanking;

enum 70501 UKBank_PaymentLocality
{
    Extensible = true;

    value(0; Domestic)
    {
        Caption = 'Domestic';
    }
    value(1; International)
    {
        Caption = 'International';
    }
}
