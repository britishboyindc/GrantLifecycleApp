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

public with sharing class ChatterUtilityClass {

public List<AttachmentWrapper> feeda {get;set;}

public ChatterUtilityClass() {
        feeda = new List<AttachmentWrapper> ();
}

    public void getAttachments(Id SourceRecordId) {
      ConnectApi.FeedItemPage fip = ConnectApi.ChatterFeeds.getFeedItemsFromFeed(null, ConnectApi.FeedType.Record, SourceRecordId) ;

        for (ConnectApi.FeedItem fit : fip.items) {
            if (fit.Type == ConnectApi.FeedItemType.ContentPost) {
                feeda.add( new AttachmentWrapper( (ConnectApi.ContentAttachment)fit.attachment));
            }
        }
    }

public void setupAttachmentstoShare (Id TargetRecordId) {

for (AttachmentWrapper aw: feeda) {

    if (aw.bInclude) {
        ConnectApi.ContentAttachmentInput cai = new ConnectApi.ContentAttachmentInput();
        cai.contentDocumentId = aw.sourceca.Id;
        
        ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
        input.attachment = cai;
        input.visibility = ConnectApi.FeedItemVisibilityType.InternalUsers; 
            
        ConnectApi.ChatterFeeds.postFeedItem(null, 
                                            ConnectApi.FeedType.Record,
                                            TargetRecordId, 
                                            input,
                                            null);
        }
    }

}



    public class AttachmentWrapper {
        public Boolean bInclude {get;set;}
        public ConnectApi.ContentAttachment sourceca {get;set;}
    
        public AttachmentWrapper(ConnectApi.ContentAttachment ca) {
            sourceca = ca;
            bInclude = FALSE;
    }
    
    }
    

}