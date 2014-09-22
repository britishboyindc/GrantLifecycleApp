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
* Along with Staff, Issues are core to a think tank' soperations, so we provide utility to add issues to any parent object
* code powers a component that can be added to any VF page to display issues for Id of the calling object
* Issue Intersection can have lookups to many parents, so we can reports on issues across different objects via single report
* Issues can have parent groupings, and multiple taxonomys e.g. Issues, Actions, Priorities - set in Custom Setting
* Update can be via page or publisher action
*/

public with sharing class IssuesIntersectionController {

//Page Attributes
public Id objectId {get;set;} //Id of record to be updated
public String sNextPage {get;set;} //if set, user will naviage to page name; otherwise back to detail page of source id
public String sMode {get;set;} //diferent hbehavior for new vs update
public String sSource {get;set;} //action vs vf page

//If we include a source for settings defaults
public Id sourcerecordId {get;set;}

private Boolean bInitialState;
public Boolean bPosted {get;set;}

public Issue_Utility_Settings__c recordFieldDetails {get;set;}

private Set<Id> IssueIntersectionIds;    
private List<Issue_Intersection__c> deleteIssues; 
private Map<String, List<Issue__c> > NewIssueMap;

//Issues can be split into multiple taxonomies - each then appear in separate section on page 
private List<String> TaxonomySections;
public List<issueselectionwrapper> IssuesIntersectionWrapper;  
public Map<String, List<issueselectionwrapper> > TaxonomySectionMap {get;set;}

//Issue Category Selection to enable filtering by Parent Issue
public List<SelectOption> cIssues {get;set;}
private Map<Id, Issue__c> ChildIssueMap;
public List<Issue__c> newIssuesforSelection {get;set;} 
private Map<Id, issueselectionwrapper> issueMap;    

private DepartmentUtility DU;
public Id cIssueId {get;set;} //page assignment variable

//Constructor
public IssuesIntersectionController() {

        bInitialState = TRUE;
        bPosted = FALSE;
       
        TaxonomySections = Issue_Utility_Settings__c.getValues('TaxonomyStrings').String_Value__c.split(';');
        
        newIssuesforSelection = new List<Issue__c> ();
        
        IssueIntersectionIds = new Set<Id> ();
        deleteIssues = new List<Issue_Intersection__c> ();
        
        issueMap = new Map<Id, issueselectionwrapper> ();
        
        DU = new DepartmentUtility();
        setupSelectOptions();
}


//Updated when parent issue category select is updated
public PageReference search() {

newIssuesforSelection.clear();
List<Issue__c> IssueMapLoop = NewIssueMap.get(cIssueId);
for (Integer i = 0; i < IssueMapLoop.size() ; i++) {

    if (!issueMap.containskey(IssueMapLoop[i].Id) ) {
    newIssuesforSelection.add(IssueMapLoop[i]);
    }
    
}
return null;
}

//For updates, retrieve current selected issues
public void retrieveCurrentIssues() {
    
    recordFieldDetails = getIUSSettings (identifySourceObject(objectId) );
    setupRecordFields();
    
    if (recordFieldDetails != null) {
    
    String sQuery = 'SELECT Issue__c, Object__c, Record_Name__c, Default_for_Related_Item__c, ';
    //Identify lookup field to include for object id passed into component and also filter by it
        sQuery += recordFieldDetails.Issue_Intersection_Field__c + ',';
        sQuery += ' Id FROM Issue_Intersection__c ';
        sQuery += ' WHERE  ' + recordfielddetails.Issue_Intersection_Field__c + ' = :objectId';
        sQuery += ' ORDER BY Issue__r.Name ASC'; 
         
    List<Issue_Intersection__c> iirs = database.query(sQuery);    

//Identify currently selected issues so they don't appear in select lists
    for (Issue_Intersection__c issueir : iirs ) {
        Issue__c newIssue = ChildIssueMap.get(issueir.Issue__c);  
        issueMap.put(newIssue.Id, new issueselectionwrapper( issueir, newIssue));
    
        }
    createDisplayMap(); //to enable taxonomy functionality 
    }

}

public List<String> getTaxonomySections() {

if (bInitialState == TRUE) {
    
        if (sMode == 'UPDATE' || sMode== 'UPDATEWITHDEFAULT') {
            retrieveCurrentIssues(); //update mode so get current issues
        }
       
        else if (sMode == 'NEWWITHDEFAULT') {
            getDefaultIssues(); //new with default allows default issues from a source object - e.g. opty to grant
        }
    
}
    
    bInitialState = FALSE;
    
return TaxonomySections;

}

//User selects an issue on page
public PageReference setSelectedIssue(){
    
    String issueId = ApexPages.currentPage().getParameters().get('cid');
    Issue__c newIssue = ChildIssueMap.get(issueId);
    
    //Create new record for page wrapper
    sObject so = new Issue_Intersection__c();
    so.put('Issue__c', newIssue.Id);
    so.put('Object__c',  'Current');
    so.put('Record_Name__c','User');
    so.put(recordfielddetails.Issue_Intersection_Field__c, objectId);
    
    issueselectionwrapper iinew = new issueselectionwrapper( (Issue_Intersection__c)so, newIssue);
    issueMap.put(issueid, iinew);
   
    List<issueselectionwrapper> templist = TaxonomySectionMap.get(newIssue.Taxonomy__c);
    templist.add(iinew);
    TaxonomySectionMap.put(newIssue.Taxonomy__c, templist); //add to display map to make sure taxonmy section display correctly
    //refresh search so refelct newly selcted issue
    if (cIssueId != NULL) { 
        search();
    }
    return null;
}  

//delete an issue but make available to add back in case removed in error   
public PageReference removeselectedissue(){
    String issueId = ApexPages.currentPage().getParameters().get('rcid');
   
    if (issueMap.containskey(issueid)) {
        //if already in db, add to deletion processing
        if (issueMap.get(issueid).issueintersection.Id != null) {//already committed to db    
              deleteIssues.add(issueMap.get(issueid).issueintersection);
        }
        issueMap.remove(issueid);
    }
   
    createDisplayMap();

    if (cIssueId != NULL) { 
            search();
    }

return null;
}  


public pageReference processSelectedIssues(){

if (recordFieldDetails == NULL) {
return cancelupdate();
}

if (processSelected() ) { 

    PageReference newpage;
        if (sNextPage != null) {//if next page included, navaigate user there
            newpage = new PageReference('/apex/' + sNextPage + '?Id=' + objectId);
        }
        else {
            newpage =  new PageReference('/' + objectId);//otherwise, back to detail page
        }
        newpage.SetRedirect(TRUE);
            return newpage;
    }
    else {
        return null;
    }

}

public pageReference processAction() {
    processSelected();
    bPosted = TRUE; //for publisher action refresh
return null;
}

public pageReference cancelupdate() {
PageReference newpage =  new PageReference('/' + objectId);
newpage.SetRedirect(TRUE);
return newpage;
}

//loop through wrapper and add new issues
private Boolean processSelected(){
List<Issue_Intersection__c> issuesforintersection = new List<Issue_Intersection__c> ();

sObject so; 

    for (String s: TaxonomySectionMap.keyset() ) {
        
        for (issueselectionwrapper iiu: TaxonomySectionMap.get(s) ) {
            issuesforintersection.add(iiu.issueintersection);
        }
    }
    
    try {
        upsert issuesforintersection;
        delete deleteIssues;  //process deletions
    return TRUE;
    }
    
    catch (Exception Ex) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error:' + Ex.getmessage()));
    return FALSE;
    }

}

