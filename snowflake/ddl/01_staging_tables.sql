
create database if not exists RESIDENTIAL_SURCHARGE;
create schema   if not exists RESIDENTIAL_SURCHARGE.STAGING;

use schema RESIDENTIAL_SURCHARGE.STAGING;


create or replace table DimCalender (
    DATE_ID                             date,
    IS_WEEKDAY                          boolean,
    FINANCIAL_YEAR                      number(38,0),
    DAY                                 number(38,0),
    FKDAYOFWEEK                         number(38,0),
    FINANCIAL_QUARTER_NUMBER            number(38,0),
    FINANCIAL_MONTH                     number(38,0),
    FINANCIAL_WEEK                      number(38,0),
    FINANCIAL_DAY_OF_THE_YEAR           number(38,0),
    FINANCIAL_MONTH_SEQUENTIAL_ID       number(38,0),
    DAY_OF_WEEK_SHORT_NAME              varchar,
    FINANCIAL_YEAR_RANGE                varchar,
    FINANCIAL_MONTH_SHORT_NAME          varchar,
    FINANCIAL_MONTH_WITH_YEAR           varchar,
    FINANCIAL_YEAR_MONTH_SHORT          number(38,0),
    FINANCIAL_QUARTER_WITH_YEAR         varchar,
    FINANCIAL_YEAR_AND_QUARTER_SHORT    number(38,0),
    WEEK_ENDING_DATE                    date
);

create or replace table DimCustomer (
    PAYINGACCOUNTCODEID     varchar,        
    CUSTOMERNAMERG          varchar,
    EXCLUDESURCHARGE        number(38,0)    
);

create or replace table DimSenderLocation (
    SENDERLOCATIONID            number(38,0),
    SENDERSUBURB                varchar,
    SENDERSTATE                 varchar,
    SENDERPOSTCODE              number(38,0),   
    SENDERRESIDENTIALADDRESS    number(38,0)
);

create or replace table DimReceiverLocation (
    RECEIVERLOCATIONID          number(38,0),
    RECEIVERSUBURB              varchar,
    RECEIVERSTATE               varchar,
    RECEIVERPOSTCODE            number(38,0),   
    RECEIVERRESIDENTIALADDRESS  number(38,0)    
);

create or replace table DimServiceType (
    SERVICETYPEID   number(38,0),
    DESCRIPTION     varchar
);

create or replace table DimUnitSurcharge (
    ID          number(38,0),
    UNIT_FROM   number(38,0),
    UNIT_TO     number(38,0),   -
    SURCHARGE   varchar         
);

create or replace table FactConsignment (
    INVOICE_ID          number(38,0),
    CONSIGNMENTNUMBER   varchar,
    INVOICEDATE         varchar,        
    SALESPOSTDATE       varchar,       
    SENDERLOCATIONID    number(38,0),
    RECEIVERLOCATIONID  number(38,0),
    PAYINGACCOUNTCODEID varchar,
    PREGSTCHARGE        number(38,2),  
    TOTALUNITS          number(38,1),   
    SERVICETYPEID       number(38,0)
);
