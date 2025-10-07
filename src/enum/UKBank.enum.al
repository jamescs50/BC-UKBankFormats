namespace kodoo.UKBanking;

enum 70500 "UK Bank File Format"
{
    Extensible = true;

    value(0; None)
    {
        Caption = ' ';
    }
    value(1; Lloyds)
    {
        Caption = 'Lloyds ISO XML';
    }
    value(2; HSBCcsv)
    {
        Caption = 'HSBC-CSV';
    }
    value(3; HSBCS18)
    {
        Caption = 'HSBC Standard 18';
    }
    value(4; HSBCSXML)
    {
        Caption = 'HSBC ISO XML';
    }

    value(10; NatWest)
    {
        Caption = 'NatWest';
    }
    value(20; Barclays)
    {
        Caption = 'Barclays';
    }
    value(30; BankOfScotland)
    {
        Caption = 'Bank Of Scotland';
    }
}
