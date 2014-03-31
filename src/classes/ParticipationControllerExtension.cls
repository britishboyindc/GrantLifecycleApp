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

public with sharing class ParticipationControllerExtension {

//Page Attributes
public Id objectId {get;set;}
public String sNextPage {get;set;}
public String sMode {get;set;}
public String sFieldSet {get;set;}
public String sSource {get;set;}

//Button Text
public String sButton {get;set;}


//Needed for Publisher Action Refresh
public Boolean bPosted {get;set;}

public List <Staff_Participation__c> pinvolvement;
private List <Staff_Participation__c> deleteinvolvement {get;set;}
public ParticipationControllerSettings__c recordfielddetails; 

Set<Id> uniqueselected;
public Contact currentuser;
public ContactSearchUtility csf {get;set;}

//For new Pages, we can default a source object with staff to copy in
public Id sourceRecordId {get;set;}
public ParticipationControllerSettings__c sourcefielddetails; 

//Identify current User to set default dept for search
private Contact cuser;
public String sUserDept {get;set;}

//Used in to display SP fields relevant to source Object
public List<Schema.FieldSetMember> resultFields {get;set;}


public ParticipationControllerExtension() {
uniqueselected = new Set<Id> ();
//pinvolvement = new List<Staff_Participation__c> ();
deleteinvolvement = new List<Staff_Participation__c> ();
csf = new ContactSearchUtility();
bPosted = FALSE;
sButton = 'Save';
}

public void setupinvolvement() {
    
    recordfielddetails = getPCESettings ( identifySourceObject(objectId) );
    setupRecordFields();
    
    pinvolvement = new List<Staff_Participation__c> ();
    
        if (recordFieldDetails != null) {
        
        cuser = GrantManagementUtilities.getloggedinusercontactbyuserid();
        
        if (cuser!= null) {//First Check there is a user found based on logged in user
                 if (GrantManagementUtilities.getContactDepartment() != null) {//Is there a Department field in the c/s?
                    sUserDept = GrantManagementUtilities.getContactDepartment();
                    //sObject soDept = cuser.getsObject('Department__r');
                    csf.sdept = (String)cuser.get(sUserDept); //Set Contact Search Dept = Logged in User Department
                }
        currentuser = cuser;
        }
        
        if (sMode == 'NEW') {
       
        
            if (sourceRecordId != NULL) {
            
            sourcefielddetails = getPCESettings ( identifySourceObject(sourceRecordId) );
            getStaffPRecords (resultFields, sourcefielddetails, sourceRecordId);
           }
       
           if  (currentuser != null && !uniqueselected.contains(currentuser.Id) ) {
                pinvolvement.add(new Staff_Participation__c (Contact__c = currentuser.Id));
                uniqueselected.add(currentuser.Id);
           }

        }
        
        else { 
        getStaffPRecords (resultFields, recordfielddetails, objectId);
        }
   
        if (csf.sdept != 'All') {
            search();
        }

        if (sNextPage != NULL) {
        sButton = 'Save and Continue';
        }

    } //end null check
    
}

public List<Staff_Participation__c> getpinvolvement () {
//We can't reference SourceId in Constructor, so we get source info via getter
if (pinvolvement == null) {
    setupinvolvement();
}
    return pinvolvement;
}


public PageReference search() {
    csf.generatevisiblecontacts();
    csf.getvisiblecontacts();
    return null;
}


public PageReference setSelectedContact(){
    String cid = ApexPages.currentPage().getParameters().get('cid');
    //to ensure selection is unique, check if in unique set before adding to new selection
    if (!uniqueselected.contains(cid)) {
        uniqueselected.add(cid);
        Contact newc = csf.cmap.get(cid);  
        pinvolvement.add(new Staff_Participation__c(Contact__c = newc.Id ));
    }
    return null;
}  
   
public PageReference removeselectedcontact(){
    //to ensure selection is unique, remove from unique set so can be added again
    String rcid = ApexPages.currentPage().getParameters().get('rcid');
    if (uniqueselected.contains(rcid)) {
            uniqueselected.remove(rcid);
    
       for (integer i = 0; i< pinvolvement.size();i++ ) {
            if(pinvolvement[i].Contact__c == rcid) {
            
                if (pinvolvement[i].Id != null) {    
                    deleteinvolvement.add(pinvolvement[i]);
                }
   
                pinvolvement.remove(i);
                
                break;
            }
        }
    }
    return null;
}  

public pageReference cancelupdate() {
PageReference newpage =  new PageReference('/' + objectId);
newpage.SetRedirect(TRUE);
return newpage;
}

public pageReference processSelected() {
processSelectedRecords();
PageReference newpage;
bPosted = TRUE;
if (sNextPage != null) {
newpage = new PageReference('/apex/' + sNextPage + '?Id=' + objectId);
}
else {
newpage =  new PageReference('/' + objectId);
}
newpage.SetRedirect(TRUE);
return newpage;
}

public pageReference processAction() {
processSelectedRecords();
bPosted = TRUE;
return null;
}

public void processSelectedRecords(){
    
    if (pinvolvement.size() > 0) {
           for (Staff_Participation__c spr: pinvolvement) {
               sObject so = (sObject)spr; //Need to cast here so we can do dynamic put
               if (objectId != null) {
                   if ( so.get(recordFieldDetails.Staff_Participation_Field__c) == null) {
                        so.put(recordFieldDetails.Staff_Participation_Field__c, objectId);
                      }
               }
               
               }           
               
               upsert pinvolvement;
    }                 
           if (deleteinvolvement.size() > 0) {           
               delete deleteinvolvement;
           }
           
}       

private Schema.Sobjecttype identifySourceObject(Id recordId) {
return recordId.getSObjectType();
}

private ParticipationControllerSettings__c getPCESettings (Schema.Sobjecttype sourcetype) {
return ParticipationControllerSettings__c.getValues(sourcetype.getDescribe().getName());
}

private void setupRecordFields() {

    if (recordFieldDetails == NULL) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Missing Object in Custom Setting!'));
    }
    else {
    Schema.DescribeSObjectResult r = Staff_Participation__c.sObjectType.getDescribe();
        if (sFieldSet == NULL) {
            sFieldSet = 'Fields_for_Display_on_Component';
        }
    resultFields = r.FieldSets.getMap().get(sFieldSet).getFields();
    }  

}

