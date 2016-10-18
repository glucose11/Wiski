global class batchHSIssueSync_v2 implements Database.batchable<HelpshiftAdminAppSyncSetting__c>,Database.Stateful, Database.AllowsCallouts{ 
    public static boolean isRunningSyncIssueClass = FALSE;
    public Integer totalPages;
    public Integer pageNo;
    public Boolean isOmniChannelEnabled;
    public Integer i;
    global batchHSIssueSync_v2() {
        isRunningSyncIssueClass = FALSE;
        isOmniChannelEnabled = False;
        if(totalPages == Null)
            totalPages = 1;
        if(pageNo == Null)
            pageNo = 0;
    }
    
    public void setPageNos(Integer totalPagesNo, Integer currentPageNo) {
        totalPages = totalPagesNo;
        pageNo = currentPageNo;
    }


   global Iterable<HelpshiftAdminAppSyncSetting__c> start(Database.batchableContext info){ 
       System.debug(new HSAdminSettingClass());
       return new HSAdminSettingClass(); 
   }     
   global void execute(Database.batchableContext info, List<HelpshiftAdminAppSyncSetting__c> scope){ 
       System.debug('execute-----------');
       System.debug(scope);
       System.debug(pageNo );
       System.debug(totalPages);
       syncIssues();
       System.debug(LoggingLevel.Error, pageNo );
       System.debug(totalPages);
   }     
   global void finish(Database.batchableContext info){     
       System.debug(LoggingLevel.Error, pageNo );
       System.debug(totalPages);
       if(pageNo < totalPages) {
           batchHSIssueSync_v2 clsObj = new batchHSIssueSync_v2();
           clsObj.setPageNos(totalPages, pageNo);
           Database.executeBatch(clsObj);
       }
       else {
            Sync_Issue__c objCustSett = Sync_Issue__c.getValues('Sync Issue');
            if(objCustSett == Null) 
                objCustSett = new Sync_Issue__c(Name='Sync Issue');
            objCustSett.Last_Sync_Time__c = System.now();
            Upsert objCustSett;
       }
   } 
   
    global void syncIssues() {
        String OmniChannelSettingName = 'Omni-ChannelEnabled';
        Boolean isOmniChannelEnabled = False;
        for(HelpshiftSetting__c temp : [SELECT IsOmniChannelEnabled__c FROM HelpshiftSetting__c WHERE IsOmniChannelEnabled__c = TRUE AND SettingName__c= :OmniChannelSettingName Limit 1]) {
            isOmniChannelEnabled = True;
        }
        Schema.DescribeSObjectResult ObjDesRslt = HS_Sync__c.sObjectType.getDescribe();
        Boolean isViewAccessOnHSIssue = ObjDesRslt.isAccessible();
        ObjDesRslt = Case.sObjectType.getDescribe();
        Boolean haveAccessOnCase = ObjDesRslt.isCreateable() && ObjDesRslt.isUpdateable();
        ObjDesRslt = Case_Comment__c.sObjectType.getDescribe();
        Boolean haveAccessOnCaseComment = ObjDesRslt.isCreateable() && ObjDesRslt.isUpdateable();
        if(isViewAccessOnHSIssue && haveAccessOnCase && haveAccessOnCaseComment) {
        
            Sync_Issue__c objCustSett = Sync_Issue__c.getValues('Sync Issue');
            if(objCustSett == Null) {
                objCustSett = new Sync_Issue__c(Name='Sync Issue');
                objCustSett.Last_Sync_Time__c = System.now().addYears(-99);
            }
            List<Case> caseList = new List<Case>();
            Map<String, List<Case_Comment__c>> caseUniqueIdToCaseCommentsMap = new Map<String, List<Case_Comment__c>>();
            if(objCustSett.Last_Sync_Time__c != NULL){
                DateTime lastSyncTime = objCustSett.Last_Sync_Time__c;
                if(lastSyncTime == null)
                    lastSyncTime  = DateTime.newInstance(1900, 1, 1);
                if(pageNo < totalPages) {
                    pageNo++;
                    String tempStr = '?state=resolved&page-size=200&state-since='+lastSyncTime.getTime() +'&state-until='+System.now().getTime() + '&page='+pageNo;
                    HttpResponse resp = HS_credentials.makeApiCall('GET', '/issues'+tempStr, Null);
                    system.debug('******'+resp.getBody());
                    Integer statusCode = resp.getStatusCode();
                    if(statusCode == 200) {
                        json2IssueWr clsObj = json2IssueWr.parse(resp.getBody().replace('"id"', '"IssueOrAuthorId"').replace('"state"', '"st"').replace('"total-pages"', '"total_pages"'));
                        system.debug('******'+clsObj);
                        totalPages = clsObj.total_pages;
                        for(json2IssueWr.issues itrIssue : clsObj.issues) {
                            Case objCase = new Case(Subject=itrIssue.title);
                            if(objCase.Subject.length() > 255)
                                objCase.Subject = objCase.Subject.substring(0, 222)+'...';
                            objCase.HSIssueId__c = itrIssue.IssueOrAuthorId;
                            objCase.Status = 'Closed';
                            if(isOmniChannelEnabled)
                                objCase.Origin = 'Helpshift';
                            objCase.Author_Email__c = itrIssue.author_email;
                            List<Case_Comment__c> caseComments = new List<Case_Comment__c>();
                            if(!itrIssue.messages.isEmpty()){
                                objCase.Description = itrIssue.messages[0].body;
                                if(String.isNotBlank(objCase.Description) && objCase.Description.length() > 32000)
                                    objCase.Description = objCase.Description.substring(0, 31997)+'...';
                                if(itrIssue.messages.size() > 1){
                                    for(Integer i = 1; i < itrIssue.messages.size(); i++){
                                        Case_Comment__c comment = new Case_Comment__c();
                                        comment.Comment__c = itrIssue.messages[i].body;
                                        if(String.isNotBlank(comment.Comment__c) && comment.Comment__c.length() > 32768)
                                            comment.Comment__c = comment.Comment__c.substring(0, 32765)+'...';
                                        if(itrIssue.messages[i].Author != null)
                                            comment.Author__c = itrIssue.messages[i].Author.name;
                                        comment.External_ID__c = itrIssue.IssueOrAuthorId + itrIssue.messages[i].created_at;
                                        caseComments.add(comment);
                                    }
                                }
                            }
                            caseList.add(objCase);
                            caseUniqueIdToCaseCommentsMap.put(objCase.HSIssueId__c,caseComments);
                        } 
                    }
                }
                
                if(!caseList.isEmpty()) {
                    isRunningSyncIssueClass = TRUE;
                    Upsert caseList HSIssueId__c;
                    
                }
                
                List<Case_Comment__c> caseCommentList = new List<Case_Comment__c>();
                for(Case objCase : caseList){
                    if(caseUniqueIdToCaseCommentsMap.containsKey(objCase.HSIssueId__c) && !caseUniqueIdToCaseCommentsMap.get(objCase.HSIssueId__c).isEmpty()){
                        for(Case_Comment__c comment : caseUniqueIdToCaseCommentsMap.get(objCase.HSIssueId__c)){
                            comment.Case__c = objCase.Id;
                            caseCommentList.add(comment);
                        }
                    }
                }
                
                if(!caseCommentList.isEmpty()) {
                    upsert caseCommentList External_ID__c;
                }
            } 
            /*
            objCustSett = Sync_Issue__c.getValues('Sync Issue');
            if(objCustSett == Null) 
                objCustSett = new Sync_Issue__c(Name='Sync Issue');
            //objCustSett.Last_Sync_Time__c = System.now();
            //Upsert objCustSett;
            */
        } else { System.debug(LoggingLevel.Error, 'Error: No CRUD permission on Object either HS_Sync__c, Case & Case_Comment__c.'); }
        
    }
}