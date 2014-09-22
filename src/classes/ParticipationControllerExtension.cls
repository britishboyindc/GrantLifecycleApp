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
* Core to the Grant Lifecycle App is the notion of adding staff to each record so you can see who is involved with a particular record
* Staff may not be users however, but they can all be contacts. So we setup an Org that is Your Org, 
*    add contacts = staff, and then add those to the Staff Particpation Object
* The staff particpation object can then have lookups to multiple 'parent' objects like Grant and Account, 
*   so you can see at a glance, which records a staff contact is linked to 
* The map of lookups to objects is controlled by the ParticipationControllerSettings__c custom setting
*
* See also the ManageStaffParticipationTrigger for updates that inserting/updating will perform
*
* This code is wrapped in a component that can receive any source id it is refenced in the custom setting.
* It can also receive field sets to change the fields displayed
* It will also work in Chatter Publisher actions as well as VF pages
*/

public with sharing class ParticipationControllerExtension {

//Page Attributes
public Id objectId {get;set;} //Id of record to be updated
public String sNextPage {get;set;} //if set, user will naviage to page name; otherwise back to detail page of source id
public String sMode {get;set;} //diferent hbehavior for new vs update
public String sFieldSet {get;set;} //determines fields to display
public String sSource {get;set;} //action vs vf page

//Button Text
public String sButton {get;set;} //set text of button on page

public Boolean bPosted {get;set;} //Needed for Publisher Action Refresh

//Lists to manage records to insert, update and remove
public List <Staff_Participation__c> pinvolvement;
private List <Staff_Participation__c> deleteinvolvement {get;set;}
public ParticipationControllerSettings__c recordfielddetails; 

//For new Pages, we can default a source object with staff to copy in
public Id sourceRecordId {get;set;}
public ParticipationControllerSettings__c sourcefielddetails; 

//Identify current User to set default dept for search
Set<Id> uniqueselected; //to ensure staff aren't added twice
public Contact currentuser; //current user to identify any default values
public ContactSearchUtility csf {get;set;} //utility to power search functionality

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
        
        //identify satff contact record user for current user
        cuser = GrantManagementUtilities.getloggedinusercontactbyuserid();
        
        if (cuser!= null) {//First Check there is a user found based on logged in user
                 if (GrantManagementUtilities.getContactDepartment() != null) {//Is there a Department field in the c/s?
                    sUserDept = GrantManagementUtilities.getContactDepartment();
                    //sObject soDept = cuser.getsObject('Department__r');
                    csf.sdept = (String)cuser.get(sUserDept); //Set Contact Search Dept = Logged in User Department
                }
        currentuser = cuser;
        }
        
       //When new, look at source id for default staff to include
        if (sMode == 'NEW') {
        
            if (sourceRecordId != NULL) {
            
            sourcefielddetails = getPCESettings ( identifySourceObject(sourceRecordId) );
            getStaffPRecords (resultFields, sourcefielddetails, sourceRecordId);
           }
       
            //add current user if not already present in list
           if  (currentuser != null && !uniqueselected.contains(currentuser.Id) ) {
                pinvolvement.add(new Staff_Participation__c (Contact__c = currentuser.Id));
                uniqueselected.add(currentuser.Id);
           }

        }
        
        //it not new, assume update mode, so just retrieve existing records
        else { 
        getStaffPRecords (resultFields, recordfielddetails, objectId);
        }
   
        //if default dept for current user/contact, we can default initial search
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

//Refers to Contact Search facility
public PageReference search() {
    csf.generatevisiblecontacts();
    csf.getvisiblecontacts();
    return null;
}

//If user clicks select link from results, we add them to staff list if not already there
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

//If user clicks remove from current list, we check if already added to db; if yes, add to deletion list   
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

//Just return to detail record we came from
public pageReference cancelupdate() {
PageReference newpage =  new PageReference('/' + objectId);
newpage.SetRedirect(TRUE);
return newpage;
}

//button to process new records/updates
public pageReference processSelected() {
processSelectedRecords();
PageReference newpage;
bPosted = TRUE;
//Redirect to new page when set
if (sNextPage != null) {
    newpage = new PageReference('/apex/' + sNextPage + '?Id=' + objectId);
}
else {
    newpage =  new PageReference('/' + objectId);
}
newpage.SetRedirect(TRUE);
return newpage;
}

//For publisher actions, we reply on javscript to rerender back to page
public pageReference processAction() {
processSelectedRecords();
bPosted = TRUE;
return null;
}

//code to process new records/updates
public void processSelectedRecords(){
   //identify target lookup fields based on object id from custom setting  
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

//to enable multiple objects to use class, identify object of id passed in
private Schema.Sobjecttype identifySourceObject(Id recordId) {
return recordId.getSObjectType();
}

private ParticipationControllerSettings__c getPCESettings (Schema.Sobjecttype sourcetype) {
return ParticipationControllerSettings__c.getValues(sourcetype.getDescribe().getName());
}

//if Id passed in has no matching object in custom setting, throw error
private void setupRecordFields() {

    if (recordFieldDetails == NULL) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Missing Object in Custom Setting!'));
    }
    else {
    //if specific field name set passed in, get fields
    Schema.DescribeSObjectResult r = Staff_Participation__c.sObjectType.getDescribe();
        if (sFieldSet == NULL) {
            sFieldSet = 'npsprep_df14_1__Fields_for_Display_on_Component';
        }
    resultFields = r.FieldSets.getMap().get(sFieldSet).getFields();
    }  

}

//Get existing staffer records - either for defaults
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
                //when referencing defaults from, another object, clone and remove original lookup value
                Staff_Participation__c sprclone = spr.clone();
                //Then setup lookup to object id passed in
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