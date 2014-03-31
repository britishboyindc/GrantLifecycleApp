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

public with sharing class SetupNewGrantControllerExtension {

private final Grant_Management__c gm {get;set;}

public List<GrantReportWrapper> grw {get;set;}
public Grant_Reporting_Requirement__c newgrr {get;set;}
private Map<Id, Grant_Reporting_Requirement__c> grrmap;  
public Grant_Report_Detail__c newgrd {get;set;} 
public String sHeaderText {get;set;}

public Boolean bshownewgr {get;set;}
public Boolean bshownewgrd {get;set;}
public Boolean bshownewgrdetails {get;set;}


public Boolean bsaveandnew {get;set;}

public Id ReportId {get;set;}
public String ReportName {get;set;}

private  Map<Id, List<Grant_Report_Detail__c> > ReportDetails;
private List<Grant_Report_Detail__c> currentreportdetails;
private Contact cuser;

// The extension constructor initializes the private member 
//variable by using the getRecord method from the standard controller.
    public SetupNewGrantControllerExtension (ApexPages.StandardController stdController) {
        this.gm = (Grant_Management__c)stdController.getRecord();
        setupReports();
        bshownewgrd = FALSE;
        bshownewgr = TRUE;
        bshownewgrdetails = FALSE;
        sHeaderText = 'Setup Reports (Step 3 of 4)';
        }

/* Page 3 Report Setup Code */

  public PageReference setupReports() {
    grw = new List<GrantReportWrapper> ();
    ReportDetails = new Map<Id, List<Grant_Report_Detail__c> > ();
    
    Integer numberDaysDue = gm.Grant_Start_Date__c.daysBetween(gm.Grant_End_Date__c);
    grw.add(new GrantReportWrapper(gm.Id, 'Interim', gm.Grant_Start_Date__c.adddays(numberDaysDue /2)) );
    grw.add(new GrantReportWrapper(gm.Id, 'Final', gm.Grant_End_Date__c) );
    
    return null;  
  }  
  
  public PageReference insertGrantReports() {
    List<Grant_Reporting_Requirement__c> grrlist = new List<Grant_Reporting_Requirement__c> ();
    List<Grant_Report_Detail__c> grdlist = new List<Grant_Report_Detail__c> ();
  
    for (GrantReportWrapper gw: grw) {
            if (gw.bCreate) {
            grrlist.add(gw.grr);
            }
        }
        
    insert grrlist;
    grrmap = new Map<Id, Grant_Reporting_Requirement__c> (grrlist);
    
    for (GrantReportWrapper gw: grw) {
    
    if (gw.bCreate) {

        if (gw.bBudgetReport) {
            grdlist.add(new Grant_Report_Detail__c(Grant_Reporting__c = gw.grr.Id, Short_Description__c = 'Budget Report', Date_Due_to_Reviewer__c = gw.grr.Due_Date__c.adddays(-15)));
        }
    
        if (gw.bNarrative) {
            grdlist.add(new Grant_Report_Detail__c(Grant_Reporting__c = gw.grr.Id, Short_Description__c = 'Narrative Report', Date_Due_to_Reviewer__c = gw.grr.Due_Date__c.adddays(-15)));
        }

    }
    }
    
    
    insert grdlist;
    
    //Now put them all in a map for easy viewing
    for (Grant_Report_Detail__c grnew: grdlist) {
    
       if (ReportDetails.containskey(grnew.Grant_Reporting__c) ) {
           currentreportdetails = ReportDetails.get(grnew.Grant_Reporting__c);
           }
       else {
           currentreportdetails = new List<Grant_Report_Detail__c> ();
           
       }
       currentreportdetails.add(grnew);
       ReportDetails.put(grnew.Grant_Reporting__c, currentreportdetails);
       }
    
    bshownewgr = FALSE;
    bshownewgrd = TRUE;
    sHeaderText = 'Setup Reports (Step 4 of 4)';
    return gotoGrant();
    }
    
     
  
  public PageReference addNewGrantReport() {
    grw.add(new GrantReportWrapper(gm.Id, 'Interim', system.today()) );
    bshownewgr = TRUE;
    return null;
  }
   
   
  /*
  public pageReference setupReportDetails() {
       system.debug(ReportId);
        if (ReportId != null) {
        ReportName = 'Reports for ' +  grrmap.get(ReportId).Due_Date__c.format();
            if (ReportDetails.containskey(ReportId) ) {
                currentreportdetails = ReportDetails.get(ReportId);
            }
            if (currentreportdetails.size() > 0) {
                return null;
                bshownewgrd = FALSE;
            }
            else {
                return newReportDetail();
            }
            }
       
       bshownewgrdetails = TRUE;
       return null;
    }
*/

    /*
    public pageReference updateReportDetails() {
    upsert currentreportdetails;
    return null;
    }

    public pageReference newReportDetail() {
    currentreportdetails.add(new Grant_Report_Detail__c(Grant_Reporting__c = ReportId, Date_Due_to_Reviewer__c = grrmap.get(ReportId).Due_Date__c.adddays(-15)));
    return null;
    }

    public pageReference insertnewReportDetails() {
    insert newgrd;
    currentreportdetails.add(newgrd);
    ReportDetails.put(ReportId, currentreportdetails);
    getGrantReportDetails();
    
    return null;
    }
    
    public List<Grant_Report_Detail__c> getGrantReportDetails() {
    //setupReportDetails();
    return currentreportdetails;
    }
    */
        
    public pageReference gotoGrant() {
    return new ApexPages.StandardController(gm).view();
    }
    
    

public class GrantReportWrapper {

public Grant_Reporting_Requirement__c grr {get;set;}
public Boolean bCreate {get;set;}
public Boolean bBudgetReport {get;set;}
public Boolean bNarrative {get;set;}

public GrantReportWrapper (Id gmId, String sType, Date DueDate) {
grr = new Grant_Reporting_Requirement__c(Due_Date__c = DueDate, Grant_Management__c = gmId, Report_Type__c = sType);
grr.Status__c = 'Not Started';
bBudgetReport = TRUE;
bNarrative = TRUE;
bCreate = TRUE;
} 

}


}