public with sharing class HSFaq {
    public boolean isValidationFieldEnabled {get; set;}
    public boolean isMultiLanguageEnabled {get; set;}
    public boolean isFAQMappingCorrect {get; set;}
    public boolean isHSAccountCreated {get; set;}
    public boolean isSyncOneTransOnly {get; set;}
    Public Integer TotalRecords {get; set;}
    Public Integer PageSize     {get; set;}
    public String newkaObj {get; set;} 
    public String newQue {get; set;}
    public String newAns {get; set;}
    private String kaObj;
    public String Que {get; set;}
    public String Ans {get; set;}
    public String synchedIdsJson {get; set;} 

    public Map<String, String> mapKALanguage {get; set;}
    public String MasterIdToTransString {get; set;}
    
    HelpshiftAdminAppSyncSetting__c hsAdminSetting;
    HelpshiftAppFieldMapping__c fldSettingFAQ;
    String authKey;
    String forNonEnglish;
     
    public String selectedHSAppId           {get; set;}
    public String selectedHSSectionId       {get; set;}
    public String selectedPublishStatus     {get; set;}
    public String selectedValidationStatus  {get; set;}
    public String selectedLanguage          {get; set;}
    public String selectedSortOrder         {get; set;}
    public String selectedKAIds             {get; set;}  
    
    public Boolean haveDMLAccess            {get; set;}  
   
    public HSFaq() {
        InitFAQ();
    }
    
    public void InitFAQ() {
        haveDMLAccess = False;
        isFAQMappingCorrect = False;
        isHSAccountCreated = String.isNotBlank(HS_credentials.hsDomain);
        
        kaObj = HS_credentials.sfObject;
        if(String.isBlank(kaObj)) {
            HS_credentials.log('Info', Label.FAQMappingNotDefinedInCustomSetting);
        }
        else {
            kaObj = kaObj.toLowerCase();
            Que = HS_credentials.sfQue.toLowerCase();
            Ans = HS_credentials.sfAns.toLowerCase(); 
            newKaObj = kaObj;
            newQue = Que;
            newAns = Ans;
            Map<String, Schema.SObjectType> schemaMap = GetAllArticleTypeSchemaMap();
            Map<String, Schema.SObjectField> schemaFieldMap;
            if(! schemaMap.containsKey(kaObj)) {
                HS_credentials.log('Info', Label.FAQMappingInCustomSettingNotValid);
            }
            else {
                Schema.DescribeSObjectResult kaRslt = schemaMap.get(kaObj).getDescribe();
                haveDMLAccess = kaRslt.isAccessible();
                if(haveDMLAccess) {
                    schemaFieldMap = kaRslt.fields.getMap();
                    if(!schemaFieldMap.containsKey(Que) || !schemaFieldMap.containsKey(Ans)) {
                        HS_credentials.log('Error', Label.FAQMappingInCustomSettingNotValid);
                    }
                    else {
                        isFAQMappingCorrect = True;
                        selectedHSAppId = selectedHSSectionId = selectedValidationStatus = selectedKAIds = '';
                        selectedPublishStatus = 'Online';
                        selectedLanguage = 'en_US';
                        selectedSortOrder = 'LastPublishedDate';
                        PageSize = 10;
                        TotalRecords = 0;
                        isValidationFieldEnabled = schemaFieldMap.containsKey('validationstatus');
                        isMultiLanguageEnabled   = schemaFieldMap.containsKey('MasterLanguage');
                        mapKALanguage = new Map<String, String>();
                        if(isMultiLanguageEnabled) {
                            for(Schema.PicklistEntry f : schemaFieldMap.get('masterlanguage').getDescribe().getPickListValues()){
                                mapKALanguage.put(f.getValue(), f.getLabel());
                            }
                            mapKALanguage.remove('en_US');
                        }
                    }
                } else { HS_credentials.log('Error', 'You don\'t have access on Knowledge Article Type.'); }
            }
        }
    }
    
    public ApexPages.StandardSetController setContKA {
        get{
            if(setContKA == Null) {
                String lang   = String.escapeSingleQuotes(selectedLanguage);
                String status = String.escapeSingleQuotes(selectedPublishStatus);
                String queryFields = Que;
                if(Que != Ans)
                    queryFields = Que + ', ' + Ans;
                string queryString = 'SELECT ArticleNumber, PublishStatus, knowledgeArticleId, LastPublishedDate, ' +  queryFields 
                                            + (isValidationFieldEnabled?',ValidationStatus':'') +' FROM ' + kaObj 
                                        + ' WHERE PublishStatus = \''+status+'\' AND Language = \''+lang+'\'' ;
                if(String.isNotBlank(selectedValidationStatus)) {
                    String ValidationStatus = String.escapeSingleQuotes(selectedValidationStatus);
                    queryString = queryString + ' AND ValidationStatus = \'' + ValidationStatus + '\'';
                }
                String srchQury = '';
                if(String.isNotBlank(fkn)) {
                    srchQury = String.escapeSingleQuotes(fkn);
                    srchQury = '\'%' + srchQury + '%\'';
                    srchQury = ' AND ' + Que + ' like ' + srchQury;
                }
                queryString = queryString + srchQury + ' ORDER BY ' + selectedSortOrder + ' Limit 10000';
                setContKA = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                setContKA.setPageSize(PageSize);
                TotalRecords = setContKA.getResultSize();
            }
            return setContKA;
        }
        set;
    }    
    
    public List<Sobject> getKAList() {
        Map<Id, Integer> mapMasterIdToTrans = new Map<Id, Integer>();
        Map<Id, Sobject> mapIdToKaSobject   = new Map<Id, Sobject>();
        String masterKAIds = '';
        MasterIdToTransString = '';
        Id tempId;
        for(Sobject iteObj : setContKA.getRecords()) {
            tempId = (Id) iteObj.get('KnowledgeArticleId');
            mapIdToKaSobject.put(tempId,  iteObj);
            mapMasterIdToTrans.put(tempId, 1);
            masterKAIds = masterKAIds + ',\'' + tempId + '\'';
        }
        if(String.isNotBlank(masterKAIds)) {
            masterKAIds = masterKAIds.substring(1, masterKAIds.length());
        }
        Set<Id> synchedIds = new Set<Id>();
        for(HS_Sync__c itrSync : [SELECT SFKnowledgeArticleId__c FROM HS_Sync__c WHERE SFKnowledgeArticleId__c IN : mapIdToKaSobject.keySet() 
                                    AND Language__c = :selectedLanguage AND HSAppId__c = :selectedHSAppId AND HS_FAQ_Id__c != Null Limit 10000]) {
            synchedIds.add(itrSync.SFKnowledgeArticleId__c);
        }
        if(String.isNotBlank(masterKAIds)) {
            String status = String.escapeSingleQuotes(selectedPublishStatus);
            for(String kalanguage : mapKALanguage.keySet()) {
                for (SObject kaObj :  Database.query('SELECT knowledgeArticleId FROM ' + kaObj 
                                        + ' WHERE '+' knowledgeArticleId '+' IN (' + masterKAIds + ') AND PublishStatus = \''+status+'\' '
                                        +' AND Language = \'' + kalanguage + '\' Limit 10000')) {
                    Integer tempTrnsCount = mapMasterIdToTrans.get( (Id)kaObj.get('KnowledgeArticleId') ) +1;
                    mapMasterIdToTrans.put( (Id)kaObj.get('KnowledgeArticleId'), tempTrnsCount);
                }
            }
        }
        MasterIdToTransString = JSON.serialize(mapMasterIdToTrans);
        synchedIdsJson = JSON.serialize(synchedIds);
        return mapIdToKaSobject.values();
    }
    public PageReference doReferesh() {
        setContKA = Null;
        return null;
    }
    
    public Boolean hasNext {
        get { return setContKA.getHasNext(); }
        set;
    }
    
    public Boolean hasPrevious {
        get { return setContKA.getHasPrevious(); }
        set;
    }
    
    public Integer pageNumber {
        get { return setContKA.getPageNumber(); }
        set;
    }
    
    public void first() {
        setContKA.first();
        system.debug('******');
    }
    
    public void last() {
        setContKA.last();
    }
    
    
    public void previous() {
        setContKA.previous();
        system.debug('******');
    }
    
    public void next() {
        system.debug('******');
        setContKA.next();
    }
        
    public List<WR_App> HS_Apps {get; set;}
    public void doGetHS_Apps() {
        HS_Apps = new List<WR_App>();
        HttpResponse resp = HS_credentials.makeApiCall('GET', '/apps', Null);
        System.debug(resp.getBody());
        if(resp.getStatusCode() == 200) {
            Map<String, List<WR_App>> mapHS_Apps = (Map<String, List<WR_App>>) Json.deserialize(resp.getBody(), Map<String, List<WR_App>>.class);
            HS_Apps = mapHS_Apps.get('apps');
        }
    }
    
    public WR_Section HS_Sections {get; set;}
    public void doGetAllHSSectionForApp() {
        HS_Sections = FindAllHS_Sections();
    }
     
    
    public WR_Section FindAllHS_Sections() {
        WR_Section hsSection;
        if(String.isBlank(selectedHSSectionId)) {
            System.debug('selectedHSAppId--->'+selectedHSAppId);
            String tempStr = '/' + String.escapeSingleQuotes(selectedHSAppId) + '/sections';
            HttpResponse resp = HS_credentials.makeApiCall('GET', tempStr, Null);
            System.debug(resp.getBody());
            if(resp.getStatusCode() == 200) {
                hsSection = (WR_Section) Json.deserialize(resp.getBody(), WR_Section.class);
                Map<String, WR_App> tempMap = new  Map<String, WR_App>();
                List<String> tempSortedList = new List<String>();
                for(WR_App wrSec : hsSection.sections) {
                    if(wrSec.app_id == selectedHSAppId)
                        tempMap.put(wrSec.title+wrSec.id, wrSec);    
                }
                tempSortedList.addAll(tempMap.keySet());
                tempSortedList.sort();  
                hsSection.sections.clear();
                for(String itrSort : tempSortedList) {
                    hsSection.sections.add(tempMap.get(itrSort));
                }
            }
        }
        doReferesh();
        return hsSection;
    }
    public void SetHSSectionId() {
        System.debug(LoggingLevel.Error, selectedHSSectionId);
    }
    
    public void createHSFaq() {
        Schema.DescribeSObjectResult HSSyncDesRslt = HS_Sync__c.sObjectType.getDescribe();
        Boolean haveDMLPermission = HSSyncDesRslt.isCreateable() && HSSyncDesRslt.isUpdateable();
        if(haveDMLPermission==false)
            HS_credentials.log('Error', 'You don\'t have DML permission on HS_Sync__c object.');
        else if(String.isNotBlank(selectedKAIds)) {
            String status = String.escapeSingleQuotes(selectedPublishStatus);
            forNonEnglish = '"en":{"title":"FAQ created via API in other languages.", "body":"FAQ created via API: This FAQ is available in other languages.", "enabled": true},';
            String bodyPostfix = '&app-id=' + EncodingUtil.urlEncode(selectedHSAppId, 'UTF-8')
                                    + '&section-id=' + EncodingUtil.urlEncode(selectedHSSectionId, 'UTF-8')
                                    + '&published=true';
            String KAIdsList = String.escapeSingleQuotes(selectedKAIds);
            KAIdsList = KAIdsList.replace('"', '\'');
            System.debug(KAIdsList +'--');
            Map<Id, List<String>> mapMasterIdToKAUpdateList = new Map<Id, List<String>>();
            Map<Id, String> mapIdToKaBody = new Map<Id, String>();
            Map<Id, Id> mapVersionIdToKnowArticleId = new Map<Id, Id>();
            Map<Id, String> mapIdToKaBodyTemp = new Map<Id, String>();
            Set<String> allLanguage = new Set<string>();
            if(isSyncOneTransOnly && selectedLanguage != 'en_US') 
                allLanguage.add(selectedLanguage);
            else if(!isSyncOneTransOnly)
                allLanguage.addAll(mapKALanguage.keySet());
            for(String kalanguage : allLanguage) {
                String queryFields = Que;
                if(Que != Ans)
                    queryFields = Que + ', ' + Ans;
                for (SObject kaObj :  Database.query('SELECT knowledgeArticleId, ' + queryFields + ' FROM ' + kaObj 
                                                            + ' WHERE knowledgeArticleId IN (' + KAIDSList + ') AND PublishStatus = \''+status+'\' '
                                                            + ' AND Language = \'' + kalanguage + '\'')) {
                    Id tempMasterKAId = (Id) kaObj.get('knowledgeArticleId');
                    Id knowledgeArticleId = (Id) kaObj.get('knowledgeArticleId');
                    String body = mapIdToKaBodyTemp.get(tempMasterKAId);
                    List<String> kaUpdateList = mapMasterIdToKAUpdateList.get(tempMasterKAId);
                    if(kalanguage==NUll || kaObj.get(Que) == NUll || kaObj.get(Ans)==Null)
                        continue;
                    if(body == Null) {
                        body = '"' + kalanguage.split('_')[0] + '":{"title":"'+ ((String)kaObj.get(Que)).replace('\"', '\\"') +'", "body":"'+ ((String)kaObj.get(Ans)).replace('\"', '\\"') +'", "enabled": true}';
                        kaUpdateList = new List<String>();
                    }
                    else {
                        body = body + ',"' + kalanguage.split('_')[0] + '":{"title":"'+ ((String)kaObj.get(Que)).replace('\"', '\\"') +'", "body":"'+ ((String)kaObj.get(Ans)).replace('\"', '\\"') +'", "enabled": true}';
                    }
                    kaUpdateList.add( kalanguage+ '=' + kaObj.get(knowledgeArticleId));
                    mapIdToKaBodyTemp.put(tempMasterKAId, body);
                    mapVersionIdToKnowArticleId.put(tempMasterKAId, knowledgeArticleId);
                    mapMasterIdToKAUpdateList.put(tempMasterKAId, kaUpdateList);
                }
            }
            allLanguage.clear();
            allLanguage.add('en_US');
            for(String kalanguage : allLanguage) {
                System.debug(kalanguage);
                String queryFields = Que;
                if(Que != Ans)
                    queryFields = Que + ', ' + Ans;
                string query = 'SELECT knowledgeArticleId, ' + queryFields + ' FROM ' + kaObj  
                                                            + ' WHERE knowledgeArticleId IN (' + KAIDSList + ') AND PublishStatus = \''+status+'\' '
                                                            + ' AND Language = \'' + kalanguage + '\'';
                system.debug('Query =>'+query);
                for (SObject kaObj :  Database.query('SELECT knowledgeArticleId, ' + queryFields + ' FROM ' + kaObj  
                                                            + ' WHERE knowledgeArticleId IN (' + KAIDSList + ') AND PublishStatus = \''+status+'\' '
                                                            + ' AND Language = \'' + kalanguage + '\'')) {
                    Id tempMasterKAId = (Id) kaObj.get('knowledgeArticleId');
                    Id knowledgeArticleId = (Id) kaObj.get('knowledgeArticleId');
                    String body = mapIdToKaBodyTemp.remove(tempMasterKAId);
                    List<String> kaUpdateList = mapMasterIdToKAUpdateList.get(tempMasterKAId);
                    if(body == Null) {
                        body = '"' + kalanguage.split('_')[0] + '":{"title":"'+ ((String)kaObj.get(Que)).replace('\"', '\\"') +'", "body":"'+ ((String)kaObj.get(Ans)).replace('\"', '\\"') +'", "enabled": true}';
                        kaUpdateList = new List<String>();
                    }
                    else {
                        body = body + ',"' + kalanguage.split('_')[0] + '":{"title":"'+ ((String)kaObj.get(Que)).replace('\"', '\\"') +'", "body":"'+ ((String)kaObj.get(Ans)).replace('\"', '\\"') +'", "enabled": true}';
                    }
                    kaUpdateList.add( kalanguage+ '=' + kaObj.get('knowledgeArticleId'));
                    mapIdToKaBody.put(tempMasterKAId, body);
                    mapVersionIdToKnowArticleId.put(tempMasterKAId, knowledgeArticleId);
                    mapMasterIdToKAUpdateList.put(tempMasterKAId, kaUpdateList);
                }
            }
            for(Id tempId : mapIdToKaBodyTemp.keySet()) {
                mapIdToKaBody.put(tempId, forNonEnglish + mapIdToKaBodyTemp.get(tempId));
            }
            Map<Id, String> mapIdToKaBody4Update = new Map<Id, String>();
 
            Set<String> alreadySyncId = new Set<string>();
            Map<Id, String> mapIdToHSFAQID4Update = new Map<Id, String>();
            for(HS_Sync__c itrSync : [SELECT SFKnowledgeArticleId__c, HS_FAQ_Id__c FROM HS_Sync__c WHERE SFKnowledgeArticleId__c IN : mapMasterIdToKAUpdateList.keySet() 
                                        AND HS_FAQ_Id__c != Null AND HSAppId__c = :selectedHSAppId Limit 10000]) {
                if(! alreadySyncId.contains(itrSync.SFKnowledgeArticleId__c) ) {
                    mapIdToHSFAQID4Update.put(itrSync.SFKnowledgeArticleId__c, itrSync.HS_FAQ_Id__c);
                    mapIdToKaBody4Update.put(itrSync.SFKnowledgeArticleId__c, mapIdToKaBody.remove(itrSync.SFKnowledgeArticleId__c));
                    alreadySyncId.add(itrSync.SFKnowledgeArticleId__c);
                }
            }
            System.debug('mapIdToKaBody4Update-->'+mapIdToKaBody4Update);
            
            List<HS_Sync__c> kaUpdateListToUpdate = new List<HS_Sync__c>();
            for(Id kaMasterId : mapIdToKaBody.keySet()) {
                HttpResponse resp = MakeCallOutOnHSServerAndSaveKA(mapIdToKaBody.get(kaMasterId), bodyPostfix);   
                for(String temp : mapMasterIdToKAUpdateList.get(kaMasterId)) {
                    HS_Sync__c kaUpdateObj = new HS_Sync__c(SFDC_KA_Id__c=temp+'='+selectedHSAppId, HSAppId__c=selectedHSAppId, HS_Section_Id__c=selectedHSSectionId, IsSyncSuccessful__c=True, Language__c=temp.split('=')[0], SFKnowledgeArticleId__c = mapVersionIdToKnowArticleId.get(kaMasterId));
                    if(resp.getStatusCode() == 201) {
                        FAQResponse rsltFAQ = (FAQResponse) JSON.deserialize(resp.getBody(), FAQResponse.Class);
                        kaUpdateObj.HS_FAQ_Id__c = rsltFAQ.id;
                        kaUpdateObj.HSSyncError__c = '';
                    }
                    else {
                        kaUpdateObj.IsSyncSuccessful__c = False;
                        kaUpdateObj.HSSyncError__c = resp.getStatusCode() + '-' + resp.getStatus() + '-' + resp.getBody();
                    }
                    kaUpdateListToUpdate.add(kaUpdateObj); 
                }
            } 
            
            for(Id kaMasterId : mapIdToKaBody4Update.keySet()) {
                List<String> kaUpdateList = mapMasterIdToKAUpdateList.get(kaMasterId);
                HttpResponse resp = MakeCallOutOnHSServerAndSaveKA(mapIdToKaBody4Update.get(kaMasterId), bodyPostfix, mapIdToHSFAQID4Update.get(kaMasterId));   
                System.debug(resp.getBody());
                for(String temp : kaUpdateList) {
                    HS_Sync__c kaUpdateObj = new HS_Sync__c(SFDC_KA_Id__c=temp+'='+selectedHSAppId, HSAppId__c=selectedHSAppId, HS_Section_Id__c=selectedHSSectionId, IsSyncSuccessful__c=True, Language__c=temp.split('=')[0]);
                    if(resp.getStatusCode() == 201 || resp.getStatusCode() == 200) {
                        FAQResponse rsltFAQ = (FAQResponse) JSON.deserialize(resp.getBody(), FAQResponse.Class);
                        kaUpdateObj.HS_FAQ_Id__c = rsltFAQ.id;
                        kaUpdateObj.HSSyncError__c = '';
                    }
                    else {
                        kaUpdateObj.IsSyncSuccessful__c = False;
                        kaUpdateObj.HSSyncError__c = resp.getStatusCode() + '-' + resp.getStatus() + '-' + resp.getBody();
                    }
                    kaUpdateListToUpdate.add(kaUpdateObj); 
                }
            } 
            if(! kaUpdateListToUpdate.isEmpty() ) {
                Upsert kaUpdateListToUpdate SFDC_KA_Id__c;
            }
        }
    }
    public httpResponse MakeCallOutOnHSServerAndSaveKA(String hsKaBody, String hsBodyPostfix) {
        return MakeCallOutOnHSServerAndSaveKA(hsKaBody, hsBodyPostfix, '');
    }
    public httpResponse MakeCallOutOnHSServerAndSaveKA(String hsKaBody, String hsBodyPostfix, String faqID) {
        String tempStr = '/faqs/' + faqID;
        String body = '{' + hsKaBody +'}';
        
        body = 'translations=' + EncodingUtil.urlEncode(body, 'UTF-8') +  hsBodyPostfix;
        System.debug(body );
        HttpResponse resp = HS_credentials.makeApiCall('POST', tempStr, body);
        return resp;
    }
    
    public List<WR_App> hsAppList {get; set;}
    public class WR_App {
        public String id {get; set;}
        public String title {get; set;}
        public String logo {get; set;}
        public String app_id {get; set;}
    }
    
    public class WR_Section {
        public Integer page {get; set;}
        public List<WR_App> sections {get; set;}
        public WR_Section() {
            sections = new List<WR_App>();
        }
    }
    

    public String fkn {get; set;}
    public PageReference onSave() {
        if(String.isBlank(newQue)) {
            HS_credentials.log('Error', 'Please select Api name for  Question');
        }
        else if(String.isBlank(newAns)) {
            HS_credentials.log('Error', 'Please select Api name for Answer');
        }
        else {
            String successMsg = HS_ConfigureFAQSettings.HS_ConfigureFAQSettings(newkaObj, newQue, newAns);
            if(successMsg == 'success') {
                HS_credentials.log('Confirm', 'Mapping is saved. Please refresh Page.');
                Que = newQue;
                Ans = newAns;
            }
            else {
                HS_credentials.log('Error', successMsg);
            }
        }
        return null;
    }
    
    public Map <String, Schema.SObjectType> GetAllArticleTypeSchemaMap() {
        Map<String, Schema.SObjectType> kaSchemaMap = new  Map<String, Schema.SObjectType>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        for(String objName : schemaMap.keySet()) {
            if(objName.contains('__kav')) {
                kaSchemaMap.put(objName, schemaMap.get(objName));
            }
        }
        return kaSchemaMap;
    }
    
    public List<SelectOption> getArticleTypes(){
        List<SelectOption> articleTypeOptionsList = new List<SelectOption>();
        articleTypeOptionsList.add(new SelectOption('', '--None--'));
        //-- Describe Result to get all article type names
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Set<String> keySet = gd.keySet();
        for (String key : keySet) {
            Schema.SObjectType objectType = gd.get(key);
            if (key.endsWith('kav')){
                articleTypeOptionsList.add(new SelectOption(objectType.getDescribe().getName().toLowerCase(), objectType.getDescribe().getLabel()));
                if(newkaObj == objectType.getDescribe().getName()) {
                    getArticleTypeFields();
                }
            }
        }
        return articleTypeOptionsList;
    }
    
    public List<SelectOption> kaQueFieldOptionsList {get; set;}
    public List<SelectOption> kaAnsFieldOptionsList {get; set;}
    public PageReference getArticleTypeFields(){
        newQue = Que;
        newAns = Ans;
        kaQueFieldOptionsList = new List<SelectOption>();
        kaAnsFieldOptionsList = new List<SelectOption>();
        if(String.isNotBlank(newkaObj)){
            //-- Describe Result to get selected article type fields
            Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
            if(gd.containsKey(newkaObj)) {
                Schema.SObjectType objectType = gd.get(newkaObj);          
                Set<String> notAllowedFieldSet = new Set<String>{'articlenumber', 'publishstatus', 'knowledgearticleid', 'lastpublisheddate', 'language'};    
                for(Schema.SObjectField sObjFld : objectType.getDescribe().fields.getMap().values()){
                    Schema.DescribeFieldResult dfr = sObjFld.getDescribe();  
                    Schema.DisplayType fldType = dfr.getType();
                    if((fldType==Schema.DisplayType.String || fldType==Schema.DisplayType.TextArea) && notAllowedFieldSet.contains(dfr.getName().toLowerCase())==False) { 
                        kaQueFieldOptionsList.add(new SelectOption(dfr.getName().toLowerCase(), dfr.getLabel()));          
                        kaAnsFieldOptionsList.add(new SelectOption(dfr.getName().toLowerCase(), dfr.getLabel()));
                    }
                }              
            }
        }
        return null;
    }
    
    public List<sObject> sList {get; set;}
        
        
       
    
}