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
private class ParticipationControllerExtension_TEST{

@isTest
private static void ControllerTestviaPage() {

TestDataFactory_TEST.setupPCESettings(FALSE);

Account ouraccount = TestDataFactory_TEST.setupNewAccount (TRUE, 'Test Our Account');
TestDataFactory_TEST.setupOrgSettings(FALSE, ouraccount.Id);
Account testa = TestDataFactory_TEST.setupNewAccount (TRUE, 'Test New Account');

//We won't test Chatter here, so turn off to test we can disable
GrantManagementSettings__c gm = GrantManagementSettings__c.getvalues('PostLeadStaffertoChatter');
gm.Boolean_Value__c = FALSE;
update gm;


Opportunity testo = TestDataFactory_TEST.setupNewOpty (TRUE, 'Test New Opty', system.today(), testa.Id);

Contact c = new Contact (AccountId = ouraccount.Id, LastName = 'Test Contact1', gm_Related_User_Record__c = userinfo.getuserid());
insert c;

Contact c2 = new Contact (AccountId = ouraccount.Id, LastName = 'Test Contact2', gm_Related_User_Record__c = userinfo.getuserid());
insert c2;

    PageReference pageRef = Page.UpdateOpportunityStaff;
    Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('Id', testo.Id);
    
    ParticipationControllerExtension pce = new ParticipationControllerExtension();
    pce.objectId = testo.Id;
    pce.sSource = 'Page';
    pce.sMode = 'NEW';
    pce.search();
    //Should be one default record included for new records
    system.assertequals(1, pce.getpinvolvement().size());
    ApexPages.currentPage().getParameters().put('cid', c.Id);
    pce.setSelectedContact();
    system.assertequals(c.Id,pce.getpinvolvement()[0].Contact__c);
    pce.getpinvolvement()[0].Lead_Staffer__c = TRUE;
    
    pce.processSelected();
    
    Opportunity oResult = [Select Id, Lead_Staff__c, (Select Id from Staff_Participations__r) FROM Opportunity];
    system.assertequals('Test Contact1', oResult.Lead_Staff__c);
    system.assertequals (1, oResult.Staff_Participations__r.size());
    
    ApexPages.currentPage().getParameters().put('cid', c2.Id);
    pce.setSelectedContact();
    pce.getpinvolvement()[1].Lead_Staffer__c = TRUE;
    pce.processSelected();
    
    oResult = [Select Id, Lead_Staff__c, (Select Id from Staff_Participations__r) FROM Opportunity];
    system.assertequals('Test Contact1' + '\n' + 'Test Contact2', oResult.Lead_Staff__c);
    system.assertequals (2, oResult.Staff_Participations__r.size());
    
    PageReference pageRef2 = Page.UpdateOpportunityStaff;
    Test.setCurrentPage(pageRef2);
    ApexPages.currentPage().getParameters().put('Id', testo.Id);
    
    ParticipationControllerExtension pce2 = new ParticipationControllerExtension();
    pce2.objectId = testo.Id;
    system.assertequals(2, pce2.getpinvolvement().size());
    ApexPages.currentPage().getParameters().put('rcid', c.Id);
    pce2.removeSelectedContact();
    
    system.assertequals(c2.Id,pce2.getpinvolvement()[0].Contact__c);
    pce2.getpinvolvement()[0].Lead_Staffer__c = TRUE;
    pce2.processSelected();

    oResult = [Select Id, Lead_Staff__c, (Select Id from Staff_Participations__r) FROM Opportunity];
    system.assertequals('Test Contact2', oResult.Lead_Staff__c);
    system.assertequals (1, oResult.Staff_Participations__r.size());
   

    //public String sNextPage {get;set;}
    //public String sMode {get;set;}
        
}

@isTest
private static void ControllerTestviaAction() {

TestDataFactory_TEST.setupPCESettings(FALSE);

Account ouraccount = TestDataFactory_TEST.setupNewAccount (TRUE, 'Test Our Account');
TestDataFactory_TEST.setupOrgSettings(FALSE, ouraccount.Id);
Account testa = TestDataFactory_TEST.setupNewAccount (TRUE, 'Test New Account');

//We won't test Chatter here, so turn off to test we can disable
GrantManagementSettings__c gm = GrantManagementSettings__c.getvalues('PostLeadStaffertoChatter');
gm.Boolean_Value__c = FALSE;
update gm;


Opportunity testo = TestDataFactory_TEST.setupNewOpty (TRUE, 'Test New Opty', system.today(), testa.Id);

Contact c = new Contact (AccountId = ouraccount.Id, LastName = 'Test Contact1', gm_Related_User_Record__c = userinfo.getuserid());
insert c;

Contact c2 = new Contact (AccountId = ouraccount.Id, LastName = 'Test Contact2', gm_Related_User_Record__c = userinfo.getuserid());
insert c2;

    PageReference pageRef = Page.UpdateOpportunityStaff;
    Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('Id', testo.Id);
    
    ParticipationControllerExtension pce = new ParticipationControllerExtension();
    pce.objectId = testo.Id;
    pce.sSource = 'Action';
    pce.search();
    system.assertequals(0, pce.getpinvolvement().size());
    ApexPages.currentPage().getParameters().put('cid', c.Id);
    pce.setSelectedContact();
    system.assertequals(c.Id,pce.getpinvolvement()[0].Contact__c);
    pce.getpinvolvement()[0].Lead_Staffer__c = TRUE;
    
    pce.processSelected();
    
    Opportunity oResult = [Select Id, Lead_Staff__c, (Select Id from Staff_Participations__r) FROM Opportunity];
    system.assertequals('Test Contact1', oResult.Lead_Staff__c);
    system.assertequals (1, oResult.Staff_Participations__r.size());
    
    ApexPages.currentPage().getParameters().put('cid', c2.Id);
    pce.setSelectedContact();
    pce.getpinvolvement()[1].Lead_Staffer__c = TRUE;
    
    //Process via Chatter Action
    pce.processAction();
    
    oResult = [Select Id, Lead_Staff__c, (Select Id from Staff_Participations__r) FROM Opportunity];
    system.assertequals('Test Contact1' + '\n' + 'Test Contact2', oResult.Lead_Staff__c);
    system.assertequals (2, oResult.Staff_Participations__r.size());
    
    PageReference pageRef2 = Page.UpdateOpportunityStaff;
    Test.setCurrentPage(pageRef2);
    ApexPages.currentPage().getParameters().put('Id', testo.Id);
    
    ParticipationControllerExtension pce2 = new ParticipationControllerExtension();
    pce2.objectId = testo.Id;
    system.assertequals(2, pce2.getpinvolvement().size());
    ApexPages.currentPage().getParameters().put('rcid', c.Id);
    pce2.removeSelectedContact();
    
    system.assertequals(c2.Id,pce2.getpinvolvement()[0].Contact__c);
    pce2.getpinvolvement()[0].Lead_Staffer__c = TRUE;

    //Process via Chatter Action
    pce2.processAction();
    system.assertequals(TRUE, pce2.bPosted);
    oResult = [Select Id, Lead_Staff__c, (Select Id from Staff_Participations__r) FROM Opportunity];
    system.assertequals('Test Contact2', oResult.Lead_Staff__c);
    system.assertequals (1, oResult.Staff_Participations__r.size());
   

    //public String sNextPage {get;set;}
    //public String sMode {get;set;}
        
}

@isTest
private static void ControllerTestErrors() {

//Don't setup settings and check if it fails gracefully
//TestDataFactory_TEST.setupPCESettings(FALSE);

Account ouraccount = TestDataFactory_TEST.setupNewAccount (TRUE, 'Test Our Account');
TestDataFactory_TEST.setupOrgSettings(FALSE, ouraccount.Id);
Account testa = TestDataFactory_TEST.setupNewAccount (TRUE, 'Test New Account');

Opportunity testo = TestDataFactory_TEST.setupNewOpty (TRUE, 'Test New Opty', system.today(), testa.Id);

Contact c = new Contact (AccountId = ouraccount.Id, LastName = 'Test Contact1', gm_Related_User_Record__c = userinfo.getuserid());
insert c;

Contact c2 = new Contact (AccountId = ouraccount.Id, LastName = 'Test Contact2', gm_Related_User_Record__c = userinfo.getuserid());
insert c2;

    PageReference pageRef = Page.UpdateOpportunityStaff;
    Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('Id', testo.Id);
    
    ParticipationControllerExtension pce = new ParticipationControllerExtension();
    pce.objectId = testo.Id;
    pce.sSource = 'Page';
    pce.getpinvolvement();

    List<Apexpages.Message> msgs = ApexPages.getMessages();
    boolean b = false;
    for(Apexpages.Message msg:msgs){
        if ( msg.getDetail().contains('Missing Object in Custom Setting!') ) {
            b = true;
        }
    }
    system.assert(b);//Assert the Page Message was Properly Displayed
}


@isTest
private static void ControllerTestCancel() {

//Don't setup settings and check if it fails gracefully
TestDataFactory_TEST.setupPCESettings(FALSE);

Account ouraccount = TestDataFactory_TEST.setupNewAccount (TRUE, 'Test Our Account');
TestDataFactory_TEST.setupOrgSettings(FALSE, ouraccount.Id);
Account testa = TestDataFactory_TEST.setupNewAccount (TRUE, 'Test New Account');

Opportunity testo = TestDataFactory_TEST.setupNewOpty (TRUE, 'Test New Opty', system.today(), testa.Id);

Contact c = new Contact (AccountId = ouraccount.Id, LastName = 'Test Contact1', gm_Related_User_Record__c = userinfo.getuserid());
insert c;

Contact c2 = new Contact (AccountId = ouraccount.Id, LastName = 'Test Contact2', gm_Related_User_Record__c = userinfo.getuserid());
insert c2;

    PageReference pageRef = Page.UpdateOpportunityStaff;
    Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('Id', testo.Id);
    
    ParticipationControllerExtension pce = new ParticipationControllerExtension();
    pce.objectId = testo.Id;
    String sUrl = pce.cancelupdate().getURL();
    system.assertequals('/'+testo.Id,sURL);
    }

}