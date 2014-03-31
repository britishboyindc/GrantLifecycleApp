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

public with sharing class BudgetActualController {

/*
This version is where jrb comments out all the code related to 
operational overhead and closing balance comparison.
It's called by the vf page: BudgetvsActual2jrbstripped
*/

public List<budgetactualwrapper> salarywrapper {get;set;}
public List<budgetactualwrapper> expenseswrapper {get;set;}

public Map<String, budgetactualwrapper> salarydisplaymap {get;set;}
public Map<String, budgetactualwrapper> salarydisplaymap4 {get;set;}

public Map<String, Boolean> budgetcolumndisplaymap {get;set;}
public Map<String, Boolean> actualcolumndisplaymap {get;set;}

public Map<String, budgetactualwrapper> expensedisplaymap {get;set;}

private List<String> salarydisplaylist;
public List<String> salarydisplaylist2 {get;set;}

public List<String> expensedisplaylist {get;set;}
private List<String> sExpenseCategories {get;set;}
public List<String> sExpenseCategories2 {get;set;}

public Transient budgetactualwrapper TotalSalaries {get;set;}
public Transient budgetactualwrapper FringeBenefits {get;set;}
public Transient budgetactualwrapper SubTotalPersonnel {get;set;}

public Transient budgetactualwrapper SubTotalProgramExpenditures {get;set;}
public Transient budgetactualwrapper TotalDirectExpenditures {get;set;}
public Transient budgetactualwrapper AppliedOverhead {get;set;}
public Transient budgetactualwrapper TotalExpenditures {get;set;}

public Transient budgetactualwrapper Revenue {get;set;}
public Transient budgetactualwrapper Balance {get;set;}
public Transient budgetactualwrapper TotalCash {get;set;}

public Transient budgetactualwrapper StartingBalance {get;set;}

public String reportingYear {get;set;}

departmentUtility du;
private Id CAPContactId;
@TestVisible private boolean bUserHasAccess;
map<String, Budget_Settings__c> mBudgetSettings;

private final Project__c p;

public  String company1 {get; set;}
public String company2 {get; set;}
private String StartingBalanceCode;
public String sCurrentDataMonth {get;set;}
private List<String> datakeys;


public BudgetActualController (ApexPages.StandardController stdController) {
    this.p = (Project__c)stdController.getRecord();
    du = new departmentUtility();
    mBudgetSettings = Budget_Settings__c.getall();
    
    List<String> CompanyCodeList = mBudgetSettings.get('CompanyCodes').String_Value__c.split(';');
    company1 = CompanyCodeList[0];
        if (CompanyCodeList.size() > 1) {
           company2 = CompanyCodeList[1];
        }
    
    datakeys = new List<String> ();
    datakeys.add('Actual' + company1);
    datakeys.add('Budget' + company1);
    datakeys.add('Actual' + company2);
    datakeys.add('Budget' + company2);


        
    if (checkaccess()) {   //only process if user has access

        //Column Display Maps
        budgetcolumndisplaymap = new Map<String, Boolean> {company1 => FALSE, company2 => FALSE} ;
        actualcolumndisplaymap = new Map<String, Boolean> {company1 => FALSE, company2 => FALSE};

        //setupsampledata();
        TotalSalaries = new budgetactualwrapper ('Total Salaries');
    
        SubTotalPersonnel = new budgetactualwrapper ('Sub-total Personnel');
    
        SubTotalProgramExpenditures = new budgetactualwrapper ('Sub-total Program Expenditures');
    
        TotalDirectExpenditures = new budgetactualwrapper ('Total Direct Expenditures');
    
        TotalExpenditures = new budgetactualwrapper ('Total Expenditures');

        AppliedOverhead = new budgetactualwrapper ('Applied Overhead');

        Revenue = new budgetactualwrapper ('Revenue');
        Balance = new budgetactualwrapper ('Balance');
        StartingBalance = new budgetactualwrapper ('Starting Balance');

        TotalCash = new budgetactualwrapper ('Total Cash');

        buildsummarydata();
    }
} //end Constructor
    
private Boolean checkaccess () {
    bUserHasAccess = FALSE;

    if (GrantManagementUtilities.getloggedinusercontactid() != null) {
            
        Staff_Participation__c [] crelated = [Select Id, Access_Budget_Data__c 
                                          FROM Staff_Participation__c
                                          WHERE Project__c = :p.Id
                                          AND Contact__c = : GrantManagementUtilities.getloggedinusercontactid()];
        if (crelated.size() > 0) {
            for (Staff_Participation__c cr: crelated) {
                if (cr.Access_Budget_Data__c) {
                    bUserHasAccess = TRUE;
                    break;
                }
                                
             }
        }
    }
   
    if (!bUserHasAccess) {//only do this check if still false
        Id PermId;
        If (mBudgetSettings.containskey('PermissionSet') ) {
            PermId = mBudgetSettings.get('PermissionSet').Id_Value__c;
         
            PermissionSetAssignment [] p = [SELECT Id, PermissionSetId FROM PermissionSetAssignment
                                            WHERE AssigneeId = :userinfo.getuserid() AND 
                                                  PermissionSetId = :PermId];
            if (p.size() > 0) {
                bUserHasAccess = TRUE;
            }
        }       
    
    }   

    return bUserHasAccess;        
}
    
public pagereference confirmAccess() {
        
    if (bUserHasAccess) {   //User doesn't have contact id so can't confirm access
        return null;
    } else {
        //return new ApexPages.StandardController(cp).view();
        return page.BvAPermissionCheck;
    }    
}

private void buildsummarydata() {
    
    //To store dynamic query strings
    String squery;
    String sActual = 'Actual';
    String pCode = p.Project_Code__c;
    

    if (mBudgetSettings.containskey('StartingBalanceCode') ) {
        StartingBalanceCode = mBudgetSettings.get('StartingBalanceCode').String_Value__c;
    }

    if (mBudgetSettings.containskey('CurrentDataMonth') ) {
        sCurrentDataMonth = mBudgetSettings.get('CurrentDataMonth').String_Value__c;
    }


//Set Reporting Year Value
AggregateResult [] sYear = [Select MAX(Year__c) maxyear from Accounting_data_load__c WHERE Project_Code__c = '811'];

if (sYear.size() > 0) {
    reportingYear = (String)sYear[0].get('maxyear');
}
else {
    reportingYear = String.valueof(system.today());
}    

    //salarywrapper = new List<budgetactualwrapper> ();
    expenseswrapper = new List<budgetactualwrapper> ();
    String FringeBenefitCategory;
    String AppliedOverHeadCategory;
    String OperationalOverHeadCategory;
    
    //Build Accounting Category Map
    Map <String, String> acmap = new Map<String, String> ();
    sExpenseCategories = new List<String> ();

    Set<String> sSalaryCodes = new Set<String> ();
    Set<String> sFringeBenefitCodes = new Set<String> ();
    Set<String> sExpenseCodes = new Set<String> ();
    Set<String> sOverheadCodes = new Set<String> ();
    Set<String> sRevenueCodes = new Set<String> ();

    //Set up Codes and Categories  
    for (Accounting_Category__c a:
          [Select Id, Name, Category_Code__c, 
            (Select Name from Accounting_Codes__r WHERE Include_on_Budget_Report__c = TRUE) 
            FROM Accounting_Category__c ORDER BY Display_Order__c ASC]) {

        //we only care about Categories with Codes for inclusion
        if (a.Accounting_Codes__r.size() > 0) {
    
            //to enable ordering of expenses categories on page, since they are returned in order
            if (a.Category_Code__c == 'EXPENSE') {
                sExpenseCategories.add(a.Name);
            }
    
            //Build Lookup Maps

            for (Accounting_Code__c ac: a.Accounting_Codes__r) {
                acmap.put (ac.Name, a.Name);
    
                if (a.Category_Code__c == 'EXPENSE') {
                    sExpenseCodes.add(ac.name);
                } else if (a.Category_Code__c == 'REVENUE') {
                    sRevenueCodes.add(ac.name);
                } else if (a.Category_Code__c == 'SALARY') {
                    sSalaryCodes.add(ac.name);
                } else if (a.Category_Code__c == 'OVERHEAD') {
                
                    sOverheadCodes.add(ac.name);
                    sExpenseCodes.add(ac.name);
                    AppliedOverHeadCategory = a.Name;

                } else if (a.Category_Code__c == 'FRINGE BENEFIT') {
                    FringeBenefitCategory = a.Name;            
                    if (p.Display_Fringe_Benefits_Separately__c) {//keep separate from Salary
                        sExpenseCodes.add(ac.name);
                    } else  {
                        sSalaryCodes.add(ac.name);
                    }
                }

            }

        }

    } //end category loop


    // jrb 20130926 attempt to extract starting balance

    Map<String, Decimal> startingBalanceMap = new Map<String, Decimal> ();
    if (p.Use_YTD_Report__c) {
        AggregateResult[] startingbalanceresults = [SELECT Org_Code__c oc, SUM(Total__c) stbal
                                                 FROM Accounting_Data_Load__C 
                                                 WHERE Project_Code__c = :p.Project_Code__c AND 
                                                 Account_Code__c = :StartingBalanceCode AND
                                                 Year__c != :reportingYear
                                                 GROUP BY Org_Code__c];

        for (AggregateResult sb : startingbalanceresults)  {
            startingBalanceMap.put((String)sb.get('oc'), (Decimal)sb.get('stbal') );
        }

    }


    //Build Revenue Results first
    AggregateResult[] revenueresults;
        squery = 'SELECT Org_Code__c oc, SUM(Total__c) amt ' +
                            ' FROM  Accounting_Data_Load__c ' +
                            ' WHERE Project_Code__c = :pCode AND ' +
                            ' Account_Code__c IN :sRevenueCodes  AND ' +
                            ' Type__c = :sActual ';
        
        if (p.Use_YTD_Report__c) {
                     squery += ' AND Year__c = :reportingYear';
        }
        
        squery += ' GROUP BY Org_Code__c';

    revenueresults = database.query(squery);

    Map<String, Decimal> revenueMap = new Map<String, Decimal> ();

    for (AggregateResult ar : revenueresults)  {
        revenueMap.put((String)ar.get('oc'), (Decimal)ar.get('amt') );
    }

    system.debug('RM' + revenueMap);
    system.debug('RC' + sSalaryCodes);
    //Build Salary Results first
    AggregateResult[] salaryresults;
    
    squery = 'SELECT Department_Code__c dc, Type__c type, ' + 
                            'Org_Code__c oc, SUM(Total__c) amt ' +
                    ' FROM Accounting_Data_Load__c ' + 
                    ' WHERE Project_Code__c = :pCode AND ' +
                    '       Account_Code__c IN :sSalaryCodes ';
                
                if (p.Use_YTD_Report__c) {
                    squery += ' AND  Type__c = :sActual ' + 
                              ' AND Year__c = :reportingYear ';
                }

                squery += ' GROUP BY Org_Code__c, Department_Code__c, Type__c ' + 
                          ' ORDER BY SUM(Total__c) DESC';

    salaryresults = database.query(squery);

    Map<String,Map<String, Decimal> > agresultssalaries = new Map<String, Map<String, Decimal> > ();
      
      
    String sKey;
    Set<String> SalaryDisplaySet = new Set<String> ();
    salarydisplaylist = new List<String> ();

    salarydisplaymap = new Map <String, budgetactualwrapper> ();
    
    for (AggregateResult ar : salaryresults)  {
 
        //Get Department Code
        String sDept = (String)ar.get('dc');
                
        //Try and resolve with Departmeny Name Map
        if (du.getCodeMap().containskey(sDept)) {
            sDept = du.getCodeMap().get(sDept).Name;
        }
              
        sKey = 'Salaries - ' + sDept; 
                
        salaryDisplayList.add(sKey);
           
        //We use a map to store budget and actual from results   
        Map<String, Decimal> salmap;
              
        if (agresultssalaries.containskey(sKey) ) {
            salmap = agresultssalaries.get(sKey);
        } else {       
            salmap = new Map<String, Decimal> ();
        } 
                    
        String salMapKey = (String)ar.get('type') + (String)ar.get('oc'); 
        if (salmap.containskey(salMapKey) ) {
            salmap.put(salMapKey, salmap.get(salMapKey) + (Decimal)ar.get('amt') );
        } else {
            salmap.put( salMapKey, (Decimal)ar.get('amt') );
        }
               
               
        agresultssalaries.put(skey, salmap);
    }
        

    for (String s: agresultssalaries.keyset() ) {
           
        Map<String, Decimal> agloopmap = agresultssalaries.get(s);
        Decimal dActual1 = 0;
        Decimal dBudget1 = 0;
        Decimal dActual2 = 0;
        Decimal dBudget2 = 0;
        
        if (agloopmap.containskey(datakeys[0]) ) {
            dActual1 = agloopmap.get(datakeys[0]);
            if (dActual1 > 0 ) {
                actualcolumndisplaymap.put(company1,TRUE);
            }
        }
        if (agloopmap.containskey(datakeys[1])) {
            dBudget1 = agloopmap.get(datakeys[1]);
            if (dBudget1 > 0 ) {
                budgetcolumndisplaymap.put(company1,TRUE);
            }
        }
        if (agloopmap.containskey(datakeys[2]) ) {
            dActual2 = agloopmap.get(datakeys[2]);
            if (dActual2 > 0 ) {
                actualcolumndisplaymap.put(company2,TRUE);
            }
        }
        if (agloopmap.containskey(datakeys[3])) {
            dBudget2 = agloopmap.get(datakeys[3]);
            if (dBudget2 > 0 ) {
                budgetcolumndisplaymap.put(company2,TRUE);
            }
        }
              
        budgetactualwrapper tSal = new budgetactualwrapper(s,p.Use_YTD_Report__c);
       
        tSal.updateValues (dBudget1, dActual1,  dBudget2, dActual2);                      
        salarydisplaymap.put(s, tSal);
                    
        TotalSalaries.updateValues (dBudget1, dActual1,  dBudget2, dActual2);                      
        SubTotalPersonnel.updateValues (dBudget1, dActual1,  dBudget2, dActual2);                      
        
        if (p.Use_YTD_Report__c) {
            TotalSalaries.brevenuebalance = True; 
            SubTotalPersonnel.brevenuebalance = True; 
        }
                    
    }

    //remove dupes from Salary List
    Set<String> myset = new Set<String>();
    salaryDisplayList2 = new List<String>();
    for (String s : salaryDisplayList) {
        if (myset.add(s)) {
            salaryDisplayList2.add(s);
        }
    }

//Now Process Expenses
    Map<String,Map<String, Decimal> > agresultsexpenses = new Map<String, Map<String, Decimal> > ();
   
    expensedisplaymap = new Map <String, budgetactualwrapper> ();
    Set<String> sCategoriesUsed = new Set<String> ();
 
    String aCode; 
    AggregateResult[] ExpenseResults;
    
    sQuery = ' SELECT Account_Code__c ac, Type__c type, Org_Code__c oc, SUM(Total__c) amt ' +
               ' FROM Accounting_Data_Load__c ' + 
               ' WHERE Project_Code__c = :pCode AND ';

    if (p.Use_YTD_Report__c) {
               
    sQuery +=  ' Year__c = :reportingYear AND ' +
               ' Type__c = :sActual AND ';
    }           
    
    sQuery +=  ' Account_Code__c IN :sExpenseCodes '  +
               ' GROUP BY Org_Code__c, Account_Code__c, Type__c  ' +
               ' ORDER BY SUM(Total__c) DESC ';


    ExpenseResults = database.query(sQuery);

    for (AggregateResult ar : ExpenseResults)  {
        aCode = 'Unknown';
    
        if (acmap.containskey( (String)ar.get('ac') ) ) {
            aCode = acmap.get ( (String)ar.get('ac') );
        }
                            
        sKey = aCode;  
        sCategoriesUsed.add(aCode);
      
        Map<String, Decimal> salmap;
      
            if (agresultsexpenses.containskey(sKey) ) {
                salmap = agresultsexpenses.get(sKey);
            } else {
                salmap = new Map<String, Decimal> ();
            }    
                
        String salMapKey = (String)ar.get('type') + (String)ar.get('oc'); 
      
            if (salmap.containskey(salMapKey) ) {
                salmap.put(salMapKey, salmap.get(salMapKey) + (Decimal)ar.get('amt') );
            } else {
                salmap.put( salMapKey, (Decimal)ar.get('amt') );
            }
                
        agresultsexpenses.put(skey, salmap);
    }
    
    for (String s: agresultsexpenses.KeySet()) {

           
        Map<String, Decimal> agloopmap = agresultsexpenses.get(s);
        Decimal dActual1 = 0;
        Decimal dBudget1 = 0;
        Decimal dActual2 = 0;
        Decimal dBudget2 = 0;


        if (agloopmap.containskey(datakeys[0]) ) {
            dActual1 = agloopmap.get(datakeys[0]);
            if (dActual1 > 0 ) {
                actualcolumndisplaymap.put(company1,TRUE);
            }
        }
        if (agloopmap.containskey(datakeys[1])) {
            dBudget1 = agloopmap.get(datakeys[1]);
            if (dBudget1 > 0 ) {
                budgetcolumndisplaymap.put(company1,TRUE);
            }
        }
        if (agloopmap.containskey(datakeys[2]) ) {
            dActual2 = agloopmap.get(datakeys[2]);
            if (dActual2 > 0 ) {
                actualcolumndisplaymap.put(company2,TRUE);
            }
        }
        if (agloopmap.containskey(datakeys[3])) {
            dBudget2 = agloopmap.get(datakeys[3]);
            if (dBudget2 > 0 ) {
                budgetcolumndisplaymap.put(company2,TRUE);
            }
        }
                
        if (s.equals(FringeBenefitCategory)) {
            FringeBenefits = new budgetactualwrapper ( 
            FringeBenefitCategory,  p.Use_YTD_Report__c);
           
            FringeBenefits.updateValues (dBudget1, dActual1,  dBudget2, dActual2);  
           
            SubTotalPersonnel.updateValues (dBudget1, dActual1,  dBudget2, dActual2);  
                
        } else if (s.equals(AppliedOverHeadCategory)) {
            AppliedOverhead.slabel = AppliedOverHeadCategory;
            AppliedOverhead.updateValues (dBudget1, dActual1,  dBudget2, dActual2);  
            
        } else if (s.equals(OperationalOverHeadCategory)) {
            AppliedOverhead.updateValues (dBudget1, dActual1,  dBudget2, dActual2);  
            
        } else {
           
               budgetactualwrapper tExp = new budgetactualwrapper(s,p.Use_YTD_Report__c);
               tExp.updateValues (dBudget1, dActual1,  dBudget2, dActual2);  
            
               expensedisplaymap.put(s, tExp);
               SubTotalProgramExpenditures.updateValues (dBudget1, dActual1,  dBudget2, dActual2);  
                              
        }
        if (p.Use_YTD_Report__c) {
            SubTotalProgramExpenditures.brevenuebalance = True; 
            AppliedOverhead.brevenuebalance = True; 
            SubTotalPersonnel.brevenuebalance = True; 
        }

                
    }

    sExpenseCategories2 = new List<String>();
    //Remove unused Categories
    for (String s: sExpenseCategories) {
        if (sCategoriesUsed.contains(s)) {
            sExpenseCategories2.add(s);
        }

    }
      
       
    TotalDirectExpenditures.ibudget1 += SubTotalProgramExpenditures.ibudget1 + SubTotalPersonnel.ibudget1;                   
    TotalDirectExpenditures.iactual1 += SubTotalProgramExpenditures.iactual1 +  SubTotalPersonnel.iactual1;
    TotalDirectExpenditures.ibudget2 += SubTotalProgramExpenditures.ibudget2 + SubTotalPersonnel.ibudget2;                   
    TotalDirectExpenditures.iactual2 += SubTotalProgramExpenditures.iactual2 +  SubTotalPersonnel.iactual2;
        
    TotalExpenditures.ibudget1 +=  TotalDirectExpenditures.ibudget1 + AppliedOverhead.ibudget1;
    TotalExpenditures.iactual1 +=  TotalDirectExpenditures.iactual1 + AppliedOverhead.iactual1;
    TotalExpenditures.ibudget2 +=  TotalDirectExpenditures.ibudget2 + AppliedOverhead.ibudget2;
    TotalExpenditures.iactual2 +=  TotalDirectExpenditures.iactual2 + AppliedOverhead.iactual2;


    Revenue.brevenuebalance = True;                
    Revenue.ibudget1 =  TotalExpenditures.ibudget1;

    if (revenueMap.containskey(company1)) {
        Revenue.iactual1 =  revenueMap.get(company1) * -1;
    }

    Revenue.ibudget2 =  TotalExpenditures.ibudget2;
    
    if (revenueMap.containskey(company2)) {
        Revenue.iactual2 =  revenueMap.get(company2) * -1;
    }    


// jrb 20130929 don't display budget columns on ytd reports
    if (p.Use_YTD_Report__c) {
        budgetcolumndisplaymap.put(company1,FALSE);        
        budgetcolumndisplaymap.put(company2,FALSE);        
    }

    if (p.Use_YTD_Report__c) {
        StartingBalance.brevenuebalance = True;                
        if (startingBalanceMap.containskey(company1)) {
            StartingBalance.iactual1 = startingBalanceMap.get(company1) * -1;
        }
        if (StartingBalanceMap.containskey(company2)) {
            StartingBalance.iactual2 = startingBalanceMap.get(company2) * -1;
        }
        StartingBalance.ibudget1 = 0;
        StartingBalance.ibudget2 = 0;
    } else {
       
        StartingBalance.iactual1 = 0;
        StartingBalance.iactual2 = 0;
        StartingBalance.ibudget1 = 0;
        StartingBalance.ibudget2 = 0;
    }
    StartingBalance.brevenuebalance = True;

    TotalCash.brevenuebalance = True;                
    TotalCash.ibudget1 =  0;
    TotalCash.iactual1 =  Revenue.iactual1 + StartingBalance.iactual1;
    TotalCash.ibudget2 =  0;
    TotalCash.iactual2 =  Revenue.iactual2 + StartingBalance.iactual2;

    Balance.brevenuebalance = True;                
    Balance.ibudget1 =  Revenue.ibudget1 - TotalExpenditures.ibudget1;
    Balance.iactual1 =  Revenue.iactual1 - TotalExpenditures.iactual1 + StartingBalance.iactual1;
    Balance.ibudget2 =  Revenue.ibudget2 - TotalExpenditures.ibudget2;
    Balance.iactual2 =  Revenue.iactual2 - TotalExpenditures.iactual2 + StartingBalance.iactual2;

//  jrb 20130928: on ytd report, sum c3 and c4 expenses and call the column 'Total'
//    hack is to set .brevenuebalance = True
    if (p.Use_YTD_Report__c) {
        TotalDirectExpenditures.brevenuebalance = True;
        TotalExpenditures.brevenuebalance = True;

    }
    
} //end method


}