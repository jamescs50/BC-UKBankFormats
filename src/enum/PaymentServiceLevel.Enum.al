namespace kodoo.UKBanking;

enum 70501 "Payment Service Level"
{
    Extensible = true;

    value(0; NURG)
    {
        Caption = 'NURG';
    }
    value(1; SEPA)
    {
        Caption = 'SEPA';
    }
    value(2; URGP)
    {
        Caption = 'URGP';
    }
}