private void getStaffPRecords (List<Schema.FieldSetMember> searchFields, ParticipationControllerSettings__c pceFieldDetails, Id searchId) {

 String sQuery = 'SELECT Contact__c, Contact__r.Email, ';
        
        //Check Field Set for fields to include
         for(Schema.FieldSetMember f : searchFields ){
           sQuery += f.getFieldPath() + ', ';
        }
    
        sQuery += pceFieldDetails.Staff_Participation_Field__c + ',';
        
        if (sMode == 'NEW') {
            sQuery += recordFieldDetails.Staff_Participation_Field__c + ',';
        }
        
        sQuery += ' Id FROM Staff_Participation__c ';
        sQuery += ' WHERE  ' + pceFieldDetails.Staff_Participation_Field__c + ' = :searchId';
        sQuery += ' ORDER BY Contact__r.LastName ASC'; 
             
        List<Staff_Participation__c> sprs = database.query(sQuery);    
    
        for ( Staff_Participation__c spr : sprs ) {
            if (sMode == 'NEW') {
                Staff_Participation__c sprclone = spr.clone();
                sprclone.put(sourcefielddetails.Staff_Participation_Field__c,null);
                pinvolvement.add(sprclone);
            }
            else {
                pinvolvement.add(spr);
            }
        uniqueselected.add(spr.Contact__c);
        }
        
}

} //end class