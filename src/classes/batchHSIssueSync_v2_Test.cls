@isTest
private class batchHSIssueSync_v2_Test {

    private static testMethod void batchHSIssueSync_v2_Test() {
        TestDataFactory.createAdminAppSyncSetting();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        batchHSIssueSync_v2 issueClsObj = new batchHSIssueSync_v2();
        issueClsObj.syncIssues();
        issueClsObj.setPageNos(1,1);
        Test.stopTest();
        
    }
    
}