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
private class ContactSearchUtility_TEST {

@isTest
private static void ContactSearch() {

TestDataFactory_TEST.setupPCESettings(FALSE);

Account ouraccount = TestDataFactory_TEST.setupNewAccount (TRUE, 'Test Our Account');
TestDataFactory_TEST.setupOrgSettings(FALSE, ouraccount.Id);

List<Department__c> testDepartments = TestDataFactory_TEST.setupDepartments();

Account testa = TestDataFactory_TEST.setupNewAccount (TRUE, 'Test New Account');

Contact c = new Contact (AccountId = ouraccount.Id, FirstName = 'Peter', LastName = 'Test Contact1', gm_Related_User_Record__c = userinfo.getuserid(), gm_Department__c  = testDepartments[0].Id);
insert c;

Contact c2 = new Contact (AccountId = ouraccount.Id, LastName = 'Test Contact2', gm_Department__c  = testDepartments[2].Id);
insert c2;

ContactSearchUtility csf = new ContactSearchUtility();

csf.cshowCAP();
system.assertequals(FALSE, csf.bshowSearch);
system.assertequals(TRUE, csf.bshowCAP);

//Set a Department
csf.sdept = 'Child 1';
csf.generatevisiblecontacts();
List<Contact> testvisiblecontacts = csf.getvisiblecontacts();
system.assertequals(1,testvisiblecontacts.size());
system.assertequals('Test Contact1', testvisiblecontacts[0].LastName);

//Set a different Department
csf.sdept = 'Child 2';
csf.generatevisiblecontacts();
testvisiblecontacts = csf.getvisiblecontacts();
system.assertequals(1,testvisiblecontacts.size());
system.assertequals('Test Contact2', testvisiblecontacts[0].LastName);

//Switch to search
csf.cshowsearch();
system.assertequals(TRUE, csf.bshowSearch);
system.assertequals(FALSE, csf.bshowCAP);

//Check with no text
csf.generatevisiblecontacts();
testvisiblecontacts = csf.getvisiblecontacts();
system.assertequals(0,testvisiblecontacts.size());

//Now with Text
csf.searchText = 'Test Contact1';
csf.searchFNText = 'Peter';
csf.generatevisiblecontacts();
testvisiblecontacts = csf.getvisiblecontacts();
system.assertequals(1,testvisiblecontacts.size());
system.assertequals('Test Contact1', testvisiblecontacts[0].LastName);

}

}