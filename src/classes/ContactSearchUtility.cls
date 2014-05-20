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
* Used by Staff Particpation controller to enable search by Your Org (as defined in C/Setting) or by LastName search across all contacts 
*/

public class ContactSearchUtility {

//Two options - show the regular search, or your org by department
public Boolean bshowSearch {get;set;}
public Boolean bshowCAP {get;set;}    

@testvisible private List<Contact> visiblecontacts;

//Displays departments to quickly filter by invoking Department Utility
public List<SelectOption> cDepartments {get;set;}

//To make retrieval quicker, we store all contacts in map 
public Map<Id, Contact> cmap;

//for text search across all contacts
public String searchText {get;set;}
public String searchFNText{get;set;}
public String resultNo {get;set;}

//Selected Department on page
public String sdept {get;set;}

//Utility class to enable retrieval of department data for searching
DepartmentUtility du;

// jrb: 20130517
private String sDepartmentFieldname;

public ContactSearchUtility() {

    //Retrieve name of field we store department data in for search filter
    sDepartmentFieldname = GrantManagementUtilities.getContactDepartment();
   
    du = new DepartmentUtility(TRUE);
    //Setup select options from Department Object
    cDepartments = du.getDepartmentSelectList(TRUE, 'Select Department');

    bshowSearch = FALSE;
    bshowCAP = TRUE;
    visiblecontacts = new List<Contact> ();
    cmap = new Map<Id, Contact> ();
    sdept = 'All';
}

public List<Contact> getvisiblecontacts() {
    return visiblecontacts;
}

//User clicks link/button to show text search
public PageReference cshowsearch() {
    bshowSearch = TRUE;
    bshowCAP = FALSE;
    visiblecontacts.clear();
    return null;
}

//user clicks button to search by their org 
public PageReference cshowCAP() {
    bshowSearch = FALSE;
    bshowCAP = TRUE;
    visiblecontacts.clear();
    return null;
}

//Dynamically build search string
private String getsearchstring() {
    String query = 'Select Id, ';
    
    if (sDepartmentFieldname != NULL) {
    query += sDepartmentFieldname + ','; 
    }
    
    query += ' FirstName, LastName, Email, Accountid, Account.Name from Contact ';
      
  //for searching in your org, pull account id value out of c/setting
    if (bshowCAP == TRUE) {
        query += 'WHERE AccountId = \'' + GrantManagementSettings__c.getValues('OurAccountId').Id_Value__c + '\'';

        //if department selected in select list, filter by that as well
        if (sdept != 'All') {
            query += ' AND ' + sDepartmentFieldname + ' ' + du.getDeptSearchString(sdept, 'IN');
        }

        query += ' Order by LastName ASC, FirstName ASC';

        } 
        
        //or use text search by last name, first name
        else {
        String conditions = '';
        //only execute if there is a last name to search for...
        if (!String.IsEmpty(searchText)){
            conditions += ' lastname LIKE \'%' + searchText + '%\' AND ';
        }

        if (!String.IsEmpty(searchFNText) ) {
            conditions += 'firstname LIKE \'%' + searchFNText + '%\' AND ';
        }
        //Only search if there are some search criteria
        if (conditions != ''){
            query += 'WHERE ' + conditions + ' IsDeleted = FALSE ';
            query += ' ORDER by LastName ASC, FirstName ASC, Account.Name ASC  LIMIT 1000';
        }
        //if no conditions, don't execute
        else {
            query = '';
        }
    }
    return query;
}

//Return Contacts at Your Org
//generate list of contacts to display
public void generatevisiblecontacts() {
    if (visiblecontacts != null) {
        visiblecontacts.clear();
    }
    if (getsearchstring() != '') {
        system.debug(getsearchstring());
        if (!String.IsEmpty(getsearchstring()) ) { 
        visiblecontacts = database.query(getsearchstring()); 
        for (Contact c: visiblecontacts) {
            cmap.put(c.id, c);
        }
    }
}

}


}