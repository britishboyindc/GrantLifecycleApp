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
* create test data for all tests to centralize setup and maintenance
*/

@isTest
public with sharing class TestDataFactory_TEST {

public static Account setupNewAccount (Boolean bCreate, String sName) {
Account a = new Account (Name = sName);
if (bCreate) {
insert a;
}
return a;
}

public static Project__c setupNewProject (Boolean bCreate, String sName) {
Project__c p = new Project__c (Name = sName);
if (bCreate) {
insert p;
}
return p;
}


public static Deliverable__c setupNewDeliverable (Boolean bCreate, String sName, Id ProjectId) {
Deliverable__c d = new Deliverable__c (Name = sName, Project__c = ProjectId);
if (bCreate) {
insert d;
}
return d;
}

public static Grant_Management__c setupNewGrant (Boolean bCreate, String sName, Id OptyId) {
Grant_Management__c gm = new Grant_Management__c (Name = sName, Source_Opportunity__c = OptyId);
if (bCreate) {
insert gm;
}
return gm;
}

public static Opportunity setupNewOpty (Boolean bCreate, String sName, Date dtCloseDate, Id AccountId) {
Opportunity o = new Opportunity (Name = sName, CloseDate = dtCloseDate);
o.StageName = 'Closed Won';
if (bCreate) {
insert o;
}
return o;
}

public static void setupPCESettings(Boolean bClear) {

List<ParticipationControllerSettings__c> pcesettings;

if (bClear) {
     pcesettings = ParticipationControllerSettings__c.getall().values();
     delete pcesettings;
}

pcesettings = new List<ParticipationControllerSettings__c> ();  
pcesettings.add(new ParticipationControllerSettings__c (Name = 'Opportunity', Staff_Participation_Field__c = 'Opportunity__c'));
pcesettings.add(new ParticipationControllerSettings__c (Name = 'Grant_Management__c', Staff_Participation_Field__c = 'Grant_Management__c'));
insert pcesettings;
}

public static void setupOrgSettings(Boolean bClear, Id AccountId) {

List<GrantManagementSettings__c> gm;

if (bClear) {
     gm = GrantManagementSettings__c.getall().values();
     delete gm;
}

gm = new List<GrantManagementSettings__c>();
gm.add(new GrantManagementSettings__c(Name = 'OurAccountId', Id_Value__c = AccountId));
gm.add(new GrantManagementSettings__c(Name = 'ContactDepartment', String_Value__c = 'gm_Department_Reference__c'));
gm.add(new GrantManagementSettings__c(Name = 'ContactIdFieldonUser', String_Value__c = 'Contact_ID__c'));
gm.add(new GrantManagementSettings__c(Name = 'UserFieldonContact', String_Value__c = 'gm_Related_User_Record__c'));
gm.add(new GrantManagementSettings__c(Name = 'PostLeadStaffertoChatter', Boolean_Value__c = TRUE));


insert gm;
}


public static void setupOptytoGrantFieldSettings(Boolean bClear) {
List<Opty_Grant_Fields__c> ogf;

if (bClear) {
     ogf = Opty_Grant_Fields__c.getall().values();
     delete ogf;
}

ogf = new List<Opty_Grant_Fields__c>();
ogf.add (new Opty_Grant_Fields__c(Name = 'Id', Grant_Field__c = 'Source_Opportunity__c', Page_Order__c = 1, Section_on_Page__c = 1));
ogf.add (new Opty_Grant_Fields__c(Name = 'Name', Grant_Field__c = 'Name', Page_Order__c = 1, Section_on_Page__c = 1));
ogf.add (new Opty_Grant_Fields__c(Name = 'Grant_Period_Start__c', Grant_Field__c = 'Grant_Start_Date__c', Page_Order__c = 1, Section_on_Page__c = 1));
ogf.add (new Opty_Grant_Fields__c(Name = 'Grant_Period_End__c', Grant_Field__c = 'Grant_End_Date__c', Page_Order__c = 1, Section_on_Page__c = 1));

ogf.add (new Opty_Grant_Fields__c(Name = 'Grant_Provisions__c', Grant_Field__c = 'Grant_Provisions__c', Page_Order__c = 20, Section_on_Page__c = 2));


insert ogf;
}

public static void setupBudgetSettings(Boolean bClear, Id PermSet, String cCodes) {
List<Budget_Settings__c> bud;

if (bClear) {
     bud = Budget_Settings__c.getall().values();
     delete bud;
}

bud = new List<Budget_Settings__c>();
if (PermSet != null) {
bud.add (new Budget_Settings__c(Name = 'PermissionSet', Id_Value__c  = PermSet));
}
bud.add (new Budget_Settings__c(Name = 'CompanyCodes', String_Value__c  = cCodes));
bud.add (new Budget_Settings__c(Name = 'StartingBalanceCode', String_Value__c  = '3200'));


insert bud;
}


public static List<Department__c> setupDepartments() {

List<Department__c> dparents = new List<Department__c> ();
dparents.add(new Department__c (Name = 'Parent 1', Roll_Up_Department__c = TRUE, Code__c = 1, Policy_Dept__c = TRUE));
dparents.add(new Department__c (Name = 'Parent 2', Roll_Up_Department__c = FALSE, Code__c = 2));
insert dparents;

List<Department__c> childdepts = new List<Department__c> ();
childdepts.add(new Department__c (Name = 'Child 1', Parent_Department__c = dparents[0].Id, Code__c = 20));
childdepts.add(new Department__c (Name = 'Child 1a', Parent_Department__c = dparents[0].Id, Code__c = 72, Policy_Dept__c = TRUE));
childdepts.add(new Department__c (Name = 'Child 2', Parent_Department__c = dparents[1].Id, Code__c = 75, Policy_Dept__c = TRUE));
childdepts.add(new Department__c (Name = 'Child 2a', Parent_Department__c = dparents[1].Id, Code__c = 82));
childdepts.add(new Department__c (Name = 'Child 2b', Parent_Department__c = dparents[1].Id, Code__c = 84));
childdepts.add(new Department__c (Name = 'Child 2c', Parent_Department__c = dparents[1].Id, Code__c = 86));

insert childdepts;
return childdepts;
}

public static void setupIssueUtilitySettings(Boolean bClear) {
List<Issue_Utility_Settings__c> issuesettings;


if (bClear) {
     issuesettings = Issue_Utility_Settings__c.getall().values();
     delete issuesettings;
}

issuesettings = new List<Issue_Utility_Settings__c>();
issuesettings.add (new Issue_Utility_Settings__c(Name = 'Deliverable__c', Issue_Intersection_Field__c  = 'Deliverable__c'));
issuesettings.add (new Issue_Utility_Settings__c(Name = 'TaxonomyStrings', String_Value__c  = 'Issue;'));

insert issuesettings;
}


public static List<Issue__c> setupIssues() {

List<Issue__c> dparents = new List<Issue__c> ();
dparents.add(new Issue__c (Name = 'Parent Issue 1'));
dparents.add(new Issue__c (Name = 'Parent Issue 2'));
insert dparents;

List<Issue__c> childissues = new List<Issue__c> ();
childissues.add(new Issue__c (Name = 'Child 1', Parent_Issue__c = dparents[0].Id, Taxonomy__c = 'Issue'));
childissues.add(new Issue__c (Name = 'Child 1a', Parent_Issue__c = dparents[0].Id, Taxonomy__c = 'Issue'));
childissues.add(new Issue__c (Name = 'Child 2', Parent_Issue__c = dparents[1].Id, Taxonomy__c = 'Issue'));

insert childissues;
return childissues;
}

public static User CreateTestUser (String sUserName) {

 User u = new User(

          Username = sUserName,
          Alias = 'standt',
          email = 'standarduser@example.com',
          emailencodingkey = 'UTF-8',
          LastName = 'Testing',
          LanguageLocaleKey = 'en_US',
          LocaleSidKey = 'en_US',
          ProfileId = userinfo.getProfileId(),
          TimeZoneSidKey = 'America/Los_Angeles'

        );

insert u;

return u;


}

public static void setChatterFeed (Id RecordId) {

ConnectApi.FeedItemPage testPage = new ConnectApi.FeedItemPage();
        List<ConnectApi.FeedItem> testItemList = new List<ConnectApi.FeedItem>();
        testItemList.add(new ConnectApi.FeedItem());
        testItemList.add(new ConnectApi.FeedItem());
        testItemList.add(createFeedItemwithAttachment(RecordId));
        testPage.items = testItemList;
        
        // Set the test data
        ConnectApi.ChatterFeeds.setTestGetFeedItemsFromFeed(null, ConnectApi.FeedType.Record, RecordId, testPage);

}

public static ConnectApi.FeedItem createFeedItemwithAttachment (Id RecordId) {

String s = 'Test Attach One';
blob sBody = blob.valueof(s);

ConnectApi.BinaryInput newChatterFile = new ConnectApi.BinaryInput(sBody, 'txt', 'Test A 1');
ConnectApi.NewFileAttachmentInput cai = new ConnectApi.NewFileAttachmentInput ();
cai.description = 'Test File 1';
cai.title = 'Test A 1';

    ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
    input.attachment = cai;
    input.visibility = ConnectApi.FeedItemVisibilityType.InternalUsers; 
        //TargetRecordId is the record id of the chatter feed you want to post on
    ConnectApi.FeedItem fi = ConnectApi.ChatterFeeds.postFeedItem(null, 
                                        ConnectApi.FeedType.Record,
                                        RecordId, 
                                        input,
                                        newChatterFile);
    return fi; 
}

public static void setAccountingData () {
Map<String, Accounting_Category__c> mcats = new Map<String, Accounting_Category__c> ();
    
    mcats.put('Salary', new Accounting_Category__c(Name = 'Salary', Category_Code__c = 'SALARY', Display_Order__c = 99) );
    mcats.put('Travel', new Accounting_Category__c(Name = 'Travel', Category_Code__c = 'EXPENSE', Display_Order__c = 2) );
    mcats.put('Office', new Accounting_Category__c(Name = 'Office', Category_Code__c = 'EXPENSE', Display_Order__c = 3) );
    mcats.put('Rent', new Accounting_Category__c(Name = 'Rent', Category_Code__c = 'EXPENSE', Display_Order__c = 4) );
    mcats.put('Consulting', new Accounting_Category__c(Name = 'Consulting', Category_Code__c = 'EXPENSE', Display_Order__c = 4) );

    mcats.put('Revenue', new Accounting_Category__c(Name = 'Revenue', Category_Code__c = 'REVENUE', Display_Order__c = 99) );
    
    mcats.put('OPERATIONAL OVERHEAD', new Accounting_Category__c(Name = 'OPERATIONAL OVERHEAD', Category_Code__c = 'OVERHEAD', Display_Order__c = 4) );
    mcats.put('Fringe Benefits', new Accounting_Category__c(Name = 'Fringe Benefits', Category_Code__c = 'FRINGE BENEFIT', Display_Order__c = 99) );
    mcats.put('Applied Grant Overhead', new Accounting_Category__c(Name = 'Applied Grant Overhead', Category_Code__c = 'OVERHEAD', Display_Order__c = 99) );
    insert mcats.values();

    List<Accounting_Code__c> acodes = new List<Accounting_Code__c> ();
    acodes.add (new Accounting_Code__c (Name = '7000',Include_on_Budget_Report__c = TRUE,Accounting_Category__c = mcats.get('Salary').Id) );
    acodes.add (new Accounting_Code__c (Name = '7100',Include_on_Budget_Report__c = TRUE,Accounting_Category__c = mcats.get('Fringe Benefits').Id) );
    acodes.add (new Accounting_Code__c (Name = '7200',Include_on_Budget_Report__c = TRUE,Accounting_Category__c = mcats.get('Consulting').Id) );
    

    acodes.add (new Accounting_Code__c (Name = '7315',Include_on_Budget_Report__c = TRUE,Accounting_Category__c = mcats.get('Travel').Id) );
    acodes.add (new Accounting_Code__c (Name = '7450',Include_on_Budget_Report__c = TRUE,Accounting_Category__c = mcats.get('Travel').Id) );
    acodes.add (new Accounting_Code__c (Name = '7400',Include_on_Budget_Report__c = TRUE,Accounting_Category__c = mcats.get('Travel').Id) );
    acodes.add (new Accounting_Code__c (Name = '7520',Include_on_Budget_Report__c = TRUE,Accounting_Category__c = mcats.get('Travel').Id) );
    acodes.add (new Accounting_Code__c (Name = '7540',Include_on_Budget_Report__c = TRUE,Accounting_Category__c = mcats.get('Travel').Id) );
    
    acodes.add (new Accounting_Code__c (Name = '7700',Include_on_Budget_Report__c = TRUE,Accounting_Category__c = mcats.get('Travel').Id) );
    acodes.add (new Accounting_Code__c (Name = '7720',Include_on_Budget_Report__c = TRUE,Accounting_Category__c = mcats.get('Rent').Id) );
    acodes.add (new Accounting_Code__c (Name = '7730',Include_on_Budget_Report__c = TRUE,Accounting_Category__c = mcats.get('Rent').Id) );

    acodes.add (new Accounting_Code__c (Name = '7995',Include_on_Budget_Report__c = TRUE,Accounting_Category__c = mcats.get('Applied Grant Overhead').Id) );
    acodes.add (new Accounting_Code__c (Name = '7990',Include_on_Budget_Report__c = FALSE,Accounting_Category__c = mcats.get('OPERATIONAL OVERHEAD').Id) );
    
    acodes.add (new Accounting_Code__c (Name = '5200',Include_on_Budget_Report__c = TRUE,Accounting_Category__c = mcats.get('Revenue').Id) );
    
    insert acodes;
}

@isTest
static void SetupCustomSettingsBudgeUpdate() {
SetupCustomSettings scs = new SetupCustomSettings();
scs.updateSettings();
List<GrantManagementSettings__c> gm = GrantManagementSettings__c.getall().values();
system.assert(gm.size() > 0);

//Test Update of Budget Settings
SetupCustomSettings scs2 = new SetupCustomSettings();
system.assertequals('March 31st 2014', scs2.budmap.get('CurrentDataMonth').String_Value__c);
system.assertequals('3200', scs2.budmap.get('StartingBalanceCode').String_Value__c);

Budget_Settings__c bnew = scs2.budmap.get('CurrentDataMonth');
system.assertequals('March 31st 2014', bnew.String_Value__c);
bnew.String_Value__c = 'December 31st 2014';
scs2.updateRecentMonth();

SetupCustomSettings scs3 = new SetupCustomSettings();
system.assertequals('December 31st 2014', scs3.budmap.get('CurrentDataMonth').String_Value__c);
//Check Existing not changed
system.assertequals('3200', scs3.budmap.get('StartingBalanceCode').String_Value__c);

}


}