# Data Dictionary

This document describes the raw source tables used in the **Vault
Product Data Science** project. Data types reflect the raw CSV
representation observed during data reconnaissance. Raw source files are
kept unchanged; parsing, renaming, translation, and other
transformations belong in the staging layer.

## account.csv

  -----------------------------------------------------------------------
  Column                  Data Type               Meaning
  ----------------------- ----------------------- -----------------------
  `account_id`            int                     Unique identifier of
                                                  the account. Primary
                                                  key

  `district_id`           int                     Identifier of the
                                                  district where the
                                                  account was opened.
                                                  Foreign key to
                                                  `district.csv`

  `frequency`             str                     Frequency of account
                                                  statement issuance

  `date`                  int                     Date the account was
                                                  opened. Raw format:
                                                  YYMMDD (`931221` =
                                                  1993-12-21)
  -----------------------------------------------------------------------

**`frequency` categories:** - `POPLATEK MESICNE`: Monthly statement
issuance - `POPLATEK TYDNE`: Weekly statement issuance -
`POPLATEK PO OBRATU`: Statement issued after transaction activity

------------------------------------------------------------------------

## card.csv

  -----------------------------------------------------------------------
  Column                  Data Type               Meaning
  ----------------------- ----------------------- -----------------------
  `card_id`               int                     Unique identifier of
                                                  the card. Primary key

  `disp_id`               int                     Identifier of the
                                                  disposition associated
                                                  with the card. Foreign
                                                  key to `disp.csv`

  `type`                  str                     Type of card

  `issued`                str                     Timestamp when the card
                                                  was issued. Raw format:
                                                  YYMMDD HH:MM:SS
  -----------------------------------------------------------------------

**`type` categories:** - `junior`: Junior card - `classic`: Classic
card - `gold`: Gold card

------------------------------------------------------------------------

## client.csv

  -----------------------------------------------------------------------
  Column                  Data Type               Meaning
  ----------------------- ----------------------- -----------------------
  `client_id`             int                     Unique identifier of
                                                  the client. Primary key

  `birth_number`          int                     Client birth number
                                                  encoding date of birth
                                                  and gender. Raw format:
                                                  YYMMDD; for female
                                                  clients, 50 is added to
                                                  the month

  `district_id`           int                     Identifier of the
                                                  client's district.
                                                  Foreign key to
                                                  `district.csv`
  -----------------------------------------------------------------------

**Note:** `birth_number` encodes both birth date and gender. These
should be derived into separate analytics-friendly fields in the staging
layer rather than altering the raw source.

------------------------------------------------------------------------

## disp.csv

  -----------------------------------------------------------------------
  Column                  Data Type               Meaning
  ----------------------- ----------------------- -----------------------
  `disp_id`               int                     Unique identifier of
                                                  the disposition.
                                                  Primary key

  `client_id`             int                     Identifier of the
                                                  client. Foreign key to
                                                  `client.csv`

  `account_id`            int                     Identifier of the
                                                  account. Foreign key to
                                                  `account.csv`

  `type`                  str                     Type of client-account
                                                  relationship
  -----------------------------------------------------------------------

**`type` categories:** - `OWNER`: Account owner - `DISPONENT`:
Authorized user of the account who is not the owner

**Note:** `disp.csv` acts as a bridge between clients and accounts.
Multiple clients can be associated with the same account.

------------------------------------------------------------------------

## district.csv

  -----------------------------------------------------------------------
  Column                  Data Type               Meaning
  ----------------------- ----------------------- -----------------------
  `A1`                    int                     Unique identifier of
                                                  the district. Primary
                                                  key

  `A2`                    str                     District name

  `A3`                    str                     Region name

  `A4`                    int                     Number of inhabitants

  `A5`                    int                     Number of
                                                  municipalities with
                                                  fewer than 500
                                                  inhabitants

  `A6`                    int                     Number of
                                                  municipalities with
                                                  500--1,999 inhabitants

  `A7`                    int                     Number of
                                                  municipalities with
                                                  2,000--9,999
                                                  inhabitants

  `A8`                    int                     Number of
                                                  municipalities with
                                                  10,000 or more
                                                  inhabitants

  `A9`                    int                     Number of cities

  `A10`                   float                   Ratio of urban
                                                  inhabitants

  `A11`                   int                     Average salary

  `A12`                   float                   Unemployment rate in
                                                  1995

  `A13`                   float                   Unemployment rate in
                                                  1996

  `A14`                   int                     Number of entrepreneurs
                                                  per 1,000 inhabitants

  `A15`                   int                     Number of crimes
                                                  committed in 1995

  `A16`                   int                     Number of crimes
                                                  committed in 1996
  -----------------------------------------------------------------------

