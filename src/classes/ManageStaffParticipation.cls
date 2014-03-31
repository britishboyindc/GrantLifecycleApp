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

public class ManageStaffParticipation {
/* With reference to Steve Andersen's post: http://gokubi.com/archives/two-interesting-ways-to-architect-apex-triggers */ 
public static List<Staff_Participation__c> staffforupdatelist;

public static void afterInsert(Staff_Participation__c[] newstaff) {

staffforupdatelist = new List<Staff_Participation__c> ();

for (Staff_Participation__c sp: newstaff) {
    if (sp.Lead_Staffer__c) {
    staffforupdatelist.add(sp);
    }
}

identifyStaffParticpationFieldUpdates(staffforupdatelist);

} //end method

public static void afterUpdate(Staff_Participation__c[] newstaff, Map<Id, Staff_Participation__c> oldstaffmap) {

staffforupdatelist = new List<Staff_Participation__c> ();

for (Staff_Participation__c sp: newstaff) {
    if (//Only process when contact changes or lead staff changes 
         (sp.Contact__c != oldstaffmap.get(sp.Id).Contact__c) || 
         (sp.Lead_Staffer__c != oldstaffmap.get(sp.Id).Lead_Staffer__c)
       )   {
    staffforupdatelist.add(sp);
    }
}

identifyStaffParticpationFieldUpdates(staffforupdatelist);
}

public static void afterDelete(Staff_Participation__c[] oldstaff) {

staffforupdatelist = new List<Staff_Participation__c> ();

for (Staff_Participation__c sp: oldstaff) {
    if (sp.Lead_Staffer__c) {
    staffforupdatelist.add(sp);
    }
}
identifyStaffParticpationFieldUpdates(staffforupdatelist);


}

private static void identifyStaffParticpationFieldUpdates(Staff_Participation__c [] stafflist) {

Map<String, Set<Id> > recordIdMap = new Map<String, Set<Id> > ();

Map<Id, Set<Id> > chatterUpdateMap = new Map<Id, Set<Id> > ();

Map<String, ParticipationControllerSettings__c> pcesettings = ParticipationControllerSettings__c.getall();

for (String s: pcesettings.keyset() ) {
recordIdMap.put(s,new Set<Id>() ); 
}


for (Staff_Participation__c sp: stafflist) {

    for (String s: pcesettings.keyset() ) {
        if (sp.get(pcesettings.get(s).Staff_Participation_Field__c)!= null ) {
            Id IdtoUpdate = (Id)sp.get(pcesettings.get(s).Staff_Participation_Field__c);
            
            Set<Id> contacttempset =  new Set<Id> ();
            
            if (chatterUpdateMap.containskey(sp.Contact__c)) {
            contacttempset = chatterUpdateMap.get(sp.Contact__c);
            }
            contacttempset.add(IdtoUpdate);
            chatterUpdateMap.put(sp.Contact__c, contacttempset);

            Set<Id> tempset =  recordIdMap.get(s);
            tempset.add(IdtoUpdate);
            recordIdMap.put(s, tempset );
            continue;
        }
    
    }
}   

    for (String s: recordIdMap.keyset() ) {
        if (recordIdMap.get(s).size() > 0) {
        processUpdates(recordIdMap.get(s), s);
        }
    }  

    if (GrantManagementSettings__c.getValues('PostLeadStaffertoChatter').Boolean_Value__c == TRUE) {
        PostUpdatestoChatter(chatterUpdateMap);   
    }

}

private static void processUpdates(Set<Id> updateIds, String sObjectName) {

String s = 'Select Id, (Select Id, Contact__r.Name from Staff_Participations__r WHERE Lead_Staffer__c = TRUE) from ' + sObjectName + ' WHERE Id in :updateIds';
List<sObject> updateObjectList = database.query(s);

    for(sObject a : updateObjectList){
        String sContact = '';
        for(Staff_Participation__c sp : a.getSObjects('Staff_Participations__r')){
            sContact += sp.Contact__r.Name + '\n';    
        }
    a.put('Lead_Staff__c', sContact);
    }

update updateObjectList;

}

private static void PostUpdatestoChatter(Map<Id, Set<Id> > ChatterUpdateMap) {
Set<Id> cons = new Set<Id> ();
cons.addall(ChatterUpdateMap.keyset());
Map<Id, Id> usermap = GrantManagementUtilities.getUserMapfromContactRecord(cons);

    for (Id cm: ChatterUpdateMap.KeySet() ) {
    Id UserId = usermap.get(cm);
        if (UserId != NULL) {
            for (Id recordId :  ChatterUpdateMap.get(cm) ) {
                String sPost = '{' + UserId + '}, You were added as a Lead Staff member to this record';
                ConnectAPIHelper.postFeedItemWithMentions(null, recordId, sPost);
            }
        }
    }

}



} //end class