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

private class ManageStaffParticipation_TESTS {
//Although the SP Trigger is tested by association, 
//this will explicitly test the trigger/class
  @IsTest(SeeAllData=true)//Required when testing Chatter
  static void UpdateStaffonOpportunity() {

  Account ourAccount = TestDataFactory_TEST.setupNewAccount(TRUE, 'Our Account');

  TestDataFactory_TEST.setupPCESettings(TRUE);
  TestDataFactory_TEST.setupOrgSettings(TRUE, ourAccount.Id);
  TestDataFactory_TEST.setupOptytoGrantFieldSettings(TRUE);

  Account testA = TestDataFactory_TEST.setupNewAccount(TRUE, 'Foundation A');
  
    Contact c = new Contact (AccountId = ouraccount.Id, LastName = 'Test Contact1', gm_Related_User_Record__c = userinfo.getuserid());
    insert c;

    Contact c2 = new Contact (AccountId = ouraccount.Id, LastName = 'Test Contact2', gm_Related_User_Record__c = userinfo.getuserid());
    insert c2;
  
  Opportunity testO = TestDataFactory_TEST.setupNewOpty (FALSE, 'Test O', system.today(), testA.Id);
  testo.Grant_Period_Start__c = system.today().adddays(10);
  testo.Grant_Period_End__c = system.today().adddays(375);
  insert testO;

  TestDataFactory_TEST.setChatterFeed(testO.Id);

  List<Staff_Participation__c> spList = new List<Staff_Participation__c> ();
  spList.add(new Staff_Participation__c(Contact__c = c.Id, Opportunity__c = testo.Id, Lead_Staffer__c = TRUE));
  spList.add(new Staff_Participation__c(Contact__c = c2.Id, Opportunity__c = testo.Id, Lead_Staffer__c = FALSE));
  
  insert spList;
  
  Opportunity testOUpdated = [Select Id, Lead_Staff__c from Opportunity WHERE Id = :testO.Id];
  system.assertequals('Test Contact1', testOUpdated.Lead_Staff__c);
  
  spList[0].Lead_Staffer__c = FALSE;
  spList[1].Lead_Staffer__c = TRUE;
  
  update spList;  
  
  testOUpdated = [Select Id, Lead_Staff__c from Opportunity WHERE Id = :testO.Id];
  system.assertequals('Test Contact2', testOUpdated.Lead_Staff__c);
    
  delete spList;
  testOUpdated = [Select Id, Lead_Staff__c from Opportunity WHERE Id = :testO.Id];
  system.assertequals(NULL, testOUpdated.Lead_Staff__c);
   
    
    
}

}