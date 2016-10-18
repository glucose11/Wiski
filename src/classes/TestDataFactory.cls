@isTest
public class TestDataFactory {
    //-- Method to create test "Helpshift Admin App Sync Setting" custom setting
    public static HelpshiftAdminAppSyncSetting__c createAdminAppSyncSetting() {
    
        HelpshiftAdminAppSyncSetting__c appSync = new HelpshiftAdminAppSyncSetting__c();
        appSync.Name = 'HSSyncAdminSetting';
        appSync.HSDomain__c = 'http://hshshs2';
        appSync.HSAccessKey__c = 'hshshs2_api_20160120195521693-d62bf38f31dae5f';                        
        appSync.FAQEndpointPrefix__c = 'https://api-test.helpshift.mobi/v1/';
        appSync.LastBatchExecutionDateTime__c = System.now().addDays(-1);
        
        INSERT appSync;
        return appSync;
    }
    
    //-- Method to create test "Helpshift App Field Mapping" custom setting
    public static HelpshiftAppFieldMapping__c createAppFieldMappingSetting() {
    
        HelpshiftAppFieldMapping__c fieldMap = new HelpshiftAppFieldMapping__c();
        fieldMap.Name = 'HS FAQ Field Mapping';
        fieldMap.SF_KAArticleTypeApiName__c = new TestDataFactory().getArticleTypeName();        
        fieldMap.SFFieldName_For_HSQestion__c = 'Title';
        fieldMap.SFFieldName_For_HSAnswer__c = 'Summary';
        
        INSERT fieldMap;
        return fieldMap;
    }
    
    //-- Method to create test "Sync Issue" custom setting
    public static Sync_Issue__c createSyncIssueSetting() {
    
        Sync_Issue__c syncIssue = new Sync_Issue__c();
        syncIssue.Name = 'Sync Issue';
        syncIssue.Last_Sync_Time__c = System.now();
        
        INSERT syncIssue;
        return syncIssue;
    }
    
    public String getArticleTypeName() {
        
        String articleTypeName = '';
        
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Set<String> keySet = gd.keySet();
        for (String key : keySet) {
            Schema.SObjectType objectType = gd.get(key);
            if (key.endsWith('kav')){
                articleTypeName = objectType.getDescribe().getName();  
                break;              
            }
        } 
        
        return articleTypeName;       
    }
    
    public sObject createKnowledgeData(String articleTypeName) {
        Long uniquePrefix = System.now().getTime();
        
        sObject FAQsObj = Schema.getGlobalDescribe().get(articleTypeName).newSObject();
        FAQsObj.put('Title',  'batchHSFAQSync v2 Test ' + uniquePrefix);
        FAQsObj.put('UrlName',  'batchHSFAQSync-v2-Test-' + uniquePrefix);
        FAQsObj.put('Summary',  'batchHSFAQSync v2 Test Answer');
        FAQsObj.put('Language',  'en_US');        
        
        INSERT FAQsObj;
        
        String queryStr = 'SELECT KnowledgeArticleId,  PublishStatus, ID ';
        queryStr = queryStr + 'FROM ' + articleTypeName;
        queryStr = queryStr + ' WHERE Id = \''+FAQsObj.ID+'\'';
        system.debug('Final Query=>'+queryStr );
        FAQsObj = Database.query(queryStr);
        
        return FAQsObj;
        
    }
    
    public static sObject createKnowledgeDataWithLang(String articleTypeName, String language) {
        Long uniquePrefix = System.now().getTime();
        
        sObject FAQsObj = Schema.getGlobalDescribe().get(articleTypeName).newSObject() ;
        FAQsObj.put('Title',  'batchHSFAQSync v2 Test ' + uniquePrefix);
        FAQsObj.put('UrlName',  'batchHSFAQSync-v2-Test-' + uniquePrefix);
        FAQsObj.put('Summary',  'batchHSFAQSync v2 Test Answer');
        FAQsObj.put('Language',  language);        
        
        INSERT FAQsObj;
        
        String queryStr = 'SELECT KnowledgeArticleId,  PublishStatus, ID ';
        queryStr = queryStr + 'FROM ' + articleTypeName;
        queryStr = queryStr + ' WHERE Id = \''+FAQsObj.ID+'\'';
        system.debug('Final Query=>'+queryStr );
        FAQsObj = Database.query(queryStr);
        
        return FAQsObj;
    }
    
    public static HS_Sync__c createHSSync(Id knowledgeArticleId, String language) {
        HS_Sync__c hsSync = new HS_Sync__c();
        hsSync.SFKnowledgeArticleId__c = knowledgeArticleId;
        hsSync.SFDC_KA_Id__c = knowledgeArticleId;
        hsSync.Language__c = language;
        hsSync.HSAppId__c = 'HSFaq Test AppId';
        hsSync.HS_Section_Id__c = 'HSFaq Test SectionId';
        hsSync.HS_FAQ_Id__c = 'HSFaq Test FAQId';
        INSERT hsSync;
        
        return hsSync;
    }
}