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
* Convert an opportunity to a grant using wizard
*/

public with sharing class ConvertOpportunitytoGrantController {

//Source Opty based on Standard Controller
private final Opportunity opty;

//Target Grant
public Grant_Management__c gm {get;set;}

//Dynamically display target grant fields for edit - section 1 for shorter fields, section 2 for long text type fields
public List<String> GrantFields1 {get;set;}
public List<String> GrantFields2 {get;set;}

//For chatter attachment processing/sharing
public ChatterUtilityClass ChatterUtility {get;set;}

public Boolean bsaveandnew {get;set;}

//Current user/contact
private Contact cuser;

// The extension constructor initializes the private member 
//variable by using the getRecord method from the standard controller.
    public ConvertOpportunitytoGrantController (ApexPages.StandardController stdController) {
        this.opty = (Opportunity)stdController.getRecord();
        gm = new Grant_Management__c();
        setupGrant();
        ChatterUtility = new ChatterUtilityClass();
        //get current Chatter Attachments from Opportunity
        ChatterUtility.getAttachments(this.opty.Id); 
        }
    
    public pagereference createGrantRecord () {
          //insert grant
          insert gm;
          //Post any shared attachments to chatter feed
          ChatterUtility.setupAttachmentstoShare(gm.Id);
          
          //Post back on source Opportunity feed
          String sPost = 'A new Grant Record was created for this Opportunity';
          ConnectAPIHelper.postFeedItemWithMentions(null, opty.Id, sPost);
        
          //direct to staff setup page
          PageReference gparticipate = new PageReference('/apex/GrantWizardP2?id='+gm.Id+'&sId=' + opty.Id);
          return gparticipate;
    }
    

private void setupGrant () {

GrantFields1 = new List<String> ();
GrantFields2 = new List<String> ();
//Setup target grant fields for display
//Fields are stored in a custom setting insteac of field set so we can map source to target
List<Opty_Grant_Fields__c> GrantFieldList = [Select Id, Name, Grant_Field__c, Page_Order__c, Section_on_Page__c 
                               FROM Opty_Grant_Fields__c 
                               ORDER BY Section_on_Page__c, Page_Order__c];

//Set up query to retrieve all target fields from source opportunity
//and setup list of fields for page display
String sId = opty.Id;
String sQuery = 'Select ';

for (Opty_Grant_Fields__c s: GrantFieldList ) {
    sQuery += s.Name + ',';
        if (s.Section_on_Page__c == 1) {
            GrantFields1.add(s.Grant_Field__c);
        }
        else if (s.Section_on_Page__c == 2) {
            GrantFields2.add(s.Grant_Field__c);
        }
    }

sQuery += ' isDeleted from Opportunity WHERE Id = :sId';

//set target values on grant to source values on Opty based on mapping in custom setting
sObject optyo = database.query(sQuery);

   sObject gmo = gm;
    
        for (Opty_Grant_Fields__c s: GrantFieldList ) {
             gm.put( s.Grant_Field__c, optyo.get(s.Name)  );  
        }

}


}