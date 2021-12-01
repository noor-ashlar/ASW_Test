
DEFINE TEMP-TABLE ttInvoice
    FIELD iCustNum   LIKE Customer.CustNum LABEL "Cust#"
    FIELD cCustName  LIKE Customer.NAME FORMAT "X(20)"
    FIELD cCreditLim  LIKE Customer.CreditLimit LABEL "Credit#".
/* Retrieve each invoice along with its Customer record, to get the Name. */
FOR EACH Customer:
    FIND FIRST ttInvoice WHERE ttInvoice.iCustNum = Customer.CustNum NO-ERROR.
    /* If there isn't already a temp-table record for the Customer, create it
    and save the Customer # and Name. */
    IF NOT AVAILABLE ttInvoice THEN
    DO:
        CREATE ttInvoice.
        ASSIGN
            ttInvoice.iCustNum  = Customer.CustNum
            ttInvoice.cCustName = Customer.Name
            ttInvoice.cCreditLim = Customer.CreditLimit.
    END.
END. /* END FOR EACH Invoice & Customer */

/* Input part to get customer ID to search*/
PROMPT-FOR ttInvoice.iCustNum LABEL "Cust Num to Find" WITH SIDE-LABELS NO-BOX ROW 10 FRAME e.

/*                          updated credit limit part*/
FIND FIRST ttInvoice NO-LOCK WHERE iCustNum = INPUT FRAME e ttInvoice.iCustNum NO-ERROR.
IF AVAILABLE ttInvoice THEN 
    DO:
        DISPLAY ttInvoice.iCustNum ttInvoice.cCustName ttInvoice.cCreditLim                                                 
                LABEL "Current credit limit"
                WITH FRAME a 1 DOWN ROW 1.
            PROMPT-FOR ttInvoice.cCreditLim LABEL "New credit limit"
                WITH SIDE-LABELS NO-BOX ROW 10 FRAME b.
            IF INPUT FRAME b ttInvoice.cCreditLim <> ttInvoice.cCreditLim THEN
            DO:
                DISPLAY "Changing max credit of" ttInvoice.iCustNum SKIP
                    "from" ttInvoice.cCreditLim "to" INPUT FRAME b ttInvoice.cCreditLim
                    WITH FRAME c ROW 15 NO-LABELS.
                ttInvoice.cCreditLim = INPUT FRAME b ttInvoice.cCreditLim.
            END.
            ELSE DISPLAY "No change in credit limit" WITH FRAME d ROW 15.
        DISPLAY iCustNum cCustName cCreditLim                                                 
            LABEL "Updated credit limit"
            WITH FRAME a 1 DOWN ROW 1.
    END.
ELSE 
    DO:
        MESSAGE "No record available".
    END.

/*                          updateing database*/

FOR EACH Customer:
    UPDATE Customer.CreditLimit = ttInvoice.cCreditLim.
END.

/*                          Printing Database after update.*/
/* Input part to get customer ID to search*/
PROMPT-FOR Customer.CustNum LABEL "Cust Num to Find in database" WITH SIDE-LABELS NO-BOX ROW 10 FRAME f.

FIND FIRST Customer NO-LOCK WHERE CustNum = INPUT FRAME f Customer.CustNum NO-ERROR.

IF AVAILABLE Customer THEN
    DO:
    DISPLAY Customer.CustNum Customer.NAME Customer.CreditLimit
    LABEL "From main Database"
    SKIP(2)
    WITH FRAME z 1 DOWN ROW 1.
    END.
ELSE
    DO:
        MESSAGE "No record available".
END.
