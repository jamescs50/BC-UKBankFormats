namespace kodoo.UKBanking;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Foundation.Company;
using Microsoft.Bank.Payment;
using Microsoft.Bank.DirectDebit;
using Microsoft.Bank.BankAccount;
using System.Text;

xmlport 70500 UKBanking_PAIN_001_001_03
{
    Caption = 'ISO pain.001.001.03 - UKBanks';
    DefaultNamespace = 'urn:iso:std:iso:20022:tech:xsd:pain.001.001.03';
    Direction = Export;
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        tableelement("Gen. Journal Line"; "Gen. Journal Line")
        {
            XmlName = 'Document';
            UseTemporary = true;
            tableelement(CompanyInformation; "Company Information")
            {
                XmlName = 'CstmrCdtTrfInitn';
                textelement(GrpHdr)
                {
                    textelement(messageid)
                    {
                        XmlName = 'MsgId';
                    }
                    textelement(createddatetime)
                    {
                        XmlName = 'CreDtTm';
                    }
                    textelement(Authstn)
                    {
                        textelement(AuthstnCd)
                        {
                            XmlName = 'Cd';

                        }
                        trigger OnBeforePassVariable()
                        begin
                            currXMLport.Skip();
                            AuthstnCd := 'AUTH';
                        end;
                    }

                    textelement(nooftransfers)
                    {
                        XmlName = 'NbOfTxs';
                    }
                    textelement(controlsum)
                    {
                        XmlName = 'CtrlSum';
                    }
                    textelement(InitgPty)
                    {
                        fieldelement(Nm; CompanyInformation.Name)
                        { }
                        textelement(initgptypstladr)
                        {
                            XmlName = 'PstlAdr';
                            fieldelement(StrtNm; CompanyInformation.Address)
                            {

                                trigger OnBeforePassField()
                                begin
                                    if CompanyInformation.Address = '' then
                                        currXMLport.Skip();
                                end;
                            }
                            fieldelement(PstCd; CompanyInformation."Post Code")
                            {

                                trigger OnBeforePassField()
                                begin
                                    if CompanyInformation."Post Code" = '' then
                                        currXMLport.Skip();
                                end;
                            }
                            fieldelement(TwnNm; CompanyInformation.City)
                            {

                                trigger OnBeforePassField()
                                begin
                                    if CompanyInformation.City = '' then
                                        currXMLport.Skip();
                                end;
                            }
                            fieldelement(Ctry; CompanyInformation."Country/Region Code")
                            {

                                trigger OnBeforePassField()
                                begin
                                    if CompanyInformation."Country/Region Code" = '' then
                                        currXMLport.Skip();
                                end;
                            }
                        }
                        textelement(initgptyid)
                        {
                            XmlName = 'Id';
                            textelement(initgptyorgid)
                            {
                                XmlName = 'OrgId';
                                fieldelement(BICOrBEI; CompanyInformation."SWIFT Code")
                                {
                                    trigger OnBeforePassField()
                                    begin
                                        if CompanyInformation."SWIFT Code" = '' then
                                            currXMLport.Skip();
                                    end;
                                }
                                textelement(initgptyothrinitgpty)
                                {
                                    XmlName = 'Othr';
                                    textelement(GrpHdrInitgPtyIdOrgIdOthrId)
                                    {
                                        XmlName = 'Id';
                                        trigger OnBeforePassVariable()
                                        begin
                                            GrpHdrInitgPtyIdOrgIdOthrId := BankRules.OrganisationID();
                                        end;
                                    }
                                }
                            }
                        }

                        trigger OnBeforePassVariable()
                        begin
                            CompanyInformation.Name := Format(StrConvMgt.WindowsToASCII(CompanyInformation.Name), -18);
                        end;
                    }
                }
                tableelement(PaymentExportDataGroup; "Payment Export Data")
                {
                    XmlName = 'PmtInf';
                    UseTemporary = true;

                    fieldelement(PmtInfId; PaymentExportDataGroup."Payment Information ID") { }
                    fieldelement(PmtMtd; PaymentExportDataGroup."SEPA Payment Method Text") { }
                    fieldelement(BtchBookg; PaymentExportDataGroup."SEPA Batch Booking")
                    {
                        trigger OnBeforePassField()
                        begin
                            //true = single entry on bank statement for payment - defaults to true.
                            if PaymentExportDataGroup."SEPA Batch Booking" then
                                currXMLport.Skip();
                        end;
                    }
                    fieldelement(NbOfTxs; PaymentExportDataGroup."Line No.") { }
                    fieldelement(CtrlSum; PaymentExportDataGroup.Amount) { }

                    textelement(PmtTpInf)
                    {
                        fieldelement(InstrPrty; PaymentExportDataGroup."SEPA Instruction Priority Text")
                        {
                            MaxOccurs = Once;
                            MinOccurs = Zero;
                        }
                        textelement(SvcLvl)
                        {
                            textelement(ScvLvlCd)
                            {
                                XmlName = 'Cd';
                            }
                            trigger OnBeforePassVariable()
                            begin
                                ScvLvlCd := BankRules.GetServiceLevelCode(PaymentExportDataGroup);
                                if ScvLvlCd = '' then
                                    currXMLport.Skip();
                            end;
                        }

                        textelement(LclInstrm)
                        {
                            fieldelement(Prtry; PaymentExportDataGroup."Local Instrument")
                            {
                                MinOccurs = Zero;
                                MaxOccurs = Once;
                            }
                            trigger OnBeforePassVariable()
                            begin
                                if BankRules.SuppressLocalInstrument() then
                                    currXMLport.Skip();
                            end;
                        }
                    }

                    fieldelement(ReqdExctnDt; PaymentExportDataGroup."Transfer Date") { }

                    textelement(Dbtr)
                    {
                        fieldelement(Nm; CompanyInformation.Name) { }
                        textelement(dbtrpstladr)
                        {
                            XmlName = 'PstlAdr';
                            fieldelement(StrtNm; CompanyInformation.Address)
                            {

                                trigger OnBeforePassField()
                                begin
                                    if CompanyInformation.Address = '' then
                                        currXMLport.Skip();
                                end;
                            }
                            fieldelement(PstCd; CompanyInformation."Post Code")
                            {

                                trigger OnBeforePassField()
                                begin
                                    if CompanyInformation."Post Code" = '' then
                                        currXMLport.Skip();
                                end;
                            }
                            fieldelement(TwnNm; CompanyInformation.City)
                            {

                                trigger OnBeforePassField()
                                begin
                                    if CompanyInformation.City = '' then
                                        currXMLport.Skip();
                                end;
                            }
                            fieldelement(Ctry; CompanyInformation."Country/Region Code")
                            {

                                trigger OnBeforePassField()
                                begin
                                    if CompanyInformation."Country/Region Code" = '' then
                                        currXMLport.Skip();
                                end;
                            }
                        }
                        textelement(dbtrid)
                        {
                            XmlName = 'Id';
                            textelement(dbtrorgid)
                            {
                                XmlName = 'OrgId';
                                fieldelement(BICOrBEI; PaymentExportDataGroup."Sender Bank BIC")
                                {
                                    trigger OnBeforePassField()
                                    begin
                                        if PaymentExportDataGroup."Sender Bank BIC" = '' then
                                            currXMLport.skip();
                                    end;
                                }
                                textelement(dbtrorgidOthr)
                                {
                                    XmlName = 'Othr';
                                    fieldelement(DbtrOrgIdOthrId; PaymentExportDataGroup."Sender Bank Branch No.")
                                    {
                                        XmlName = 'Id';
                                    }
                                }
                            }

                            trigger OnBeforePassVariable()
                            begin
                                if (PaymentExportDataGroup."Sender Bank BIC" = '') and
                                (PaymentExportDataGroup."Sender Bank Branch No." = '') then
                                    currXMLport.Skip();
                            end;
                        }
                    }
                    textelement(DbtrAcct)
                    {
                        textelement(dbtracctid)
                        {
                            XmlName = 'Id';

                            fieldelement(IBAN; PaymentExportDataGroup."Sender IBAN")
                            {
                                MaxOccurs = Once;
                                MinOccurs = Zero;

                                trigger OnBeforePassField()
                                begin
                                    if BankRules.SupressIBAN() then
                                        currXMLport.Skip();
                                end;
                            }

                            textelement(dbtracctOthr)
                            {
                                XmlName = 'Othr';

                                textelement(dbtracctOthrId)
                                {
                                    XmlName = 'Id';
                                }
                                trigger OnBeforePassVariable()
                                begin
                                    dbtracctOthrId := BankRules.GetdbtracctOthrId(PaymentExportDataGroup);
                                    if dbtracctOthrId = '' then
                                        currXMLport.Skip();
                                end;
                            }
                        }
                    }

                    textelement(DbtrAgt)
                    {
                        MinOccurs = Once;
                        MaxOccurs = Once;

                        textelement(dbtragtfininstnid)
                        {
                            XmlName = 'FinInstnId';
                            MinOccurs = Once;

                            fieldelement(BIC; PaymentExportDataGroup."Sender Bank BIC")
                            {
                                MaxOccurs = Once;
                                MinOccurs = Zero;

                                trigger OnBeforePassField()
                                begin
                                    if PaymentExportDataGroup."Sender Bank BIC" = '' then
                                        currXMLport.Skip();
                                end;
                            }
                            textelement(DbtragtFininstnidClrSysMmbId)
                            {
                                XmlName = 'ClrSysMmbId';
                                MaxOccurs = Once;
                                MinOccurs = Zero;
                                fieldelement(DbtragtFininstnidClrSysMmbId; PaymentExportDataGroup."Sender Bank Branch No.")
                                {
                                    XmlName = 'MmbId';
                                    MaxOccurs = Once;
                                    MinOccurs = Zero;
                                }
                            }
                        }
                    }

                    fieldelement(ChrgBr; PaymentExportDataGroup."SEPA Charge Bearer Text")
                    {
                        trigger OnBeforePassField()
                        begin
                            if BankRules.SuppressChargeBearer() then
                                currXMLport.Skip();
                        end;
                    }

                    tableelement(paymentexportdata; "Payment Export Data")
                    {
                        LinkFields = "Sender Bank BIC" = field("Sender Bank BIC"), "SEPA Instruction Priority Text" = field("SEPA Instruction Priority Text"), "Transfer Date" = field("Transfer Date"), "SEPA Batch Booking" = field("SEPA Batch Booking"), "SEPA Charge Bearer Text" = field("SEPA Charge Bearer Text");
                        LinkTable = PaymentExportDataGroup;
                        XmlName = 'CdtTrfTxInf';
                        UseTemporary = true;

                        textelement(PmtId)
                        {
                            fieldelement(EndToEndId; paymentexportdata."End-to-End ID") { }
                        }

                        textelement(CdtTrfTxInfPmtTpInf)
                        {
                            XmlName = 'PmtTpInf';

                            textelement(CdtTrfTxInfPmtTpInfSvcLvl)
                            {
                                XmlName = 'SvcLvl';
                                textelement(CdtTrfTxInfPmtTpInfSvcLvlCd)
                                {
                                    XmlName = 'Cd';

                                }
                                trigger OnBeforePassVariable()
                                begin
                                    CdtTrfTxInfPmtTpInfSvcLvlCd := BankRules.GetServiceLevelCode(PaymentExportDataGroup);
                                    if CdtTrfTxInfPmtTpInfSvcLvlCd = '' then
                                        currXMLport.Skip();
                                end;
                            }




                            trigger OnBeforePassVariable()
                            begin
                                if BankRules.SuppressCdtTrfTxInfPmtTpInf() then
                                    currXMLport.Skip();
                            end;
                        }

                        textelement(Amt)
                        {
                            fieldelement(InstdAmt; paymentexportdata.Amount)
                            {
                                fieldattribute(Ccy; paymentexportdata."Currency Code") { }
                            }
                        }

                        textelement(CdtrAgt)
                        {
                            textelement(cdtragtfininstnid)
                            {
                                XmlName = 'FinInstnId';

                                fieldelement(BIC; paymentexportdata."Recipient Bank BIC")
                                {
                                    FieldValidate = Yes;
                                    trigger OnBeforePassField()
                                    begin
                                        if (paymentexportdata."Recipient Bank BIC" = '') then
                                            currXMLport.Skip();
                                    end;
                                }
                                textelement(CdtrAgtClrSysMmbId)
                                {
                                    XmlName = 'ClrSysMmbId';
                                    fieldelement(CdtrAgtClrSysMmbIdMmbId; paymentexportdata."Recipient Bank Branch No.")
                                    {
                                        XmlName = 'MmbId';

                                    }
                                    trigger OnBeforePassVariable()
                                    begin
                                        if (paymentexportdata."Recipient Bank Branch No." = '') then
                                            currXMLport.Skip();
                                    end;
                                }
                                textelement(cdtragtfininstnidPstlAdr)
                                {
                                    XmlName = 'PstlAdr';
                                    fieldelement(cdtragtfininstnidPstlAdrCtry; paymentexportdata."Recipient Bank Country/Region")
                                    {
                                        XmlName = 'Ctry';
                                    }
                                }
                            }

                            textelement(Cdtr)
                            {
                                fieldelement(Nm; paymentexportdata."Recipient Name")
                                {
                                    trigger OnBeforePassField()
                                    begin
                                        paymentexportdata."Recipient Name" := Format(StrConvMgt.WindowsToASCII(paymentexportdata."Recipient Name"), -18);
                                    end;
                                }

                                textelement(cdtrpstladr)
                                {
                                    XmlName = 'PstlAdr';

                                    fieldelement(StrtNm; paymentexportdata."Recipient Address")
                                    {

                                        trigger OnBeforePassField()
                                        begin
                                            if paymentexportdata."Recipient Address" = '' then
                                                currXMLport.Skip();
                                        end;
                                    }

                                    fieldelement(PstCd; paymentexportdata."Recipient Post Code")
                                    {
                                        trigger OnBeforePassField()
                                        begin
                                            if paymentexportdata."Recipient Post Code" = '' then
                                                currXMLport.Skip();
                                        end;
                                    }

                                    fieldelement(TwnNm; paymentexportdata."Recipient City")
                                    {

                                        trigger OnBeforePassField()
                                        begin
                                            if paymentexportdata."Recipient City" = '' then
                                                currXMLport.Skip();
                                        end;
                                    }

                                    fieldelement(Ctry; paymentexportdata."Recipient Country/Region Code")
                                    {
                                        trigger OnBeforePassField()
                                        begin
                                            if paymentexportdata."Recipient Country/Region Code" = '' then
                                                currXMLport.Skip();
                                        end;
                                    }

                                    trigger OnBeforePassVariable()
                                    begin
                                        if (paymentexportdata."Recipient Address" = '') and
                                           (paymentexportdata."Recipient Post Code" = '') and
                                           (paymentexportdata."Recipient City" = '') and
                                           (paymentexportdata."Recipient Country/Region Code" = '')
                                        then
                                            currXMLport.Skip();
                                    end;
                                }
                            }

                            textelement(CdtrAcct)
                            {
                                textelement(cdtracctid)
                                {
                                    XmlName = 'Id';

                                    fieldelement(IBAN; paymentexportdata."Recipient IBAN")
                                    {
                                        FieldValidate = Yes;
                                        MaxOccurs = Once;
                                        MinOccurs = Zero;

                                        trigger OnBeforePassField()
                                        begin
                                            if (paymentexportdata."Recipient IBAN" = '') or BankRules.SupressIBAN() then
                                                currXMLport.Skip();
                                        end;
                                    }

                                    textelement(Othr)
                                    {
                                        fieldelement(cdtracctidcdtracctidId; paymentexportdata."Recipient Bank Acc. No.")
                                        {
                                            XmlName = 'Id';
                                        }
                                        trigger OnBeforePassVariable()
                                        begin
                                            if paymentexportdata."Recipient Bank Acc. No." = '' then
                                                currXMLport.Skip();
                                        end;
                                    }
                                }
                            }

                            textelement(RmtInf)
                            {
                                MinOccurs = Zero;

                                textelement(Strd)
                                {
                                    MinOccurs = Zero;

                                    textelement(CdtrRefInf)
                                    {
                                        MinOccurs = Zero;

                                        textelement(Tp)
                                        {
                                            MinOccurs = Zero;

                                            textelement(CdOrPrtry)
                                            {
                                                MinOccurs = Zero;

                                                textelement(remittancetext)
                                                {
                                                    XmlName = 'Prtry';
                                                    MinOccurs = Zero;
                                                }
                                            }
                                        }
                                    }
                                }

                                trigger OnBeforePassVariable()
                                begin
                                    if paymentexportdata."Recipient Reference" <> '' then
                                        remittancetext := Format(StrConvMgt.WindowsToASCII(paymentexportdata."Recipient Reference"), -18)
                                    else
                                        remittancetext := Format(StrConvMgt.WindowsToASCII(CompanyInformation.Name), -18);

                                    if remittancetext = '' then
                                        currXMLport.Skip();
                                end;
                            }
                        }
                        trigger OnAfterGetRecord()
                        begin
                            BankRules.AdjustPaymentBuffer(paymentexportdata);
                        end;
                    }
                    trigger OnAfterGetRecord()
                    begin
                        BankRules.AdjustPaymentBuffer(PaymentExportDataGroup);
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    if not paymentexportdata.GetPreserveNonLatinCharacters() then
                        paymentexportdata.CompanyInformationConvertToLatin(CompanyInformation);
                end;
            }
        }
    }


    trigger OnPreXmlPort()
    begin
        InitData();
    end;


    local procedure InitData()
    var
        SEPACTFillExportBuffer: Codeunit "SEPA CT-Fill Export Buffer";
        PaymentGroupNo: Integer;
    begin
        SEPACTFillExportBuffer.FillExportBuffer("Gen. Journal Line", paymentexportdata);
        BankRules.SetExportFormat("Gen. Journal Line");
        paymentexportdata.GetRemittanceTexts(TempPaymentExportRemittanceText);

        nooftransfers := Format(paymentexportdata.Count);
        messageid := paymentexportdata."Message ID";
        createddatetime := Format(CurrentDateTime, 19, 9);
        paymentexportdata.CalcSums(Amount);
        controlsum := Format(paymentexportdata.Amount, 0, 9);

        paymentexportdata.SetCurrentKey(
          "Sender Bank BIC", "SEPA Instruction Priority Text", "Transfer Date",
          "SEPA Batch Booking", "SEPA Charge Bearer Text");

        if not paymentexportdata.FindSet() then
            Error(NoDataToExportErr);

        InitPmtGroup();
        repeat
            if IsNewGroup() then begin
                InsertPmtGroup(PaymentGroupNo);
                InitPmtGroup();
            end;
            PaymentExportDataGroup."Line No." += 1;
            PaymentExportDataGroup.Amount += paymentexportdata.Amount;
        until paymentexportdata.Next() = 0;
        InsertPmtGroup(PaymentGroupNo);
    end;

    local procedure IsNewGroup(): Boolean
    begin
        exit(
          (paymentexportdata."Sender Bank BIC" <> PaymentExportDataGroup."Sender Bank BIC") or
          (paymentexportdata."SEPA Instruction Priority Text" <> PaymentExportDataGroup."SEPA Instruction Priority Text") or
          (paymentexportdata."Transfer Date" <> PaymentExportDataGroup."Transfer Date") or
          (paymentexportdata."SEPA Batch Booking" <> PaymentExportDataGroup."SEPA Batch Booking") or
          (paymentexportdata."SEPA Charge Bearer Text" <> PaymentExportDataGroup."SEPA Charge Bearer Text"));
    end;

    local procedure InitPmtGroup()
    begin
        PaymentExportDataGroup := paymentexportdata;
        PaymentExportDataGroup."Line No." := 0; // used for counting transactions within group
        PaymentExportDataGroup.Amount := 0; // used for summarizing transactions within group
    end;

    local procedure InsertPmtGroup(var PaymentGroupNo: Integer)
    begin
        PaymentGroupNo += 1;
        PaymentExportDataGroup."Entry No." := PaymentGroupNo;
        PaymentExportDataGroup."Payment Information ID" :=
          CopyStr(
            StrSubstNo('%1/%2', paymentexportdata."Message ID", PaymentGroupNo),
            1, MaxStrLen(PaymentExportDataGroup."Payment Information ID"));
        PaymentExportDataGroup.Insert();
    end;

    var
        TempPaymentExportRemittanceText: Record "Payment Export Remittance Text" temporary;
        BankRules: Codeunit "Bank Export Rules";
        StrConvMgt: Codeunit StringConversionManagement;
        NoDataToExportErr: Label 'There is no data to export.', Comment = '%1=Field;%2=Value;%3=Value';
}