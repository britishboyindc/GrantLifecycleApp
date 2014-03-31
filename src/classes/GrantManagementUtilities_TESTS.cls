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
private class GrantManagementUtilities_TESTS {

@isTest
private static void CurrentUserLookupTests() {

TestDataFactory_TEST.setupPCESettings(FALSE);

Account ouraccount = TestDataFactory_TEST.setupNewAccount (TRUE, 'Test Our Account');
TestDataFactory_TEST.setupOrgSettings(FALSE, ouraccount.Id);

//Set Running test user to C2

Contact c2 = new Contact (AccountId = ouraccount.Id, LastName = 'Test Contact2');
insert c2;

c2.gm_Related_User_Record__c = userinfo.getUserId();
update c2;

User u = new User (Id = userinfo.getUserId(), Contact_ID__c = c2.Id);
update u;

Contact testc = GrantManagementUtilities.getloggedinusercontactbyuserid();
system.assertequals('Test Contact2', testc.LastName);

Id testId = GrantManagementUtilities.getloggedinusercontactid();
system.assertequals(c2.Id, testId);

}

@isTest
private static void ContactUserLookupTests() {

TestDataFactory_TEST.setupPCESettings(FALSE);

Account ouraccount = TestDataFactory_TEST.setupNewAccount (TRUE, 'Test Our Account');
TestDataFactory_TEST.setupOrgSettings(FALSE, ouraccount.Id);

Contact c = new Contact (AccountId = ouraccount.Id, LastName = 'Test Contact1');
insert c;

User user1 = TestDataFactory_TEST.CreateTestUser('testgrantdev1@bfcpartner.com');

c.gm_Related_User_Record__c = user1.Id;
update c;

user1.Contact_ID__c = c.Id;
update user1;


Set<Id> ConTest = new Set<Id> ();
ConTest.add(c.Id);

Map<Id, Id> testResults = GrantManagementUtilities.getUserMapfromContactRecord(ConTest);
system.assertequals(user1.Id, testResults.get(c.Id) );

//Change Context and Run Again
System.runAs(user1) {

    Contact testc = GrantManagementUtilities.getloggedinusercontactbyuserid();
    system.assertequals('Test Contact1', testc.LastName);

    Id testId2 = GrantManagementUtilities.getloggedinusercontactid();
    system.assertequals(c.Id, testId2);


}

}

}