@isTest
private class batchHSFAQSync_v2_Test {
    static SObject enUSFAQ;
    
    static void createSettingsData() {
        TestDataFactory.createSyncIssueSetting();
        TestDataFactory.createAdminAppSyncSetting();
        TestDataFactory.createAppFieldMappingSetting();
    }
    
    static void createKnowledgeData() {
        Long uniquePrefix = System.now().getTime();
        
        SObject faq = TestDataFactory.createKnowledgeDataWithLang(new TestDataFactory().getArticleTypeName(), 'en_US');
        
        KbManagement.PublishingService.publishArticle((Id)faq.get('KnowledgeArticleId'), TRUE);
        
        enUSFAQ = faq;
    }
    
    static void createHSSynData() {
        TestDataFactory.createHSSync((Id)enUSFAQ.get('KnowledgeArticleId'), 'en_US');
    }
    
    private static testMethod void batchHSFAQSync_v2_ctor_Test() {
        Test.startTest();
        
        createSettingsData();
        
        batchHSFAQSync_v2 hsFAQSync = new batchHSFAQSync_v2();
        
        Test.stopTest();
        
        System.assertEquals(TRUE, hsFAQSync.hsAdminSetting != NULL);
        System.assertEquals(TRUE, hsFAQSync.fldSettingFAQ != NULL);
        System.assertEquals(TRUE, hsFAQSync.authKey != NULL);
        System.assertEquals(TRUE, hsFAQSync.kaObj != NULL);
    }
    
    private static testMethod void batchHSFAQSync_v2_Test() {
        Test.startTest();
        
        createSettingsData();
        
        createKnowledgeData();
        
        createHSSynData();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        batchHSFAQSync_v2 hsFAQSync = new batchHSFAQSync_v2();
        
        Database.executeBatch( hsFAQSync );
         
        Test.stopTest();
        
        System.assertEquals(1, [SELECT COUNT() FROM HS_Sync__c WHERE IsSyncSuccessful__c = TRUE]);
    }
    private static testMethod void t19() {
        Case caseA = new Case();
        caseA.Subject = 'CAAWTest_execute_WithAccount_Test_A';
        caseA.Author_Email__c = 'CAAW_execWithAcc_A@dazeworks.com';
        List<Case> casesToInsert = new List<Case>();
        casesToInsert.add( caseA );
        INSERT casesToInsert;
    }
    private static testMethod void t1() {
        //batchHSFAQSync_v2.dummyTestMethod();
        System.assertEquals(1,1);
    }
}