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
* This is an unmanaged package, so no install scripts, but this powers a page where user 
* can quickly insert default vales into required custom settings 
*/

public with sharing class SetupCustomSettings {

public List<ParticipationControllerSettings__c> pcesettings  {get;set;}
public List<GrantManagementSettings__c> gm  {get;set;}
public List<Opty_Grant_Fields__c> ogf  {get;set;}
public List<Issue_Utility_Settings__c> issuesettings   {get;set;}
public List<Budget_Settings__c> bud  {get;set;}
public Map<String, Budget_Settings__c> budmap  {get;set;}
Id PermissionSetId;

public SetupCustomSettings() {
SetupSettings();
}

public void SetupSettings () {

    pcesettings = ParticipationControllerSettings__c.getall().values();
    gm = GrantManagementSettings__c.getall().values();
    ogf = Opty_Grant_Fields__c.getall().values();
    bud = Budget_Settings__c.getall().values();
    budmap = Budget_Settings__c.getall(); 
    issuesettings = Issue_Utility_Settings__c.getall().values();
   
    
if (pcesettings.isEmpty()) {
    pcesettings = new List<ParticipationControllerSettings__c> ();  
    pcesettings.add(new ParticipationControllerSettings__c (Name = 'Account', Staff_Participation_Field__c = 'Account__c'));
    pcesettings.add(new ParticipationControllerSettings__c (Name = 'Opportunity', Staff_Participation_Field__c = 'Opportunity__c'));
    pcesettings.add(new ParticipationControllerSettings__c (Name = 'Grant_Management__c', Staff_Participation_Field__c = 'Grant_Management__c'));
    pcesettings.add(new ParticipationControllerSettings__c (Name = 'Deliverable__c', Staff_Participation_Field__c = 'Deliverables__c'));
    pcesettings.add(new ParticipationControllerSettings__c (Name = 'Outreach__c', Staff_Participation_Field__c = 'Outreach__c'));
    pcesettings.add(new ParticipationControllerSettings__c (Name = 'Project__c', Staff_Participation_Field__c = 'Project__c'));
    
    
    }

if (gm.isEmpty()) {
    gm = new List<GrantManagementSettings__c>();
    gm.add(new GrantManagementSettings__c(Name = 'OurAccountId', Id_Value__c = 'ENTER ID HERE'));
    gm.add(new GrantManagementSettings__c(Name = 'ContactDepartment', String_Value__c = 'gm_Department_Reference__c'));
    gm.add(new GrantManagementSettings__c(Name = 'ContactIdFieldonUser', String_Value__c = 'Contact_ID__c'));
    gm.add(new GrantManagementSettings__c(Name = 'UserFieldonContact', String_Value__c = 'gm_Related_User_Record__c'));
    gm.add(new GrantManagementSettings__c(Name = 'PostLeadStaffertoChatter', Boolean_Value__c = TRUE));
    }

if (ogf.isEmpty()) {
    ogf = new List<Opty_Grant_Fields__c>();
    ogf.add (new Opty_Grant_Fields__c(Name = 'Id', Grant_Field__c = 'Source_Opportunity__c', Page_Order__c = 1, Section_on_Page__c = 1));
    ogf.add (new Opty_Grant_Fields__c(Name = 'Name', Grant_Field__c = 'Name', Page_Order__c = 1, Section_on_Page__c = 1));
    ogf.add (new Opty_Grant_Fields__c(Name = 'Grant_Period_Start__c', Grant_Field__c = 'Grant_Start_Date__c', Page_Order__c = 1, Section_on_Page__c = 1));
    ogf.add (new Opty_Grant_Fields__c(Name = 'Grant_Period_End__c', Grant_Field__c = 'Grant_End_Date__c', Page_Order__c = 1, Section_on_Page__c = 1));
    ogf.add (new Opty_Grant_Fields__c(Name = 'Grant_Provisions__c', Grant_Field__c = 'Grant_Provisions__c', Page_Order__c = 20, Section_on_Page__c = 2));
    
}

if (bud.isEmpty()) {
    bud = new List<Budget_Settings__c>();
    bud.add (new Budget_Settings__c(Name = 'PermissionSet', Id_Value__c  = 'Enter Perm Id'));
    bud.add (new Budget_Settings__c(Name = 'CompanyCodes', String_Value__c  = 'C1;C2'));
    bud.add (new Budget_Settings__c(Name = 'StartingBalanceCode', String_Value__c  = '3200'));
    bud.add (new Budget_Settings__c(Name = 'CurrentDataMonth', String_Value__c  = 'March 31st 2014'));
    }

if (issuesettings.isEmpty()) {
    issuesettings = new List<Issue_Utility_Settings__c>();
    issuesettings.add (new Issue_Utility_Settings__c(Name = 'Account', Issue_Intersection_Field__c  = 'Account__c'));
    issuesettings.add (new Issue_Utility_Settings__c(Name = 'Contact', Issue_Intersection_Field__c  = 'Contact__c'));
    issuesettings.add (new Issue_Utility_Settings__c(Name = 'Deliverable__c', Issue_Intersection_Field__c  = 'Deliverable__c'));
    issuesettings.add (new Issue_Utility_Settings__c(Name = 'Department__c', Issue_Intersection_Field__c  = 'Department__c'));
    issuesettings.add (new Issue_Utility_Settings__c(Name = 'Outreach__c', Issue_Intersection_Field__c  = 'Outreach__c'));
    issuesettings.add (new Issue_Utility_Settings__c(Name = 'Project__c', Issue_Intersection_Field__c  = 'Project__c'));
    
    issuesettings.add (new Issue_Utility_Settings__c(Name = 'TaxonomyStrings', String_Value__c  = 'Issue;'));
    }


}

public pageReference updateSettings() {
try{
upsert pcesettings;
upsert gm;
upsert bud;
upsert ogf;

upsert issuesettings;

}
Catch (Exception Ex) {

}
return null;
}

public pageReference updateRecentMonth () {

upsert budmap.values();
return new PageReference ('/');
}

}