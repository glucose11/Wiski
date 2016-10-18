/**
 * Unit Test for Apex Class - HelpshiftOmniChannelSetting
 *
 * @author  Deepak K Anand
 * @since   11 Sept 2016
 */
@isTest
public class HelpshiftOmniChannelSetting_Test {
    ///////////////////////////
    //Private Helper Methods //
    ///////////////////////////

    /**
     * Create Test Data
     */
    static void createTestData() {
        INSERT new HelpshiftSetting__c( SettingName__c = 'Omni-ChannelEnabled', IsOmniChannelEnabled__c = TRUE );
    }

    //////////////////////
    //Unit Test Methods //
    //////////////////////
    testMethod
    static void SaveSetting_NoData_Test() {
        Test.startTest();

            HelpshiftOmniChannelSetting setting = new HelpshiftOmniChannelSetting();

            Test.setMock( HttpCalloutMock.class, new MockHttpResponseGenerator() );

            setting.SaveSetting();

        Test.stopTest();

        System.assertEquals( 'Save successful.', setting.omniMessage );
    }

    testMethod
    static void SaveSetting_WithData_Test() {
        createTestData();
        
        HelpshiftOmniChannelSetting setting = new HelpshiftOmniChannelSetting();

        Test.setMock( HttpCalloutMock.class, new MockHttpResponseGenerator() );

        /**
         * The startTest() and stopTest()
         * have been brought down to make
         * sure the DMLs have been committed
         * before we make a callout.
         */
        Test.startTest();
        
            setting.SaveSetting();

        Test.stopTest();

        System.assertEquals( 'Save successful.', setting.omniMessage );
    } 
}