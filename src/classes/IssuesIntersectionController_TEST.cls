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
private class IssuesIntersectionController_TEST {
    
    @isTest
    static void MainComponentTest() {
    
    Account ourAccount = TestDataFactory_TEST.setupNewAccount(TRUE, 'Our Account');

    TestDataFactory_TEST.setupPCESettings(TRUE);
    TestDataFactory_TEST.setupOrgSettings(TRUE, ourAccount.Id);
   
    Project__c testProject = TestDataFactory_TEST.setupNewProject(TRUE, 'Project 1');

    Account testA = TestDataFactory_TEST.setupNewAccount(TRUE, 'Foundation A');
  
    Contact c = new Contact (AccountId = ouraccount.Id, LastName = 'Test Contact1', gm_Related_User_Record__c = userinfo.getuserid());
    insert c;

    Contact c2 = new Contact (AccountId = ouraccount.Id, LastName = 'Test Contact2', gm_Related_User_Record__c = userinfo.getuserid());
    insert c2;
  
    TestDataFactory_TEST.setupIssueUtilitySettings(FALSE);
    List<issue__c> testIssues = TestDataFactory_TEST.setupIssues();

    Deliverable__c testDeliver = TestDataFactory_TEST.setupNewDeliverable(FALSE, 'Test Deliver 1', testProject.Id);
    testDeliver.Departments__c = 'Child 1;Child 2';
    testDeliver.Project__c = testProject.Id;
    insert testDeliver;

    List<Department__c> testDepts = TestDataFactory_TEST.setupDepartments();

    //Create Defaults
    List<Issue_Intersection__c> iisdefaults = new List<Issue_Intersection__c> ();
    iisdefaults.add(new Issue_Intersection__c(Issue__c = testIssues[0].Id, Department__c = testDepts[0].Id, Default_for_Related_Item__c = TRUE)); //Child 1 - Child 1
    iisdefaults.add(new Issue_Intersection__c(Issue__c = testIssues[0].Id, Department__c = testDepts[2].Id, Default_for_Related_Item__c = TRUE)); //Child 1 - Child 2
    
    iisdefaults.add(new Issue_Intersection__c(Issue__c = testIssues[0].Id, Project__c = testProject.Id, Default_for_Related_Item__c = TRUE)); //Child 1 - Child 2
    iisdefaults.add(new Issue_Intersection__c(Issue__c = testIssues[1].Id, Department__c = testDepts[2].Id, Default_for_Related_Item__c = TRUE)); //Child 1a - Child 2

    insert iisdefaults;
 
    PageReference pageRef = Page.NewDeliverableIssues;
    Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('Id', testDeliver.Id);
    

    IssuesIntersectionController bfc = new  IssuesIntersectionController();
    
    bfc.objectId = testDeliver.Id;
    bfc.sMode = 'NEWWITHDEFAULT';
    bfc.sSource = 'Page';

    //Initiates List Population Process
    bfc.getTaxonomySections();

    List<IssuesIntersectionController.issueselectionwrapper> testiiw = bfc.TaxonomySectionMap.get('Issue');
    system.assertequals(2, testiiw.size());
    Issue__c issue1 = testiiw[0].issue;
    system.assert(issue1.Name.Contains('Child 1'));
    
    bfc.processSelectedIssues();

    //Create Defaults - should create 2 records to show we do not create dupe issue references 
    List<Issue_Intersection__c> testdefaults = [SELECT Id FROM Issue_Intersection__c WHERE Deliverable__c = :testDeliver.Id];
    system.assertequals(2, testdefaults.size());    

    //Now invoke again in update mode
    PageReference pageRef2 = Page.NewDeliverableIssues;
    Test.setCurrentPage(pageRef2);
    ApexPages.currentPage().getParameters().put('Id', testDeliver.Id);
    
    IssuesIntersectionController bfc2 = new  IssuesIntersectionController();
    
    bfc2.objectId = testDeliver.Id;
    bfc2.sMode = 'UPDATE';
    bfc2.sSource = 'Page';
    bfc2.sNextPage = 'ContactIssue';


    bfc2.getTaxonomySections();

    ApexPages.currentPage().getParameters().put('rcid', testIssues[0].Id);

    bfc2.removeSelectedIssue();
    bfc2.processSelectedIssues();

    //Create Defaults - should create 2 records to show we do not create dupe issue references 
    testdefaults = [SELECT Id, Issue__c FROM Issue_Intersection__c WHERE Deliverable__c = :testDeliver.Id];
    system.assertequals(1, testdefaults.size());    
    system.assertequals(testIssues[1].Id, testdefaults[0].Issue__c);    

    //Check Cancel
    String sCancel = bfc2.cancelupdate().geturl();
    system.assertequals ('/'+testDeliver.Id, sCancel);


    }

@isTest
    static void MainComponentTestStaffDefaults() {
    
    Account ourAccount = TestDataFactory_TEST.setupNewAccount(TRUE, 'Our Account');

    TestDataFactory_TEST.setupPCESettings(TRUE);
    TestDataFactory_TEST.setupOrgSettings(TRUE, ourAccount.Id);
   
    Account testA = TestDataFactory_TEST.setupNewAccount(TRUE, 'Foundation A');
  
    Contact c = new Contact (AccountId = ouraccount.Id, LastName = 'Test Contact1', gm_Related_User_Record__c = userinfo.getuserid());
    insert c;

    Contact c2 = new Contact (AccountId = ouraccount.Id, LastName = 'Test Contact2', gm_Related_User_Record__c = userinfo.getuserid());
    insert c2;
  
    TestDataFactory_TEST.setupIssueUtilitySettings(FALSE);
    List<issue__c> testIssues = TestDataFactory_TEST.setupIssues();

    Project__c testProject = TestDataFactory_TEST.setupNewProject(TRUE, 'Project 1');


    Deliverable__c testDeliver = TestDataFactory_TEST.setupNewDeliverable(FALSE, 'Test Deliver 1', testProject.Id);
    testDeliver.Departments__c = 'Child 1;Child 2';
    insert testDeliver;

    List<Department__c> testDepts = TestDataFactory_TEST.setupDepartments();

    //Create Staff Defaults
    List<Staff_Participation__c> spList = new List<Staff_Participation__c> ();
    spList.add(new Staff_Participation__c(Contact__c = c.Id, Deliverables__c = testDeliver.Id, Lead_Staffer__c = TRUE));
    spList.add(new Staff_Participation__c(Contact__c = c2.Id, Deliverables__c = testDeliver.Id, Lead_Staffer__c = FALSE));
    insert spList;

    List<Issue_Intersection__c> iisdefaults = new List<Issue_Intersection__c> ();
    iisdefaults.add(new Issue_Intersection__c(Issue__c = testIssues[0].Id, Contact__c = c.Id, Default_for_Related_Item__c = TRUE)); //Child 1 - Child 1
    iisdefaults.add(new Issue_Intersection__c(Issue__c = testIssues[1].Id, Contact__c = c2.Id, Default_for_Related_Item__c = TRUE)); //Child 1a - Child 2

    insert iisdefaults;
 
    PageReference pageRef = Page.NewDeliverableIssues;
    Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('Id', testDeliver.Id);
    

    IssuesIntersectionController bfc = new  IssuesIntersectionController();
    
    bfc.objectId = testDeliver.Id;
    bfc.sMode = 'NEWWITHDEFAULT';
    bfc.sSource = 'Page';

    //Initiates List Population Process
    bfc.getTaxonomySections();

    List<IssuesIntersectionController.issueselectionwrapper> testiiw = bfc.TaxonomySectionMap.get('Issue');
    system.assertequals(2, testiiw.size());
    Issue__c issue1 = testiiw[0].issue;
    system.assert(issue1.Name.Contains('Child 1'));
    Issue_Intersection__c iss1 = testiiw[0].issueintersection;
    system.assertEquals('Contact', iss1.Object__c);
    system.assertEquals(testDeliver.Id, iss1.Deliverable__c);

    bfc.processSelectedIssues();

    //Create Defaults - should create 2 records to show we do not create dupe issue references 
    List<Issue_Intersection__c> testdefaults = [SELECT Id FROM Issue_Intersection__c WHERE Deliverable__c = :testDeliver.Id];
    system.assertequals(2, testdefaults.size());    

    
    }


