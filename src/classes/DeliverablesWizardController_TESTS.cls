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
private class DeliverablesWizardController_TESTS {

@isTest
private static void NewDeliverableCreation() {

TestDataFactory_TEST.setupPCESettings(FALSE);

Account ouraccount = TestDataFactory_TEST.setupNewAccount (TRUE, 'Test Our Account');
TestDataFactory_TEST.setupOrgSettings(FALSE, ouraccount.Id);

List<Department__c> testDepartments = TestDataFactory_TEST.setupDepartments();

Account testa = TestDataFactory_TEST.setupNewAccount (TRUE, 'Test New Account');
Opportunity testO = TestDataFactory_TEST.setupNewOpty (FALSE, 'Test O', system.today(), testa.Id);

Contact c = new Contact (AccountId = ouraccount.Id, FirstName = 'Peter', LastName = 'Test Contact1', gm_Related_User_Record__c = userinfo.getuserid(), gm_Department__c  = testDepartments[0].Id);
insert c;

Contact c2 = new Contact (AccountId = ouraccount.Id, LastName = 'Test Contact2', gm_Department__c  = testDepartments[2].Id);
insert c2;

Project__c testProject = TestDataFactory_TEST.setupNewProject(TRUE, 'Project 1');

Grant_Management__c testGM = TestDataFactory_TEST.setupNewGrant (TRUE, 'Test GM', testO.Id);

PageReference pageRef = Page.ProductWizardP1;
Test.setCurrentPage(pageRef);
Deliverable__c prod = new Deliverable__c();
DeliverablesWizardControllerExtension bfc = new DeliverablesWizardControllerExtension(new ApexPages.StandardController(prod)); 
bfc.projectId = testProject.Id;

//Force Error by using incorrect Id Reference
bfc.grantId =  testProject.Id;

try{
prod.Name = null;
bfc.authorpage();
}

Catch (Exception Ex) {
system.debug(Ex);
}

bfc.grantId = testGM.Id;
prod.Name = 'test';
String sUrl = bfc.authorpage().getURL();


List<Deliverable__c> testdeliverables = [Select Id, Project__c FROM Deliverable__c];
system.assertequals(1, testdeliverables.size());
system.assertequals(testProject.Id, testdeliverables[0].Project__c);

String sCompare = '/apex/' + UTIL_Namespace.StrTokenNSPrefix('ProductWizardP2') + '?Id='+testdeliverables[0].Id;
system.assertEquals(sCompare, sURL);  



List<Grant_Deliverable__c> testgd = [Select Id, Grant_Management__c FROM Grant_Deliverable__c WHERE
                                     Deliverable__c = :testdeliverables[0].Id];

system.assertequals(testGM.Id,  testgd[0].Grant_Management__c);
}

}