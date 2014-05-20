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
* Utility class for functions we use in Grant Management app, mostly to map 'staffer' Contacts to users
*/

Public Class GrantManagementUtilities {

private static String ContactDepartmentField;
private static Id currentUserContactId;
private static Map<Id, Id> usermap; 
private static Map<String, GrantManagementSettings__c> gmSettings;

//auto include custom settings
static{
        gmSettings = GrantManagementSettings__c.getAll();
    }


//Department lookup field can be set by user, so includ eutility to retrieve for SOQL
public static String getContactDepartment() {
if  (ContactDepartmentField == NULL) {
       ContactDepartmentField = getSettingValue('ContactDepartment'); 
    }
return ContactDepartmentField;
}

//Pass in last of Staffer Contacts, and get back user ids for those contacts 
public static Map<Id, Id> getUserMapfromContactRecord(Set<Id> ContactIds) {

if (usermap == NULL) {
   String sUserField = getSettingValue('UserFieldonContact'); 
    List<sObject> cons =  database.query ('Select Id, ' + sUserField + ' FROM Contact WHERE Id = :ContactIds');
    usermap = new Map<Id, Id> ();

    if (cons.size() > 0) {

            for (sObject c: cons) {
                if ( c.get(sUserField) != null) {
                    usermap.put(c.Id, (Id)c.get(sUserField));
                }
             }
    }
}

return usermap;

}

//If we know the user, is there also a contact staff record?
public static Contact getloggedinusercontactbyuserid() {

//Get Department Field from Contact
if (getContactDepartment() != null ) {
String sUserField = getSettingValue('UserFieldonContact');

    Id userId = UserInfo.getUserId();
    String sQuery = 'Select Id, Account.Name, FirstName, LastName, Email, ';
    squery += getContactDepartment();
    squery += ' FROM Contact WHERE ' + sUserField + ' = :userId';

Contact [] cons = database.query(sQuery);

if (cons.size() > 0) {
    return cons[0];
}
}
 
return null;
}

//We also store the staffer contact id on user record 
public static Id getloggedinusercontactid() {
    if (currentUserContactId == null) {
   String sContactField = getSettingValue('ContactIdFieldonUser');
   Id sUserId = userinfo.getUserId();
   String sq = 'Select Id, ' + sContactField +  
                       ' FROM USER  WHERE Id = :sUserId ' + 
                       ' AND ' + sContactField + ' != NULL';

   sObject [] capusers = database.query(sq);
        if (capusers.size() > 0) {
            currentUserContactId = (Id)capusers[0].get(sContactField);
        }
    }

        return currentUserContactId;
}    

//simple way to retrieve custom setting value
private static String getSettingValue (String sKey) {
String s;

   if (gmSettings.ContainsKey(sKey) ) {
            if (gmSettings.get(sKey).String_Value__c != null) {
                s = gmSettings.get(sKey).String_Value__c; 
            }
      }
return s;
}

} //end class