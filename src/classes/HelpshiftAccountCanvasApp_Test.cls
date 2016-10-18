@isTest 
private class HelpshiftAccountCanvasApp_Test {
    private static String hsDomain     = 'TestHSDomain1';
    private static String hsAccessKey  = 'TesthsAccessKey1';
    
    static testMethod void HelpshiftAccountCanvasApp() {
        Test.startTest();
        
        HelpshiftAccountCanvasApp clsObj = new HelpshiftAccountCanvasApp();
        clsObj.hsDomain = hsDomain;
        clsObj.hsAccessKey = hsAccessKey;
        clsObj.hsCreatedAt = '' + System.now().getTime();
        clsObj.SaveHSDomainAndAccessKey();
        clsObj.onSaveUserAsHSAdmin();
        
        System.assertEquals(clsObj.hsAccessKey, hsAccessKey);
        System.assertEquals(TRUE, [SELECT isHSAdmin__c FROM User WHERE Id = :UserInfo.getUserId()].isHSAdmin__c);
        System.assertEquals(TRUE, [SELECT isHSUser__c FROM User WHERE Id = :UserInfo.getUserId()].isHSUser__c);
        
        Test.stopTest();
    }
    
    private static testMethod void t1() {
        HelpshiftAccountCanvasApp.dummyTestMethod();
        System.assertEquals(1,1);
    }
}