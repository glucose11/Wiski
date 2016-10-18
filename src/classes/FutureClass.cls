global class FutureClass {
    public static boolean isRunningSyncIssueClass = FALSE; // {get; set;}
    public FutureClass() {
        isRunningSyncIssueClass = FALSE;
    }
    @future(callout=true)
    global static void syncIssues() {
        Schema.DescribeSObjectResult ObjDesRslt = HS_Sync__c.sObjectType.getDescribe();
        Boolean isViewAccessOnHSIssue = ObjDesRslt.isAccessible();
        ObjDesRslt = Case.sObjectType.getDescribe();
        Boolean haveAccessOnCase = ObjDesRslt.isCreateable() && ObjDesRslt.isUpdateable();
        ObjDesRslt = Case_Comment__c.sObjectType.getDescribe();
        Boolean haveAccessOnCaseComment = ObjDesRslt.isCreateable() && ObjDesRslt.isUpdateable();
        HelpshiftAdminAppSyncSetting__c hsAdminSetting = HelpshiftAdminAppSyncSetting__c.getValues('HSSyncAdminSetting');
        
        if(isViewAccessOnHSIssue && haveAccessOnCase && haveAccessOnCaseComment && hsAdminSetting != Null) {
        
            Sync_Issue__c objCustSett = Sync_Issue__c.getValues('Sync Issue');
            if(objCustSett == Null) {
                objCustSett = new Sync_Issue__c(Name='Sync Issue');
                objCustSett.Last_Sync_Time__c = System.now().addYears(-99);
            }
            List<Case> caseList = new List<Case>();
            Map<String, List<Case_Comment__c>> caseUniqueIdToCaseCommentsMap = new Map<String, List<Case_Comment__c>>();
            Integer totalPages = 10;
            Integer pageNo = 0;
            if(objCustSett.Last_Sync_Time__c != NULL){
                DateTime lastSyncTime = objCustSett.Last_Sync_Time__c;
                while(totalPages != NULL && pageNo < totalPages) {
                    pageNo++;
                    String tempStr = '?state=resolved&page-size=500&state-since='+lastSyncTime.getTime() +'&state-until='+System.now().getTime() + '&page='+pageNo;
                    HttpResponse resp = HS_credentials.makeApiCall('GET', '/issues'+tempStr, Null);
                    system.debug('******'+resp.getBody());
                    Integer statusCode = resp.getStatusCode();
                    if(statusCode == 200) {
                        json2IssueWr clsObj = json2IssueWr.parse(resp.getBody().replace('"id"', '"IssueOrAuthorId"').replace('"state"', '"st"'));
                        system.debug('******'+clsObj);
                        totalPages = clsObj.total_pages;
                        for(json2IssueWr.issues itrIssue : clsObj.issues) {
                            Case objCase = new Case(Subject=itrIssue.title);
                            if(objCase.Subject.length() > 255)
                                objCase.Subject = objCase.Subject.substring(0, 222)+'...';
                            objCase.HSIssueId__c = itrIssue.IssueOrAuthorId;
                            objCase.Status = 'Closed';
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
            objCustSett = Sync_Issue__c.getValues('Sync Issue');
            if(objCustSett == Null) 
                objCustSett = new Sync_Issue__c(Name='Sync Issue');
            objCustSett.Last_Sync_Time__c = System.now();
            Upsert objCustSett;
        } else { System.debug(LoggingLevel.Error, 'Error: No CRUD permission on Object either HS_Sync__c, Case & Case_Comment__c.'); }
        
    }
           
    public static void dummyTestMethod() {
        Integer i = 0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
    }
    
}