//for deliverables, we provide ability to get defults from many sources (Project, grant, user, departments)
public void getDefaultIssues () {

     
        recordfielddetails = getIUSSettings (identifySourceObject(objectId) );
        setupRecordFields();
        
        if (recordFieldDetails != null) {  
            
            if (recordfielddetails.Issue_Intersection_Field__c == 'npsprep_df14_1__Deliverable__c' ) {
                    Set<Id> IssueIntersectionIds = new Set<Id> ();
                    
                    Deliverable__c prod = [Select Id, Name, Project__c, Departments__c, 
                                                (Select Id, Contact__c 
                                                FROM Staff_Participations__r) 
                                           FROM Deliverable__c 
                                           WHERE Id = :objectId];
                    
                    if (prod.Project__c != null) {
                        IssueIntersectionIds.add(prod.Project__c);
                    }
                    
                    if (prod.Staff_Participations__r.size() > 0) {
                    
                        for (Staff_Participation__c sp: prod.Staff_Participations__r) {
                            IssueIntersectionIds.add(sp.contact__c);
                        }
                    }
                
                    if (prod.Departments__c != null) {
                
                        Map<String, Id> dmap = DU.getnamemap();
                        List<String> pdepts = prod.Departments__c.split(';');
                       
                        for (String s: pdepts) {
                            if (dmap.containskey(s) ) {
                                IssueIntersectionIds.add(dmap.get(s));
                            }
                        }
                   
                    }
                //retrieve all default issues based on Ids identified
                    for (Issue_Intersection__c iis: [Select Id, Record_Name__c, Object__c, 
                                                        Issue__r.Name, Issue__r.Taxonomy__c, 
                                                        Deliverable__c from  Issue_Intersection__c 
                                                    WHERE Record_Id__c IN :IssueIntersectionIds 
                                                    AND Default_for_Related_Item__c = TRUE 
                                                    ORDER BY Issue__r.Name ASC]) {
                
                        Issue__c newIssue = ChildIssueMap.get(iis.Issue__c);
                        
                        sObject so = new Issue_Intersection__c();
                        so.put('Issue__c', newIssue.Id);
                        so.put('Object__c',  iis.Object__c);
                        so.put('Record_Name__c',iis.Record_Name__c);
                        so.put(recordfielddetails.Issue_Intersection_Field__c, objectId);
                    
                        issueMap.put(iis.Issue__c, new issueselectionwrapper( (Issue_Intersection__c)so, newIssue));
                       
                        }
        
            }
        createDisplayMap();
        }

} //end getDefaultIssues

