global with sharing class batchHSFAQSync_v2 implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable {
    
    public HelpshiftAdminAppSyncSetting__c hsAdminSetting   {get; set;}
    public HelpshiftAppFieldMapping__c     fldSettingFAQ    {get; set;}
    
    public Boolean isMultiLanguageEnabled   {get; set;}
    public Boolean haveDMLPermission        {get; set;}    
    public String forNonEnglish             {get; set;}  
    public String language                  {get; set;}
    
    public String queryKA   {get; set;}
    public String authKey   {get; set;}
    public String Que       {get; set;}
    public String Ans       {get; set;}
    public String kaObj     {get; set;}
    
    global void execute(SchedulableContext sc){
        batchHSFAQSync_v2 clsObj = new batchHSFAQSync_v2();
        if(clsObj.haveDMLPermission) {
            Database.executeBatch(clsObj); 
        } else { System.debug(LoggingLevel.Error, 'Error: Can not run batch job. No DML permission on Object HS_Sync__c Object.'); }
    }
    
    global batchHSFAQSync_v2() {
        isMultiLanguageEnabled = FALSE;
        Schema.DescribeSObjectResult HSSyncDesRslt = HS_Sync__c.sObjectType.getDescribe();
        haveDMLPermission = HSSyncDesRslt.isUpdateable();
        hsAdminSetting = HelpshiftAdminAppSyncSetting__c.getValues('HSSyncAdminSetting');
        fldSettingFAQ = HelpshiftAppFieldMapping__c.getValues('HS FAQ Field Mapping');
        authKey   = EncodingUtil.base64Encode(Blob.valueOf(hsAdminSetting.HSAccessKey__c + ':'));

        kaObj = HS_credentials.sfObject;
        System.debug(kaObj );
        if(String.isNotBlank(kaObj)) {
            kaObj = kaObj.toLowerCase();
            Que = HS_credentials.sfQue.toLowerCase();
            Ans = HS_credentials.sfAns.toLowerCase(); 
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            if(schemaMap.containsKey(kaObj)) {
                Map<String, Schema.SObjectField> schemaFieldMap = schemaMap.get(kaObj).getDescribe().fields.getMap();
                isMultiLanguageEnabled   = schemaFieldMap.containsKey('MasterLanguage');
            }
        }
        if(String.isBlank(language)) {
            language  = 'en_US';
            forNonEnglish = '';
        }
        System.debug('*******'+language);
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        if(String.isBlank(kaObj) || String.isBlank(authKey))
            return Database.getQueryLocator('SELECT Id FROM Case WHERE ID=Null Limit 1');
        DateTime dt;
        if(String.isBlank(queryKA)) {
            if(fldSettingFAQ != Null) {
                dt = hsAdminSetting.LastBatchExecutionDateTime__c;
                if(dt==Null) 
                    dt = System.now();
                System.debug('*******'+dt);
                String queryField = Que;
                if(Que != Ans)
                    queryField = Que + ',' + Ans;
                queryKA = 'SELECT KnowledgeArticleId, Language, ' + queryField + ' FROM '+kaObj+
                            + ' WHERE PublishStatus = \'Online\' AND Language = \''+ language +'\' AND LastPublishedDate > ' + dt.formatGMT('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'') + ' Limit 10000';
            }
        }
        System.debug('DT : ' + dt);
        System.debug('*******'+queryKA);
        //System.debug('Result'+Database.query(queryKA));
        return Database.getQueryLocator(queryKA);
    }
    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        if(haveDMLPermission) {
            System.debug('execute');
            List<HS_Sync__c> kaUpdateList = new List<HS_Sync__c>();
            Set<ID> masterVersionIdSet = new Set<ID>();
            Map<ID, HS_Sync__c> mapMastVersionIDToHsSync = new Map<ID, HS_Sync__c>();
            
            for (SObject kaObj : scope) {
                masterVersionIdSet.add( (Id)kaobj.get('knowledgeArticleId') );
            }
            kaUpdateList = [SELECT SFKnowledgeArticleId__c, HS_Section_Id__c, Language__c, HSAppId__c, HS_FAQ_Id__c, SFDC_KA_Id__c FROM HS_Sync__c 
                            WHERE SFKnowledgeArticleId__c IN : masterVersionIdSet AND Language__c =:language];
                            
            System.debug(kaUpdateList);
            for(HS_Sync__c hsSyncObj : kaUpdateList){
                mapMastVersionIDToHsSync.put(hsSyncObj.SFKnowledgeArticleId__c, hsSyncObj);
            }
            kaUpdateList.clear();
            
            for (SObject kaObj : scope) {
                if(! mapMastVersionIDToHsSync.containsKey((Id)kaobj.get('knowledgeArticleId')))
                    continue;
                
                System.debug('Batch record : ' + kaobj);
    
                String lang = mapMastVersionIDToHsSync.get((Id)kaobj.get('knowledgeArticleId')).Language__c;
                lang = lang.split('_')[0];
                String question = ((String) kaObj.get(Que)).replace('\"', '\\"');
                String answer = ((String) kaObj.get(Ans)).replace('\"', '\\"');
                System.debug('Answer after replacing quotes : ' + answer);
                String bodyPostfix = '&app-id=' + EncodingUtil.urlEncode(mapMastVersionIDToHsSync.get((Id)kaobj.get('knowledgeArticleId')).HSAppId__c, 'UTF-8')
                                        + '&section-id=' + EncodingUtil.urlEncode(mapMastVersionIDToHsSync.get((Id)kaobj.get('knowledgeArticleId')).HS_Section_Id__c, 'UTF-8')
                                        + '&published=true';
                String body = '"' + lang + '": {"title":"' + question + '","body":"' + answer + '"}';
                HttpResponse resp = MakeCallOutOnHSServerAndSaveKA(body, bodyPostfix, mapMastVersionIDToHsSync.get((Id)kaobj.get('knowledgeArticleId')).HS_FAQ_Id__c);
                System.debug(resp+'-----------');
                HS_Sync__c kaUpdateObj = mapMastVersionIDToHsSync.get((Id)kaobj.get('knowledgeArticleId'));
                 //new HS_Sync__c(SFDC_KA_Id__c=language + '= ' + kaObj.Id, IsSyncSuccessful__c=True);
                if(resp.getStatusCode() == 200) {
                    FAQResponse rsltFAQ = (FAQResponse) JSON.deserialize(resp.getBody(), FAQResponse.Class);
                    kaUpdateObj.HS_FAQ_Id__c = rsltFAQ.id;
                    kaUpdateObj.HSSyncError__c = '';
                    kaUpdateObj.IsSyncSuccessful__c = true;
                }
                else {
                    kaUpdateObj.IsSyncSuccessful__c = False;
                    kaUpdateObj.HSSyncError__c = resp.getStatusCode() + '-' + resp.getStatus() + '-' + resp.getBody();
                }
                kaUpdateList.add(kaUpdateObj); 
            }
            if(! kaUpdateList.isEmpty()) {
                Upsert kaUpdateList;
            }
        } else { System.debug(LoggingLevel.Error, 'Error: Can not run batch job. No DML permission on Object HS_Sync__c Object.'); }
    }   
    global void finish(Database.BatchableContext BC) {
        if(!isMultiLanguageEnabled) {
            language  = 'NoMoreLanguage';
        }
        if(language  == 'en_US' && isMultiLanguageEnabled) {
            language  = 'pt_BR';
        }
        else if(language  == 'pt_BR' && isMultiLanguageEnabled) {
            language  = 'de';
        }
        else if(language  == 'de' && isMultiLanguageEnabled) {
            language  = 'NoMoreLanguage';
        }
        if(language  != 'NoMoreLanguage') {
            batchHSFAQSync_V2 clsObj = new batchHSFAQSync_V2();
            clsObj.language = language;
            clsObj.forNonEnglish = '"en":{"title":"", "body":""},';
            //Database.executeBatch(clsObj);
            System.debug('language  --------->'+language  );
        }
        if((language  == 'NoMoreLanguage' || !isMultiLanguageEnabled) && haveDMLPermission) {
            hsAdminSetting.LastBatchExecutionDateTime__c = System.now();
            Update hsAdminSetting;  
        }
    }

    
    public httpResponse MakeCallOutOnHSServerAndSaveKA(String hsKaBody, String hsBodyPostfix, String faqID) {
        String tempStr = '/faqs/' + faqID;
        String body = '{' + hsKaBody +'}';
        body = 'translations=' + EncodingUtil.urlEncode(body, 'UTF-8') + hsBodyPostfix;

        HttpResponse resp = HS_credentials.makeApiCall('POST', tempStr, body);
        return resp;
    }
    

   
}