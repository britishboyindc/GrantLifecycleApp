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

@isTest
private class BudgetActual_TEST {
     
    @isTest
    static void NoAccessBudgetActualOnlyC3() {
    //Test with no Contact to User Setup
   

    Account ouraccount = TestDataFactory_TEST.setupNewAccount (TRUE, 'Test Our Account');
    TestDataFactory_TEST.setupOrgSettings(FALSE, ouraccount.Id);
    TestDataFactory_TEST.setupBudgetSettings(FALSE, NULL, '3;4;');

    List<Department__c> testDepartments = TestDataFactory_TEST.setupDepartments();

    Account testa = TestDataFactory_TEST.setupNewAccount (TRUE, 'Test New Account');
    
    Contact c = new Contact (AccountId = ouraccount.Id, FirstName = 'Peter', LastName = 'Test Contact1', gm_Related_User_Record__c = userinfo.getuserid(), gm_Department__c  = testDepartments[0].Id);
    insert c;

    Contact c2 = new Contact (AccountId = ouraccount.Id, LastName = 'Test Contact2', gm_Department__c  = testDepartments[2].Id);
    insert c2;

    Project__c testProject = TestDataFactory_TEST.setupNewProject(FALSE, 'Project 1');
    testProject.Project_Code__c = '999'; 
    testProject.Display_Fringe_Benefits_Separately__c = TRUE;
    testProject.Use_YTD_Report__c = FALSE;
    insert testProject;
    
    PageReference pageRef = Page.BudgetvsActual;
    Test.setCurrentPage(pageRef);
    BudgetActualController bfc = new BudgetActualController(new ApexPages.StandardController(testProject)); 
    system.assertequals('/apex/' + UTIL_Namespace.StrTokenNSPrefix('bvapermissioncheck'), bfc.confirmaccess().geturl());
    system.assertequals(FALSE, bfc.bUserHasAccess);
    }
    