**Note:** The raw dataset uses generic `A1`--`A16` column names. These
should be renamed to descriptive, analytics-friendly names in the
staging layer while preserving the raw source unchanged.

------------------------------------------------------------------------

## loan.csv

  -----------------------------------------------------------------------
  Column                  Data Type               Meaning
  ----------------------- ----------------------- -----------------------
  `loan_id`               int                     Unique identifier of
                                                  the loan. Primary key

  `account_id`            int                     Identifier of the
                                                  account associated with
                                                  the loan. Foreign key
                                                  to `account.csv`

  `date`                  int                     Date the loan was
                                                  granted. Raw format:
                                                  YYMMDD (`931221` =
                                                  1993-12-21)

  `amount`                int                     Total amount of the
                                                  loan

  `duration`              int                     Duration of the loan in
                                                  months

  `payments`              float                   Monthly loan payment
                                                  amount

  `status`                str                     Loan repayment status
  -----------------------------------------------------------------------

**`status` categories:** - `A`: Contract finished; loan repaid - `B`:
Contract finished; loan not repaid - `C`: Contract active; payments on
schedule - `D`: Contract active; client in debt

------------------------------------------------------------------------

## order.csv

  -----------------------------------------------------------------------
  Column                  Data Type               Meaning
  ----------------------- ----------------------- -----------------------
  `order_id`              int                     Unique identifier of
                                                  the standing order.
                                                  Primary key

  `account_id`            int                     Identifier of the
                                                  account issuing the
                                                  standing order. Foreign
                                                  key to `account.csv`

  `bank_to`               str                     Bank code of the
                                                  recipient

  `account_to`            int                     Account number of the
                                                  recipient

  `amount`                float                   Amount of the scheduled
                                                  payment

  `k_symbol`              str                     Category/purpose of the
                                                  scheduled payment
  -----------------------------------------------------------------------

**`k_symbol` categories:** - `SIPO`: Household payments - `UVER`: Loan
payment - `POJISTNE`: Insurance payment - `LEASING`: Leasing payment -
Missing/blank: Payment purpose not specified

**Note:** `order.csv` represents standing payment instructions rather
than individual executed transactions.

------------------------------------------------------------------------

## trans.csv

  -----------------------------------------------------------------------
  Column                  Data Type               Meaning
  ----------------------- ----------------------- -----------------------
  `trans_id`              int                     Unique identifier of
                                                  the transaction.
                                                  Primary key

  `account_id`            int                     Identifier of the
                                                  account associated with
                                                  the transaction.
                                                  Foreign key to
                                                  `account.csv`

  `date`                  int                     Date of the
                                                  transaction. Raw
                                                  format: YYMMDD
                                                  (`930101` = 1993-01-01)

  `type`                  str                     Direction/type of
                                                  transaction

  `operation`             str                     Method or operation
                                                  through which the
                                                  transaction was
                                                  performed

  `amount`                float                   Amount of the
                                                  transaction

  `balance`               float                   Account balance after
                                                  the transaction

  `k_symbol`              str                     Category/purpose of the
                                                  transaction

  `bank`                  str                     Bank code of the
                                                  counterparty, when
                                                  applicable

  `account`               float                   Account number of the
                                                  counterparty, when
                                                  applicable
  -----------------------------------------------------------------------

**`type` categories:** - `PRIJEM`: Credit / incoming transaction -
`VYDAJ`: Debit / outgoing transaction - `VYBER`: Withdrawal

**`operation` categories:** - `VYBER`: Cash withdrawal -
`PREVOD NA UCET`: Transfer to another account - `VKLAD`: Cash deposit -
`PREVOD Z UCTU`: Transfer from another account - `VYBER KARTOU`: Card
withdrawal - Missing/blank: Operation not specified

**`k_symbol` categories:** - `UROK`: Interest credited - `SLUZBY`:
Statement/service fee - `SIPO`: Household payments - `DUCHOD`: Pension -
`POJISTNE`: Insurance payment - `UVER`: Loan payment - `SANKC. UROK`:
Penalty interest - Missing/blank: Transaction purpose not specified

**Note:** Missing values in `operation`, `k_symbol`, `bank`, or
`account` are not necessarily data-quality errors. Some fields are only
applicable to particular transaction types.