    @isTest
    static void MainComponentTestNoDefaults() {
    
    Account ourAccount = TestDataFactory_TEST.setupNewAccount(TRUE, 'Our Account');

    TestDataFactory_TEST.setupPCESettings(TRUE);
    TestDataFactory_TEST.setupOrgSettings(TRUE, ourAccount.Id);
   
    Account testA = TestDataFactory_TEST.setupNewAccount(TRUE, 'Foundation A');
  
    Contact c = new Contact (AccountId = ouraccount.Id, LastName = 'Test Contact1', gm_Related_User_Record__c = userinfo.getuserid());
    insert c;

    Contact c2 = new Contact (AccountId = ouraccount.Id, LastName = 'Test Contact2', gm_Related_User_Record__c = userinfo.getuserid());
    insert c2;
  
    TestDataFactory_TEST.setupIssueUtilitySettings(FALSE);
    List<issue__c> testIssues = TestDataFactory_TEST.setupIssues();


    Project__c testProject = TestDataFactory_TEST.setupNewProject(TRUE, 'Project 1');

    Deliverable__c testDeliver = TestDataFactory_TEST.setupNewDeliverable(FALSE, 'Test Deliver 1', testProject.Id);
    testDeliver.Departments__c = 'Child 1;Child 2';
    insert testDeliver;

    List<Department__c> testDepts = TestDataFactory_TEST.setupDepartments();

    PageReference pageRef = Page.NewDeliverableIssues;
    Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('Id', testDeliver.Id);
    
    IssuesIntersectionController bfc = new  IssuesIntersectionController();
    
    bfc.objectId = testDeliver.Id;
    bfc.sMode = 'NEWWITHDEFAULT';
    bfc.sSource = 'Page';

    //Initiates List Population Process
    bfc.getTaxonomySections();

    List<IssuesIntersectionController.issueselectionwrapper> testiiw = bfc.TaxonomySectionMap.get('Issue');
    system.assertequals(0, testiiw.size());
    bfc.cIssueId = testIssues[0].Parent_Issue__c;

    bfc.search();

    system.assertequals(2, bfc.newIssuesforSelection.size());
    system.assertequals('Child 1a', bfc.newIssuesforSelection[0].Name);
    system.assertequals('Issue', bfc.newIssuesforSelection[0].Taxonomy__c);
    
    ApexPages.currentPage().getParameters().put('cid', testIssues[0].Id);

    bfc.setSelectedIssue();
    bfc.processAction();

    //Check when update via Chatter Publisher Action
    system.assertequals(TRUE, bfc.bPosted);

    //Check Records Created
    List<Issue_Intersection__c> testdefaults = [SELECT Id FROM Issue_Intersection__c WHERE Deliverable__c = :testDeliver.Id];
    system.assertequals(1, testdefaults.size());    


}
    
        
}