    //@isTest
    static void HasAccessviaInvolvmentBudgetActualOnlyC3() {
    //Test User has contact but No Access
      Contact c = new Contact (LastName = 'CAP Staffer');
      insert c;
        
      Id UserId = userinfo.getuserid();
      Id ProfileId = [SELECT Id FROM Profile WHERE Name='System Administrator'].Id; 
      User u = new User(Alias = 'standt', Email='testadmin@bfcclient.com', 
      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
      LocaleSidKey='en_US', ProfileId = ProfileId, 
      TimeZoneSidKey='America/Los_Angeles', UserName='testadmin@bfcclient.com');
      system.runAs(u) { 
      User cu = new User  (Id = UserId, Contact_ID__c = c.Id);
      update cu;
      }
        
    Project__c p = new Project__c ();
    p.Name = 'Test P 1';
    p.Project_Code__c = '999'; 
    p.Display_Fringe_Benefits_Separately__c = TRUE;
    p.Use_YTD_Report__c = FALSE;
    insert p;
        
    Staff_Participation__c cr = new Staff_Participation__c(
        Access_Budget_Data__c = TRUE,
        Project__c = p.Id,
        Contact__c = c.Id);
        insert cr;
                
    PageReference pageRef = Page.BudgetvsActual;
    Test.setCurrentPage(pageRef);
    budgetactualcontroller bfc = new budgetactualcontroller(new ApexPages.StandardController(p));
    system.assertequals(TRUE, bfc.bUserHasAccess);
    }
    
@isTest
static void BudgetActualBoth() {
    
    Account ouraccount = TestDataFactory_TEST.setupNewAccount (TRUE, 'Test Our Account');
    TestDataFactory_TEST.setupOrgSettings(FALSE, ouraccount.Id);

    List<Department__c> testDepartments = TestDataFactory_TEST.setupDepartments();

    Account testa = TestDataFactory_TEST.setupNewAccount (TRUE, 'Test New Account');

    Contact c = new Contact (AccountId = ouraccount.Id, FirstName = 'Peter', LastName = 'Test Contact1', gm_Related_User_Record__c = userinfo.getuserid(), gm_Department__c  = testDepartments[0].Id);
    insert c;
        
    // This code runs as the system user
    Id UserId = userinfo.getuserid();
    User cu = new User (Id = USerId, Contact_ID__c = c.Id);
    update cu;

    User u = TestDataFactory_TEST.CreateTestUser('grantdev1testscriptuser@bfcclient.com');
    system.runAs(u) {  
        PermissionSet ps = new PermissionSet (Name = 'Test_BvA_Access', Label = 'Test BvA Access' );
        insert ps;
        PermissionSetAssignment p = new PermissionSetAssignment ( PermissionSetId = ps.Id, AssigneeId = UserId);
        insert p;
        TestDataFactory_TEST.setupBudgetSettings(FALSE, ps.Id, '3;4;');
    }

    Project__c p = TestDataFactory_TEST.setupNewProject(FALSE, 'Test P 1');
    p.Project_Code__c = '823'; 
    p.Display_Fringe_Benefits_Separately__c = TRUE;
    p.Use_YTD_Report__c = FALSE;
    p.Include_Operational_Overhead_in_Expense__c = FALSE;
    insert p;
     
    //Have to requery to get back rollup fields
    Project__c testp = [Select Id, Name, Project_Code__c, 
                              Display_Fringe_Benefits_Separately__c,
                              Use_YTD_Report__c,
                              Include_Operational_Overhead_in_Expense__c
                              FROM Project__c 
                              WHERE Id = :p.Id]; 


    TestDataFactory_TEST.setAccountingData();

    if (UTIL_Namespace.InManagedPackage) {
        List<sObject> testAData = Test.loadData(Accounting_Data_Load__c.sObjectType, 'AccountingTestData1_managed');
    } else {
        List<sObject> testAData = Test.loadData(Accounting_Data_Load__c.sObjectType, 'AccountingTestData1');
    }
    //List<sObject> testBData = Test.loadData(Accounting_Data_Load__c.sObjectType, 'BudgetC3Data');

    PageReference pageRef = Page.BudgetvsActual;
    Test.setCurrentPage(pageRef);
    budgetactualcontroller bfc = new budgetactualcontroller(new ApexPages.StandardController(testp)); 
    bfc.confirmaccess();
    system.assertequals(TRUE, bfc.bUserHasAccess);
    
   
    //Test Salary Display
        BudgetActualWrapper baw = bfc.salarydisplaymap.get('Salaries - Child 1');
        system.assertequals(TRUE, baw.getbdisplay() );   
        system.assertequals('Salaries - Child 1', baw.sLabel   );   
        system.assertequals(295750, baw.getiBudget1()  );   
        system.assertequals(99891, baw.getiActual1()  );   
        system.assertequals(6338, baw.getiBudget2() );   
        system.assertequals(5904, baw.getiActual2() );   
        system.assertequals(196293, baw.getiremaining() );  

        baw = bfc.expensedisplaymap.get('Travel');
        system.assertequals(TRUE, baw.getbdisplay() );   
        system.assertequals('Travel', baw.sLabel   );   
        system.assertequals(9750, baw.getiBudget1()  );   
        system.assertequals(1881, baw.getiActual1()  );   
        system.assertequals(0, baw.getiBudget2() );   
        system.assertequals(1114, baw.getiActual2() );   
        system.assertequals(6755, baw.getiremaining() );  

        budgetactualwrapper testbaw = bfc.FringeBenefits;
        system.assertequals(TRUE, testbaw.getbdisplay() );   
        system.assertequals('Fringe Benefits', testbaw.sLabel   );   
        system.assertequals(55800, testbaw.getiBudget1()  );   
        system.assertequals(18700, testbaw.getiActual1()  );   
        system.assertequals(1318, testbaw.getiBudget2() );   
        system.assertequals(1230, testbaw.getiActual2() );   
        system.assertequals(37188, testbaw.getiremaining() ); 

        testbaw = bfc.SubTotalPersonnel;
        system.assertequals(TRUE, testbaw.getbdisplay() );   
        system.assertequals('Sub-total Personnel', testbaw.sLabel   );   
        system.assertequals(360000, testbaw.getiBudget1()  );   
        system.assertequals(120877, testbaw.getiActual1()  );   
        system.assertequals(8501, testbaw.getiBudget2() );   
        system.assertequals(7328, testbaw.getiActual2() );   
        system.assertequals(240296, testbaw.getiremaining() ); 

        testbaw = bfc.SubTotalProgramExpenditures;
        system.assertequals(TRUE, testbaw.getbdisplay() );   
        system.assertequals('Sub-total Program Expenditures', testbaw.sLabel   );   
        system.assertequals(9750, testbaw.getiBudget1()  );   
        system.assertequals(3251, testbaw.getiActual1()  );   
        system.assertequals(0, testbaw.getiBudget2() );   
        system.assertequals(1129, testbaw.getiActual2() );   
        system.assertequals(5370, testbaw.getiremaining() ); 

        testbaw = bfc.TotalDirectExpenditures;
        system.assertequals(TRUE, testbaw.getbdisplay() );   
        system.assertequals('Total Direct Expenditures', testbaw.sLabel   );   
        system.assertequals(369750, testbaw.getiBudget1()  );   
        system.assertequals(124128, testbaw.getiActual1()  );   
        system.assertequals(8501, testbaw.getiBudget2() );   
        system.assertequals(8457, testbaw.getiActual2() );   
        system.assertequals(245666, testbaw.getiremaining() ); 

        testbaw = bfc.AppliedOverhead;
        system.assertequals(TRUE, testbaw.getbdisplay() );   
        system.assertequals('Applied Grant Overhead', testbaw.sLabel   );   
        system.assertequals(65250, testbaw.getiBudget1()  );   
        system.assertequals(19619, testbaw.getiActual1()  );   
        system.assertequals(1500,testbaw.getiBudget2() );   
        system.assertequals(1211, testbaw.getiActual2() );   
        system.assertequals(45920, testbaw.getiremaining() ); 

        testbaw = bfc.TotalExpenditures;
        system.assertequals(TRUE, testbaw.getbdisplay() );   
        system.assertequals('Total Expenditures', testbaw.sLabel   );   
        system.assertequals(435000, testbaw.getiBudget1()  );   
        system.assertequals(143747, testbaw.getiActual1()  );   
        system.assertequals(10001, testbaw.getiBudget2() );   
        system.assertequals(9668, testbaw.getiActual2() );   
        system.assertequals(291586, testbaw.getiremaining() ); 

        testbaw = bfc.Revenue;
        system.assertequals(TRUE, testbaw.getbdisplay() );   
        system.assertequals('Revenue', testbaw.sLabel   );   
        system.assertequals(435000, testbaw.getiBudget1()  );   
        system.assertequals(435000, testbaw.getiActual1()  );   
        system.assertequals(10001, testbaw.getiBudget2() );   
        system.assertequals(10000, testbaw.getiActual2() );   
        system.assertequals(-1, testbaw.getiremaining() ); 
    
}
    
@isTest
static void BudgetActualReportingYearTest() {
    
    Account ouraccount = TestDataFactory_TEST.setupNewAccount (TRUE, 'Test Our Account');
    TestDataFactory_TEST.setupOrgSettings(FALSE, ouraccount.Id);

    List<Department__c> testDepartments = TestDataFactory_TEST.setupDepartments();

    Account testa = TestDataFactory_TEST.setupNewAccount (TRUE, 'Test New Account');
    
    Contact c = new Contact (AccountId = ouraccount.Id, FirstName = 'Peter', LastName = 'Test Contact1', gm_Related_User_Record__c = userinfo.getuserid(), gm_Department__c  = testDepartments[0].Id);
    insert c;
    
      // This code runs as the system user
      Id UserId = userinfo.getuserid();
      User cu = new User (Id = USerId, Contact_ID__c = c.Id);
      update cu;
      
      User u = TestDataFactory_TEST.CreateTestUser('grantdev1testscriptuser@bfcclient.com');
      system.runAs(u) {  
            PermissionSet ps = new PermissionSet (Name = 'Test_BvA_Access', Label = 'Test BvA Access' );
            insert ps;
            PermissionSetAssignment p = new PermissionSetAssignment ( PermissionSetId = ps.Id, AssigneeId = UserId);
            insert p;
            TestDataFactory_TEST.setupBudgetSettings(FALSE, ps.Id, 'C3;');
     }
    
    Project__c p = TestDataFactory_TEST.setupNewProject(FALSE, 'Test P 1');
    p.Project_Code__c = '811'; 
    p.Display_Fringe_Benefits_Separately__c = FALSE;
    p.Use_YTD_Report__c = TRUE;
    p.Include_Operational_Overhead_in_Expense__c = FALSE;
    insert p;
     
    //Have to requery to get back rollup fields
    Project__c testp = [Select Id, Name, Project_Code__c, 
                              Display_Fringe_Benefits_Separately__c,
                              Use_YTD_Report__c,
                              Include_Operational_Overhead_in_Expense__c
                              FROM Project__c 
                              WHERE Id = :p.Id]; 


    TestDataFactory_TEST.setAccountingData();
   
    if (UTIL_Namespace.InManagedPackage) { 
        List<sObject> testAData = Test.loadData(Accounting_Data_Load__c.sObjectType, 'ADLData811_managed');
    } else {
        List<sObject> testAData = Test.loadData(Accounting_Data_Load__c.sObjectType, 'ADLData811');
    }
   
    PageReference pageRef = Page.BudgetvsActual;
    Test.setCurrentPage(pageRef);
    budgetactualcontroller bfc = new budgetactualcontroller(new ApexPages.StandardController(testp)); 
    bfc.confirmaccess();
    system.assertequals(TRUE, bfc.bUserHasAccess);
  
    system.debug(bfc.salarydisplaymap);   
    
    
    //Test Salary Display
        BudgetActualWrapper testbaw = bfc.salarydisplaymap.get('Salaries - Child 2a');
        system.assertequals(TRUE, testbaw.getbdisplay() );   
        system.assertequals('Salaries - Child 2a', testbaw.sLabel   );   
        system.assertequals(0, testbaw.getiBudget1()  );   
        system.assertequals(35146, testbaw.getiActual1()  );   
        system.assertequals(0, testbaw.getiBudget2() );   
        system.assertequals(0, testbaw.getiActual2() );   
   
   //Test Expense Display
        testbaw = bfc.expensedisplaymap.get('Consulting');
        system.assertequals(TRUE, testbaw.getbdisplay() );   
        system.assertequals('Consulting', testbaw.sLabel   );   
        system.assertequals(0, testbaw.getiBudget1()  );   
        system.assertequals(42200, testbaw.getiActual1()  );   
        system.assertequals(0, testbaw.getiBudget2() );   
        system.assertequals(0, testbaw.getiActual2() );   
   
    
        testbaw = bfc.SubTotalPersonnel;
        system.assertequals(TRUE, testbaw.getbdisplay() );   
        system.assertequals('Sub-total Personnel', testbaw.sLabel   );   
        system.assertequals(0, testbaw.getiBudget1()  );   
        system.assertequals(69411, testbaw.getiActual1()  );   
        system.assertequals(0, testbaw.getiBudget2() );   
        system.assertequals(0, testbaw.getiActual2() );   
        system.assertequals(69411, testbaw.getiremaining() ); 

        testbaw = bfc.SubTotalProgramExpenditures;
        system.assertequals(TRUE, testbaw.getbdisplay() );   
        system.assertequals('Sub-total Program Expenditures', testbaw.sLabel   );   
        system.assertequals(0, testbaw.getiBudget1()  );   
        system.assertequals(42200, testbaw.getiActual1()  );   
        system.assertequals(0, testbaw.getiBudget2() );   
        system.assertequals(0, testbaw.getiActual2() );   
        system.assertequals(42200, testbaw.getiremaining() ); 

        testbaw = bfc.TotalDirectExpenditures;
        system.assertequals(TRUE, testbaw.getbdisplay() );   
        system.assertequals('Total Direct Expenditures', testbaw.sLabel   );   
        system.assertequals(0, testbaw.getiBudget1()  );   
        system.assertequals(111611, testbaw.getiActual1()  );   
        system.assertequals(0, testbaw.getiBudget2() );   
        system.assertequals(0, testbaw.getiActual2() );   
        system.assertequals(111611, testbaw.getiremaining() ); 

        testbaw = bfc.AppliedOverhead;
        system.assertequals(TRUE, testbaw.getbdisplay() );   
        system.assertequals('Applied Grant Overhead', testbaw.sLabel   );   
        system.assertequals(0, testbaw.getiBudget1()  );   
        system.assertequals(10411, testbaw.getiActual1()  );   
        system.assertequals(0,testbaw.getiBudget2() );   
        system.assertequals(0, testbaw.getiActual2() );   
        system.assertequals(10411, testbaw.getiremaining() ); 

        testbaw = bfc.TotalExpenditures;
        system.assertequals(TRUE, testbaw.getbdisplay() );   
        system.assertequals('Total Expenditures', testbaw.sLabel   );   
        system.assertequals(0, testbaw.getiBudget1()  );   
        system.assertequals(122022, testbaw.getiActual1()  );   
        system.assertequals(0, testbaw.getiBudget2() );   
        system.assertequals(0, testbaw.getiActual2() );   
        system.assertequals(122022, testbaw.getiremaining() ); 

        

}   
    
@isTest
static void BudgetActualReportingYearTestCompany2() {
    
    Account ouraccount = TestDataFactory_TEST.setupNewAccount (TRUE, 'Test Our Account');
    TestDataFactory_TEST.setupOrgSettings(FALSE, ouraccount.Id);

    List<Department__c> testDepartments = TestDataFactory_TEST.setupDepartments();

    Account testa = TestDataFactory_TEST.setupNewAccount (TRUE, 'Test New Account');
    
    Contact c = new Contact (AccountId = ouraccount.Id, FirstName = 'Peter', LastName = 'Test Contact1', gm_Related_User_Record__c = userinfo.getuserid(), gm_Department__c  = testDepartments[0].Id);
    insert c;
    
      // This code runs as the system user
      Id UserId = userinfo.getuserid();
      User cu = new User (Id = USerId, Contact_ID__c = c.Id);
      update cu;
      
      User u = TestDataFactory_TEST.CreateTestUser('grantdev1testscriptuser@bfcclient.com');
      system.runAs(u) {  
            PermissionSet ps = new PermissionSet (Name = 'Test_BvA_Access', Label = 'Test BvA Access' );
            insert ps;
            PermissionSetAssignment p = new PermissionSetAssignment ( PermissionSetId = ps.Id, AssigneeId = UserId);
            insert p;
            TestDataFactory_TEST.setupBudgetSettings(FALSE, ps.Id, 'C2;C3;');
     }
    
    Project__c p = TestDataFactory_TEST.setupNewProject(FALSE, 'Test P 1');
    p.Project_Code__c = '811'; 
    p.Display_Fringe_Benefits_Separately__c = FALSE;
    p.Use_YTD_Report__c = TRUE;
    p.Include_Operational_Overhead_in_Expense__c = FALSE;
    insert p;
     
    //Have to requery to get back rollup fields
    Project__c testp = [Select Id, Name, Project_Code__c, 
                              Display_Fringe_Benefits_Separately__c,
                              Use_YTD_Report__c,
                              Include_Operational_Overhead_in_Expense__c
                              FROM Project__c 
                              WHERE Id = :p.Id]; 


    TestDataFactory_TEST.setAccountingData();
    
    if (UTIL_Namespace.InManagedPackage) { 
        List<sObject> testAData = Test.loadData(Accounting_Data_Load__c.sObjectType, 'ADLData811_managed');
    } else {
        List<sObject> testAData = Test.loadData(Accounting_Data_Load__c.sObjectType, 'ADLData811');
    }
   
    PageReference pageRef = Page.BudgetvsActual;
    Test.setCurrentPage(pageRef);
    budgetactualcontroller bfc = new budgetactualcontroller(new ApexPages.StandardController(testp)); 
    bfc.confirmaccess();
    system.assertequals(TRUE, bfc.bUserHasAccess);
  
    system.debug(bfc.salarydisplaymap);   
    
    
    //Test Salary Display
        BudgetActualWrapper testbaw = bfc.salarydisplaymap.get('Salaries - Child 2a');
        system.assertequals(TRUE, testbaw.getbdisplay() );   
        system.assertequals('Salaries - Child 2a', testbaw.sLabel   );   
        system.assertequals(0, testbaw.getiBudget1()  );   
        system.assertequals(0, testbaw.getiActual1()  );   
        system.assertequals(0, testbaw.getiBudget2() );   
        system.assertequals(35146, testbaw.getiActual2() );   
   
   //Test Expense Display
        testbaw = bfc.expensedisplaymap.get('Consulting');
        system.assertequals(TRUE, testbaw.getbdisplay() );   
        system.assertequals('Consulting', testbaw.sLabel   );   
        system.assertequals(0, testbaw.getiBudget1()  );   
        system.assertequals(0, testbaw.getiActual1()  );   
        system.assertequals(0, testbaw.getiBudget2() );   
        system.assertequals(42200, testbaw.getiActual2() );   
   
    
        testbaw = bfc.SubTotalPersonnel;
        system.assertequals(TRUE, testbaw.getbdisplay() );   
        system.assertequals('Sub-total Personnel', testbaw.sLabel   );   
        system.assertequals(0, testbaw.getiBudget1()  );   
        system.assertequals(0, testbaw.getiActual1()  );   
        system.assertequals(0, testbaw.getiBudget2() );   
        system.assertequals(69411, testbaw.getiActual2() );   
        system.assertequals(69411, testbaw.getiremaining() ); 

        testbaw = bfc.SubTotalProgramExpenditures;
        system.assertequals(TRUE, testbaw.getbdisplay() );   
        system.assertequals('Sub-total Program Expenditures', testbaw.sLabel   );   
        system.assertequals(0, testbaw.getiBudget1()  );   
        system.assertequals(0, testbaw.getiActual1()  );   
        system.assertequals(0, testbaw.getiBudget2() );   
        system.assertequals(42200, testbaw.getiActual2() );   
        system.assertequals(42200, testbaw.getiremaining() ); 

        testbaw = bfc.TotalDirectExpenditures;
        system.assertequals(TRUE, testbaw.getbdisplay() );   
        system.assertequals('Total Direct Expenditures', testbaw.sLabel   );   
        system.assertequals(0, testbaw.getiBudget1()  );   
        system.assertequals(0, testbaw.getiActual1()  );   
        system.assertequals(0, testbaw.getiBudget2() );   
        system.assertequals(111611, testbaw.getiActual2() );   
        system.assertequals(111611, testbaw.getiremaining() ); 

        testbaw = bfc.AppliedOverhead;
        system.assertequals(TRUE, testbaw.getbdisplay() );   
        system.assertequals('Applied Grant Overhead', testbaw.sLabel   );   
        system.assertequals(0, testbaw.getiBudget1()  );   
        system.assertequals(0, testbaw.getiActual1()  );   
        system.assertequals(0,testbaw.getiBudget2() );   
        system.assertequals(10411, testbaw.getiActual2() );   
        system.assertequals(10411, testbaw.getiremaining() ); 

        testbaw = bfc.TotalExpenditures;
        system.assertequals(TRUE, testbaw.getbdisplay() );   
        system.assertequals('Total Expenditures', testbaw.sLabel   );   
        system.assertequals(0, testbaw.getiBudget1()  );   
        system.assertequals(0, testbaw.getiActual1()  );   
        system.assertequals(0, testbaw.getiBudget2() );   
        system.assertequals(122022, testbaw.getiActual2() );   
        system.assertequals(122022, testbaw.getiremaining() ); 

        

}   

} //End Class