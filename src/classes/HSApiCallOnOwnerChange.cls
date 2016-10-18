public with sharing class HSApiCallOnOwnerChange {
    public static Boolean HSAPiCallCaseOwnerIds(ID caseId) {
        List<Case> caseList = [SELECT HSIssueId__c, OwnerId FROM Case WHERE ID = :caseId AND HSIssueId__c != '' AND OwnerId != '' Limit 1];
        if(! caseList.isEmpty()) {
            Case objCase =  caseList[0];
            User us = [SELECT HSUserId__c FROM User WHERE ID = :objCase.OwnerId Limit 1]; //{"assignee-id":"'+us.HSUserId__c+'"}
            HttpResponse resp = HS_credentials.makeApiCall('PUT', '/issues/'+objCase.HSIssueId__c , 'assignee-id='+us.HSUserId__c);  
            System.debug(resp.getStatusCode()+ '-----------' +resp.getBody());
            if(resp.getStatusCode() == 200)
                return true;
            else if(resp.getStatusCode() == 400) {
                Data DataResp = (data) JSON.deserialize(resp.getBody().replace('issue-id', 'issue_id'), data.class);
                Case_Comment__c comment = new Case_Comment__c();
                comment.Comment__c = 'Agent assignment failed: Corresponding Helpshift issue is already resolved.';
                comment.External_ID__c = DataResp.issue_id + System.now();
                comment.Case__c = objCase.Id;
                Upsert comment External_ID__c;
                return true;
            }
            else
                return false;
        }
        return false;
    }
    
    public static Boolean HSAPiCallCaseOwnerIdsSet(Set<ID> caseIds) {
        Map<Id, User> mapUser = new Map<Id, User>([SELECT HSUserId__c FROM User]);
        for(Case objCase : [SELECT HSIssueId__c, OwnerId FROM Case WHERE ID IN :caseIds AND HSIssueId__c != '' AND OwnerId != '' Limit 1]) {
            //User us = [SELECT HSUserId__c FROM User WHERE ID = :objCase.OwnerId Limit 1]; //{"assignee-id":"'+us.HSUserId__c+'"}
            HttpResponse resp = HS_credentials.makeApiCall('PUT', '/issues/'+objCase.HSIssueId__c , 'assignee-id='+mapUser.get(objCase.OwnerId).HSUserId__c);  
            System.debug(resp.getStatusCode()+ '-----------' +resp.getBody());
            if(resp.getStatusCode() == 200)
                return true;
            else
                return false;
        }
        return false;
    }
    
    class data {
        public string issue_id {get; set;} 
    }
}