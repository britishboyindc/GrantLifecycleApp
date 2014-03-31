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

public with sharing class DeliverablesWizardControllerExtension {

private final Deliverable__c prod;
    
public String serrmsg {get;set;}
public String pcodegerror {get;set;}
    
public List<SelectOption> projectcodes {get;set;}
public Id projectId {get;set;}

public List<SelectOption> grantcodes {get;set;}
public Id grantid {get;set;}

public List<SelectOption> Orgs {get;set;}

// The extension constructor initializes the private member variable acct by using the getRecord method from the standard controller.    
public DeliverablesWizardControllerExtension (ApexPages.StandardController stdController) {
    this.prod = (Deliverable__c)stdController.getRecord();
    setupSelectLists();
    
    prod.Product_Type__c = 'Column';
    prod.Outreach_Activities__c ='Online Posting';
    }


public PageReference authorpage(){
   
    if (prod.Project__c == null && projectId != null) { 
        prod.Project__c = projectId;
    }
    
    try{
       upsert prod;
    
       //Create relationship to Grant if selected
       if (grantid != null) {
       Grant_Deliverable__c gd = new Grant_Deliverable__c(Deliverable__c = prod.Id, Grant_Management__c = grantid);
       insert gd;
       } 
    
       return new PageReference('/apex/ProductWizardP2?Id='+prod.Id);
       
    } //end try
       
    catch (exception Ex) {
           // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getmessage()  ));
        }
        return null;
}


private void setupSelectLists () {
 //build picklist for Projects List
    
    grantcodes = new List<SelectOption> ();
    grantcodes.add(new SelectOption('','Select Grant'));
    for (Grant_Management__c c: [Select Id, Name FROM Grant_Management__c WHERE Closed__c = FALSE Order By Name ASC]) {
            grantcodes.add(new SelectOption(c.id,c.Name));
        }  

    //build picklist for Projects List
    projectcodes = new List<SelectOption> ();
    projectcodes.add(new SelectOption('','Select Project'));
    for (Project__c c: [Select Id, Project_Grant_Manager__c, Name from Project__c WHERE Closed__c = FALSE Order By Name ASC]) {
        projectcodes.add(new SelectOption(c.id,c.Name));
        }
}

} //end class