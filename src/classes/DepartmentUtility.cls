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

public with sharing class DepartmentUtility {
String squery;
public List<Department__c> DepartmentList {get;set;}
Boolean buseRollup;
Map<String, String []> ChildDepartmentQueryMap;
private Map<String, Department__c> DepartmentCodeMap;
private Map<String, Id> DepartmentNameMap;


public departmentUtility(Boolean bRollUp) {

        ChildDepartmentQueryMap = new Map<String, String []> ();

        buseRollup = bRollUp;
        if (buseRollup) {
        squery = 'Select Id, Name, Code__c , Policy_Dept__c, (Select Id, Name, Policy_Dept__c From ChildDepartments__r ORDER BY NAME ASC) From Department__c  WHERE Parent_Department__c = NULL ORDER BY NAME ASC';
        }
        else {
        squery = 'Select Id, Name, Code__c From Department__c  WHERE Roll_Up_Department__c = FALSE ORDER BY NAME ASC';
        }   
        DepartmentList = new List<Department__c> ();
        DepartmentList = database.query(squery);
    }

public departmentUtility() {
       DepartmentList = new List<Department__c> ();
       DepartmentList = [Select Id, Name, Code__c From Department__c ORDER BY Name ASC];
    }
    
public Map<String, Department__c> getCodeMap () {
    
    if (DepartmentCodeMap == null) {
        DepartmentCodeMap = new Map<String, Department__c> ();
    }   
    
    for (Department__c d:  DepartmentList) {
            if (d.Code__c != null) {
            DepartmentCodeMap.put(string.Valueof(d.Code__c), d);
            }
    }    

return DepartmentCodeMap;
}

public Map<String, Id> getNameMap () {
    if (DepartmentNameMap == NULL) {
        DepartmentNameMap = new Map<String, Id> ();
  
        for (Department__c d:  DepartmentList) {
                DepartmentNameMap.put(d.Name, d.Id);
        }
    }

return DepartmentNameMap;
}
    
public List<SelectOption> getDepartmentSelectList(Boolean bIncludeSelect, String sValue) {

List<String> PolicyDepts = new List<String> ();
List<String> NonPolicyDepts = new List<String> ();
    


List<SelectOption> depts = new  List<SelectOption>();

if (bIncludeSelect) {
    depts.add(new SelectOption('All', sValue));
}

        for (Department__c d: DepartmentList) {

                if (d.Policy_Dept__c) {
                    PolicyDepts.add(d.Name);
                }
                else {
                    NonPolicyDepts.add(d.Name);
                }

                if (buseRollup && d.ChildDepartments__r.size() > 0) {
                //Create a querymap for INCLUDES querys on child departments since stored as Strings
                List<String> ChildDepartments = new List<String> (); 
                    for (Department__c dchild: d.ChildDepartments__r) {
                        ChildDepartments.add('\'' + String.escapeSingleQuotes(dchild.Name) + '\'');
                        
                        if (dchild.Policy_Dept__c) {
                           PolicyDepts.add(dchild.Name);
                        }
                        else {
                            NonPolicyDepts.add(dchild.Name);
                        }
                    }
                
                    ChildDepartmentQueryMap.put(String.escapeSingleQuotes(d.name), ChildDepartments);
                    
                }
        }

        //now loop back and departments to pick list
        PolicyDepts.sort();
        NonPolicyDepts.sort();

        for (String s: PolicyDepts) {
            depts.add(new SelectOption(String.escapeSingleQuotes(s), s));
        }

        for (String s: NonPolicyDepts) {
            depts.add(new SelectOption(String.escapeSingleQuotes(s), s));
        }
                        
    return depts;
 }

public String getDeptSearchString (String sParent, String sFieldClause) {

String [] childquery; 
String sDepartmentQuery = sFieldClause;

if (ChildDepartmentQueryMap.containskey(sParent) ){
childquery = ChildDepartmentQueryMap.get(sParent);
}

if (childquery == null) {
    sDepartmentQuery += ' (\'' + sParent + '\') ';
    }

else {
    sDepartmentQuery += ' (';
        for (String s: childquery) {
        sDepartmentQuery += s + ',';
        }
sDepartmentQuery = sDepartmentQuery.removeEnd(',');
sDepartmentQuery += ')';
}
return sDepartmentQuery;
}

}