//Issus have parent/child relationship - select parent and see child issues to select from
public void setupSelectOptions () {
    NewIssueMap = new Map<String, List<Issue__c> > ();
    ChildIssueMap = new Map<Id, Issue__c> ();
    cIssues = new List<SelectOption>();
    cIssues.add(new SelectOption('', 'Select Issue Area'));
    
    for (Issue__c issues: [Select Id, Name, (Select Id, Name, Taxonomy__c from Issues__r) FROM Issue__c WHERE Parent_Issue__c = NULL] ) {
        
            if (issues.Issues__r.size() > 0) {
                    cIssues.add(new SelectOption(issues.Id, issues.Name));
                    NewIssueMap.put(issues.Id, issues.Issues__r);//store in map for easy retrieval when adding
                        for (Issue__c ichildissue: issues.Issues__r) {
                            ChildIssueMap.put(ichildissue.Id, ichildissue);
                        }
            }
    }
    
}

//Split issues into taxonomy sections on page
private void createDisplayMap () {

   TaxonomySectionMap = new Map<String, List<issueselectionwrapper> > ();
   
   for (String sTax : TaxonomySections) {
        TaxonomySectionMap.put(sTax, new List<issueselectionwrapper> () );
       }

   for (issueselectionwrapper iiw: issueMap.values() ) {
            system.debug(iiw.issue.Taxonomy__c);
            List<issueselectionwrapper> templist = TaxonomySectionMap.get(iiw.issue.Taxonomy__c);
            templist.add(iiw);
            TaxonomySectionMap.put(iiw.issue.Taxonomy__c, templist);
       }

}

//Use wrapper so we can identify issue and information from issue intersection such as source
public class issueselectionwrapper {

    public Issue__c issue {get;set;}
    public Issue_Intersection__c issueintersection {get;set;}
    
    public issueselectionwrapper(Issue_Intersection__c iiw, Issue__c issue) {
        this.issue = issue; 
        issueintersection = iiw;
    }

} //end issueselectionwrapper

private Schema.Sobjecttype identifySourceObject(Id recordId) {
return recordId.getSObjectType();
}

//get details of lookups from Custom Setting so we can map object id to it's lookup
private Issue_Utility_Settings__c getIUSSettings (Schema.Sobjecttype sourcetype) {
return Issue_Utility_Settings__c.getValues(sourcetype.getDescribe().getName());
}

//if not mapping in custom setting, throw error
private void setupRecordFields() {

    if (recordFieldDetails == NULL) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Missing Object in Custom Setting!'));
       
    }
}

}