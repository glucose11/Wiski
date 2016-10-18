/**
 * Unit Test for Apex Class - HSApiCallOnOwnerChange
 *
 * @author  Deepak K Anand
 * @since   11 Sept 2016
 */
@isTest
public class HSApiCallOnOwnerChange_Test {
    /**
     * To facilitate bulk testing
     */
    private static final Integer NO_OF_CASES = 5;

    ////////////////////////////
    // Private Helper Methods //
    ////////////////////////////
    
    /**
     * Generate random and unique HS Issue Id / HS User Id
     * 
     * @return  String      A GUID like String representing an Issue Id / User Id
     */
    static String generateUniqueHSCompatId() {        
        String hex  = EncodingUtil.ConvertTohex( Crypto.GenerateAESKey( 128 ) );
        
        String uniqueHSId = 
            hex.SubString(  0,  8   ) + '-' + 
            hex.SubString(  8,  12  ) + '-' + 
            hex.SubString(  12, 16  ) + '-' + 
            hex.SubString(  16, 20  ) + '-' + 
            hex.substring(  20 );

        return uniqueHSId;
    }

    /**
     * Create Test Case records
     */
    static void createCases() {
        /**
         * Create a Test Admin User
         */
        User testAdminUser = createUser();

        List<Case> testCasesToCreate = new List<Case>();

        for( Integer counter = 1; counter <= NO_OF_CASES; counter++ ) {
            testCasesToCreate.add(
                new Case(
                    Status          = 'New',
                    Origin          = 'Web',
                    HSIssueId__c    = generateUniqueHSCompatId(),
                    OwnerId         = testAdminUser.Id
                )
            );
        }

        INSERT testCasesToCreate;
    }

    /**
     * createUser               Create a User with Administrator Privileges
     * @return      User        The newly created User record.
     */
    static User createUser(){
        User adminUser = new User(
            Username            = UserInfo.getOrganizationId() + System.now().millisecond() + 'adminuser@helpshift.com',
            Alias               = 'admuser',
            Email               = 'adminuser@helpshift.com',
            EmailEncodingKey    = 'UTF-8',
            LastName            = 'User',
            languageLocaleKey   = 'en_US',
            LocaleSidKey        = 'en_US',
            ProfileId           = [ SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            TimeZoneSidKey      = 'America/Los_Angeles',
            HSUserId__c         = generateUniqueHSCompatId()
        );

        INSERT adminUser;

        return adminUser;
    }

    /**
     * This method will be implicitly
     * invoked at the beginning of each
     * of the Unit Test Routines thus
     * avoiding an explicit call to the
     * data preparation methods / routines.
     */
    @testSetup
    static void createTestData() {
        /**
         * Isolating test data creation
         * to separate methods to improve
         * readability!
         */
        createCases();
    }

    //////////////////////////////////
    // Unit Test Routines / Methods //
    //////////////////////////////////
    
    testMethod
    static void HSAPiCallCaseOwnerIds_Test() {
        Test.startTest();

            Test.setMock( HttpCalloutMock.class, new MockHttpResponseGenerator() );

            /**
             * Grab just one Case record
             * and send it to the HS System.
             */
            Case testCase = [ 
                SELECT  Id 
                FROM    Case 
                LIMIT   1
            ];

            HSApiCallOnOwnerChange.HSAPiCallCaseOwnerIds( testCase.Id );

        Test.stopTest();

        /**
         * There isn't anything that can be
         * asserted!
         */
    }

    testMethod
    static void HSAPiCallCaseOwnerIdsSet_Test() {
        Test.startTest();

            Test.setMock( HttpCalloutMock.class, new MockHttpResponseGenerator() );

            /**
             * Grab just all the Case records
             * and send it to the HS System.
             */
            Map<Id, Case> testCases = new Map<Id, Case>(
                [ 
                    SELECT  Id 
                    FROM    Case
                ]
            );

            HSApiCallOnOwnerChange.HSAPiCallCaseOwnerIdsSet( testCases.keySet() );

        Test.stopTest();

        /**
         * There isn't anything that can be
         * asserted!
         */
    }
}