//-- To Do - batch should be always executed with batch size 1
global with sharing class batchCaseOwnerChangeTracker implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful, Schedulable{
    
    public Sync_Issue__c syncIssueSettings   {get; set;}   
    public DateTime syncDateTime;  
    public DateTime lastSyncDateTime;
    public Boolean batchWasSuccess;
    
    @testVisible
    private DateTime currentTime;
    
    global batchCaseOwnerChangeTracker() {
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        syncIssueSettings = Sync_Issue__c.getValues('Sync Issue');
        if(syncIssueSettings == null || syncIssueSettings.IssueOwnerLastSync__c == null)
            lastSyncDateTime = System.now();
        else  
            lastSyncDateTime = syncIssueSettings.IssueOwnerLastSync__c.addMinutes(-1); //-- buffer of 1 min, it will fetch cases assigned since last 2 mins
        String ownerField = 'Owner';
        batchWasSuccess = false;
        /**
         * Doing so, so that the same
         * can be manipulated from a Unit
         * Test to set the time to somewhere
         * in the future in order to get
         * coverage.
         */        
        currentTime = currentTime == NULL ? System.now() : currentTime;
        String queryString = 'SELECT CaseId, Field, NewValue, OldValue, CreatedDate FROM CaseHistory'
                            + ' WHERE Field = :ownerField' 
                            + ' AND CreatedDate <= :currentTime AND CreatedDate >= : lastSyncDateTime ';
           
        System.debug('IssueOwnerLastSync : ' + syncIssueSettings.IssueOwnerLastSync__c);
        System.debug('***queryString****'+queryString);
        syncDateTime = System.now();
        return Database.getQueryLocator(queryString );
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> caseHistoryList) {
        set<Id> caseIds = new set<Id>();
        for(sObject sObjRec : caseHistoryList){
            CaseHistory caseHistoryRec = (CaseHistory)sObjRec;
            //-- Check if New Owner is a user
            String newValStr = String.valueOf(caseHistoryRec.NewValue);
            if(newValStr != NULL && newValStr.startsWith('005')){
                //-- Make Callout - push new owner to HS
                caseIds.add(caseHistoryRec.CaseId);
            }
        }
        if(! caseIds.isEmpty()) {
            batchWasSuccess = HSApiCallOnOwnerChange.HSAPiCallCaseOwnerIdsSet(caseIds);
        }
        //batchWasSuccess = true;
    }   
    global void finish(Database.BatchableContext BC) {
        
        if(batchWasSuccess){
            //-- Abort scheduled job
            //-- reschedule after 1 min
            
            syncIssueSettings.IssueOwnerLastSync__c = syncDateTime;
            update syncIssueSettings;    
        }
        else{
            //-- Abort scheduled job
            //-- reschedule after 1 min
            //-- push error in error object
            
        }
        System.debug('Batch finish method -->'+batchWasSuccess);
        /*### Sachin Code Start ###*/
        /*lIST<CronJobDetail> CRJOB =  [SELECT Id, JobType, Name FROM CronJobDetail WHERE NAME = 'batchCaseOwnerChangeTracker'];
        IF(!CRJOB.isEmpty()) {
            List<CronTrigger> listCronTrigger = [select Id, OwnerId, CronExpression from CronTrigger where CronJobDetailId = :CRJOB[0].Id];                  
            if(listCronTrigger.size() > 0){  
                for(Integer i = 0; i < listCronTrigger.size(); i++){
                    //-- Abort the pending jobs
                    System.abortJob(listCronTrigger.get(i).id);
                }
            }
        }
        if(syncIssueSettings.StopBatchForOwnerChangeTracker__c == null || syncIssueSettings.StopBatchForOwnerChangeTracker__c == false) {
            Datetime dt = DateTime.now().addMinutes(1);  
            String sch = String.valueOf( dt.second() ) + ' ' + String.valueOf( dt.minute()   ) + ' ' + String.valueOf( dt.hour() ) + ' '  + String.valueOf( dt.day() ) +  ' ' + String.valueOf( dt.month() ) + ' '  + '? ' + String.valueOf( dt.Year());
            system.schedule('batchCaseOwnerChangeTracker', sch, new batchCaseOwnerChangeTracker());
        }
        /*### Sachin Code End ###*/
        
        /*### Niranja Code Start ###*/
        //-- Get cron trigger id of the pending jobs
        List<CronTrigger> listCronTrigger = [select Id, OwnerId, CronExpression from CronTrigger where CronExpression like '% batchCaseOwnerChangeTracker%'];                  
        if(listCronTrigger.size() > 0){  
            for(Integer i = 0; i < listCronTrigger.size(); i++){
                //-- Abort the pending jobs
                System.abortJob(listCronTrigger.get(i).id);
            }
        }
                
        //-- reschedule the job for new time           
        if(syncIssueSettings.StopBatchForOwnerChangeTracker__c == null || syncIssueSettings.StopBatchForOwnerChangeTracker__c == false) {
            Datetime dt = DateTime.now().addMinutes(1);  
            String sch = String.valueOf( dt.second() ) + ' ' + String.valueOf( dt.minute()   ) + ' ' + String.valueOf( dt.hour() ) + ' '  + String.valueOf( dt.day() ) +  ' ' + String.valueOf( dt.month() ) + ' '  + '? ' + String.valueOf( dt.Year()) + ' batchCaseOwnerChangeTracker';
            system.schedule('batchCaseOwnerChangeTracker', sch, new batchCaseOwnerChangeTracker());
        }         
        /*### Niranja Code End ###*/
        
    }   
    
    
    
    
    global void execute(SchedulableContext ctx) {
        database.executebatch(new batchCaseOwnerChangeTracker(), 1);            
    } 
          
}