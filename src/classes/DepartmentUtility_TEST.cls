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
private class DepartmentUtility_TEST {

@isTest
private static void DepartmentUtilityCreation() {

TestDataFactory_TEST.setupPCESettings(FALSE);

Account ouraccount = TestDataFactory_TEST.setupNewAccount (TRUE, 'Test Our Account');
TestDataFactory_TEST.setupOrgSettings(FALSE, ouraccount.Id);

List<Department__c> testDepartments = TestDataFactory_TEST.setupDepartments();

Account testa = TestDataFactory_TEST.setupNewAccount (TRUE, 'Test New Account');

Contact c = new Contact (AccountId = ouraccount.Id, FirstName = 'Peter', LastName = 'Test Contact1', gm_Related_User_Record__c = userinfo.getuserid(), gm_Department__c  = testDepartments[0].Id);
insert c;

Contact c2 = new Contact (AccountId = ouraccount.Id, LastName = 'Test Contact2', gm_Department__c  = testDepartments[2].Id);
insert c2;

DepartmentUtility du = new DepartmentUtility();

Map<String, Id> testMap = du.getNameMap();
Map<String, Department__c> testcodemap = du.getcodemap();

system.assert(du.getNameMap().containskey('Child 1'));
system.assert(du.getNameMap().containskey('Parent 1'));

system.debug(testcodemap);
Department__c testd1 = testcodemap.get('1');
system.assertequals('Parent 1', testd1.Name);
system.assertequals(1, testd1.Code__c);

testd1 = testcodemap.get('86');
system.assertequals('Child 2c', testd1.Name);
system.assertequals(86, testd1.Code__c);

DepartmentUtility du2 = new DepartmentUtility(FALSE);
testMap = du2.getNameMap();

system.assert(du2.getNameMap().containskey('Child 1'));
system.assert(!du2.getNameMap().containskey('Parent 1'));

//Check Rollups
DepartmentUtility du3 = new DepartmentUtility(TRUE);

List<SelectOption> testOptions = du3.getDepartmentSelectList(TRUE, 'Select Me');
system.assertequals('Select Me', testOptions[0].getlabel());
system.assertequals('Child 1a', testOptions[1].getvalue());
system.assertequals('Child 2', testOptions[2].getvalue());

String testQueryClause = du3.getDeptSearchString ('Parent 1', 'IN');
system.assertequals('IN (\'Child 1\',\'Child 1a\')', testQueryClause);

String testQueryClause2 = du3.getDeptSearchString ('Child 1', '=');
system.assertequals('= (\'Child 1\') ', testQueryClause2);


}

}