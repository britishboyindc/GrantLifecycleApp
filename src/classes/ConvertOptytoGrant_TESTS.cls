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
private class ConvertOptytoGrant_TESTS {
	
	@IsTest(SeeAllData=true)
	static void OpportunitytoGrantConversionPage() {

	Account ourAccount = TestDataFactory_TEST.setupNewAccount(TRUE, 'Our Account');

	TestDataFactory_TEST.setupPCESettings(TRUE);
	TestDataFactory_TEST.setupOrgSettings(TRUE, ourAccount.Id);
	
	TestDataFactory_TEST.setupOptytoGrantFieldSettings(TRUE);

	Account testA = TestDataFactory_TEST.setupNewAccount(TRUE, 'Foundation A');
	Opportunity testO = TestDataFactory_TEST.setupNewOpty (FALSE, 'Test O', system.today(), testA.Id);
	testo.Grant_Period_Start__c = system.today().adddays(10);
	testo.Grant_Period_End__c = system.today().adddays(375);
	insert testO;

	//Create attachments in Chatter Feed
	TestDataFactory_TEST.setChatterFeed(testO.Id);

	//Invoke Page
	PageReference pageRef = Page.ConvertToGrantRecord;
    Test.setCurrentPage(pageRef);

    ConvertOpportunitytoGrantController o2g = new ConvertOpportunitytoGrantController(new ApexPages.StandardController(testO)); 
	//Confirm that Chatter Feed Utility returns attachments     
	system.assertequals(1, o2g.ChatterUtility.feeda.size());
    
    //Set Chatter fiel for inclusion
    o2g.ChatterUtility.feeda[0].bInclude = TRUE;

    //Convert Opty to Grant
    o2g.createGrantRecord();

    //Confirm record created
    Grant_Management__c [] gmresult = [Select Id, Name, Grant_Start_Date__c, Grant_End_Date__c 
    									FROM Grant_Management__c  
    									WHERE Source_Opportunity__c = :testo.Id];
    
    //Confirm only one record creaetd
    system.assertequals(1, gmresult.size());
    system.assertequals(gmresult[0].Name, testO.Name);
    system.assertequals(gmresult[0].Grant_Start_Date__c, testO.Grant_Period_Start__c);
    	
    Grant_Management__c testGrant = gmresult[0];
    	
    List<ContentDocumentLink> testcl = [SELECT ContentDocumentId FROM ContentDocumentLink
            							WHERE LinkedEntityId = :testGrant.Id];	
    system.assertequals(1, testcl.size());           							
    //Now Insert new Reports for Grant
    SetupNewGrantControllerExtension sgce = new SetupNewGrantControllerExtension(new ApexPages.StandardController(testGrant) );
	
	//Add additional report
	sgce.addNewGrantReport();

	//Insert Reports/Items
	sgce.insertGrantReports();

	List<Grant_Reporting_Requirement__c> testgrr = [Select Id, Due_Date__c FROM Grant_Reporting_Requirement__c WHERE Grant_Management__c = :testGrant.Id ORDER BY Due_Date__c ASC]; 
	system.assertequals(3,testgrr.size());
	
	List<Grant_Report_Detail__c> testgitem = [Select Id, Date_Due_to_Reviewer__c, Short_Description__c FROM  Grant_Report_Detail__c WHERE Grant_Reporting__c = :testgrr[0].Id ORDER BY Short_Description__c ASC]; 
	system.assertequals(2,testgitem.size());
	
	system.assertequals('Budget Report',testgitem[0].Short_Description__c);
	system.assertequals('Narrative Report',testgitem[1].Short_Description__c);

	}
	
		
}