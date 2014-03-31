/*
    Copyright (c) 2013, Bridge Farm Consulting Inc
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Bridge Farm Consulting Inc nor 
      Center for American Progress nor the names of
      its contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.
 
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
    POSSIBILITY OF SUCH DAMAGE.
*/
/**
* @author Center for American Progress/Bridge Farm Consulting Inc
* @date 2014 (1.x)
* @description 
*/

public class BudgetActualWrapper {

List<String> args = new String[]{'0','number','###,###,###'};

public string slabel {get;set;}

public decimal ibudget1 {get;set;}
public decimal iactual1 {get;set;}
public decimal ibudget2 {get;set;}
public decimal iactual2 {get;set;}


public boolean brevenuebalance;

private string sremaining;

public budgetactualwrapper (String label, boolean brb) {
    slabel = label;
    brevenuebalance = brb;
   
    ibudget1 = 0;
    iactual1 = 0;
    ibudget2 = 0;
    iactual2 = 0;


}

public budgetactualwrapper (String label) {
    slabel = label;
    brevenuebalance = False;

    ibudget1 = 0;
    iactual1 = 0;
    ibudget2 = 0;
    iactual2 = 0;

    
}

public Decimal getiremaining () {
    if (brevenuebalance) {
        return ( (iactual1 + iactual2) - (ibudget1 + ibudget2) ).round();
        
    } else {
        return ( (ibudget1 + ibudget2) - (iactual1 + iactual2) ).round();
    }
}


public Decimal getibudget1 () {
    return ibudget1.round();
}

public Decimal getiactual1 () {
    return iactual1.round();
}

public Decimal getibudget2 () {
    return ibudget2.round();
}

public Decimal getiactual2 () {
    return iactual2.round();
}

public Boolean getbdisplay () {
    Boolean bshow = TRUE;
    if (ibudget1 == 0 && iactual1 == 0 && ibudget2 == 0 && iactual2 == 0) {
    
        bshow = FALSE;
    }
    return bshow;
}

public void updateValues(Decimal db1, Decimal da1, Decimal db2, Decimal da2) {

ibudget1 += db1;
iactual1 += da1;
ibudget2 += db2;
iactual2 += da2;

}

}