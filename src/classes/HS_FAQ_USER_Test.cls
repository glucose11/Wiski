/*
 * This is the Apex Unit Test for the HS_ConfigureFAQSettings ,HSUser,  HSFaq Apex Class 
 * 
 * @author  Dazeworks Technologies Pvt Ltd
 * @since   29th January 2016
 * @version 1.0
 */
@isTest
private class HS_FAQ_USER_Test {
    private static testMethod void HS_ConfigureFAQSettings_Test() {
      HS_ConfigureFAQSettings.HS_ConfigureFAQSettings('TestObj','TestQ','TestAns');
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
      HSUser hu = new HSUser();
      hu.selectedUsIds =userinfo.getuserid();
      hu.createHSUser();
      Test.stopTest();
      User loggedINUser = [Select id, isHSUser__c from User where id =: userinfo.getuserid()];
      System.assertEquals(loggedINUser.isHSUser__c, true);
      /*TestDataFactory tf = new TestDataFactory();
      sObject sob = tf.createKnowledgeData('Helpshift__Test_article_type__kav');
      HelpshiftAdminAppSyncSetting__c  happ = TestDataFactory.createAdminAppSyncSetting();
      
      HS_credentials.sfObject='Helpshift__Test_article_type__kav';
      HSFaq hf = new HSFaq();
      hf.selectedKAIds=sob.id;
      hf.selectedHSAppId = happ.id;
      hf.selectedHSSectionId ='';
      hf.selectedPublishStatus = 'draft';
      hf.isSyncOneTransOnly = true;
      hf.selectedLanguage = 'en_US';
      hf.createHSFaq();
      */
    }
    
   
}