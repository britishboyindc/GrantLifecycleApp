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

public with sharing class IssuesIntersectionController {

//Page Attributes
public Id objectId {get;set;}
public String sNextPage {get;set;}
public String sMode {get;set;}
public String sSource {get;set;}

//If we include a source for settings defaults
public Id sourcerecordId {get;set;}


private Boolean bInitialState;
public Boolean bPosted {get;set;}

public Issue_Utility_Settings__c recordFieldDetails {get;set;}

private Set<Id> IssueIntersectionIds;    
private List<Issue_Intersection__c> deleteIssues; 
private Map<String, List<Issue__c> > NewIssueMap;

private Map<Id, Issue__c> ChildIssueMap;

public List<Issue__c> newIssuesforSelection {get;set;} 

private Map<Id, issueselectionwrapper> issueMap;    

private List<String> TaxonomySections;

public List<issueselectionwrapper> IssuesIntersectionWrapper;  

public Map<String, List<issueselectionwrapper> > TaxonomySectionMap {get;set;}

public List<SelectOption> cIssues {get;set;}

private DepartmentUtility DU;

public Id cIssueId {get;set;}

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


public void retrieveCurrentIssues() {
    
    recordFieldDetails = getIUSSettings (identifySourceObject(objectId) );
    setupRecordFields();
    
    if (recordFieldDetails != null) {
    
    String sQuery = 'SELECT Issue__c, Object__c, Record_Name__c, Default_for_Related_Item__c, ';
    
        sQuery += recordFieldDetails.Issue_Intersection_Field__c + ',';
        sQuery += ' Id FROM Issue_Intersection__c ';
        sQuery += ' WHERE  ' + recordfielddetails.Issue_Intersection_Field__c + ' = :objectId';
        sQuery += ' ORDER BY Issue__r.Name ASC'; 
         
    List<Issue_Intersection__c> iirs = database.query(sQuery);    


    for (Issue_Intersection__c issueir : iirs ) {
        Issue__c newIssue = ChildIssueMap.get(issueir.Issue__c);  
        issueMap.put(newIssue.Id, new issueselectionwrapper( issueir, newIssue));
    
        }
    //search();
    createDisplayMap();  
    }

}

public List<String> getTaxonomySections() {

if (bInitialState == TRUE) {
    
        if (sMode == 'UPDATE' || sMode== 'UPDATEWITHDEFAULT') {
            retrieveCurrentIssues();
        }
       
        else if (sMode == 'NEWWITHDEFAULT') {
            getDefaultIssues();
        }
    
}
    
    bInitialState = FALSE;
    
return TaxonomySections;

}

//List<issueselectionwrapper> tmap = TaxonomySectionMap.get(newIssue.Taxonomy__c);

public PageReference setSelectedIssue(){
    
    String issueId = ApexPages.currentPage().getParameters().get('cid');
    Issue__c newIssue = ChildIssueMap.get(issueId);
    
    sObject so = new Issue_Intersection__c();
    so.put('Issue__c', newIssue.Id);
    so.put('Object__c',  'Current');
    so.put('Record_Name__c','User');
    so.put(recordfielddetails.Issue_Intersection_Field__c, objectId);
    
    issueselectionwrapper iinew = new issueselectionwrapper( (Issue_Intersection__c)so, newIssue);
    issueMap.put(issueid, iinew);
   
    List<issueselectionwrapper> templist = TaxonomySectionMap.get(newIssue.Taxonomy__c);
    templist.add(iinew);
    TaxonomySectionMap.put(newIssue.Taxonomy__c, templist);

    if (cIssueId != NULL) { 
        search();
    }
    return null;
}  

   
public PageReference removeselectedissue(){
    String issueId = ApexPages.currentPage().getParameters().get('rcid');
   
    if (issueMap.containskey(issueid)) {
        
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
        if (sNextPage != null) {
            newpage = new PageReference('/apex/' + sNextPage + '?Id=' + objectId);
        }
        else {
            newpage =  new PageReference('/' + objectId);
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
    bPosted = TRUE;
return null;
}

public pageReference cancelupdate() {
PageReference newpage =  new PageReference('/' + objectId);
newpage.SetRedirect(TRUE);
return newpage;
}

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
        delete deleteIssues;  
    return TRUE;
    }
    
    catch (Exception Ex) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error:' + Ex.getmessage()));
    return FALSE;
    }

}


public void getDefaultIssues () {

     
        recordfielddetails = getIUSSettings (identifySourceObject(objectId) );
        setupRecordFields();
        
        if (recordFieldDetails != null) {  
            
            if (recordfielddetails.Issue_Intersection_Field__c == 'Deliverable__c' ) {
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

public void setupSelectOptions () {
    NewIssueMap = new Map<String, List<Issue__c> > ();
    ChildIssueMap = new Map<Id, Issue__c> ();
    cIssues = new List<SelectOption>();
    cIssues.add(new SelectOption('', 'Select Issue Area'));
    
    for (Issue__c issues: [Select Id, Name, (Select Id, Name, Taxonomy__c from Issues__r) FROM Issue__c WHERE Parent_Issue__c = NULL] ) {
        
            if (issues.Issues__r.size() > 0) {
                    cIssues.add(new SelectOption(issues.Id, issues.Name));
                    NewIssueMap.put(issues.Id, issues.Issues__r);
                        for (Issue__c ichildissue: issues.Issues__r) {
                            ChildIssueMap.put(ichildissue.Id, ichildissue);
                        }
            }
    }
    
}

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

private Issue_Utility_Settings__c getIUSSettings (Schema.Sobjecttype sourcetype) {
return Issue_Utility_Settings__c.getValues(sourcetype.getDescribe().getName());
}

private void setupRecordFields() {

    if (recordFieldDetails == NULL) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Missing Object in Custom Setting!'));
       
    }
}

}