/**
 * Unit Test for Apex Class - HSUser
 *
 * @author  Deepak K Anand
 * @since   11 Sept 2016
 */
@isTest
public class HSUser_Test {
    private static final Integer NO_OF_USERS = 2;
    private static final List<String> TEST_EMAILS = new List<String>{ 
        'dazeworks@helpshift.com', 
        'niranja@helpshift.com' 
    };

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
     * Create Test User Accounts
     * 
     * @param   emails      The List of Emails that will be assigned on the respective User being created
     * @param   noOfUsers   The Total Number of Users that needs to be created
     */
    static void createUsers( List<String> emails, Integer noOfUsers ){
        List<User> usersToCreate = new List<User>();

        for( Integer counter = 1; counter <= noOfUsers; counter++ ) {
            usersToCreate.add(
                new User(
                    Username            = UserInfo.getOrganizationId() + System.now().millisecond() + emails[counter - 1],
                    Alias               = 'hsuser' + counter,
                    Email               = emails[counter - 1],
                    EmailEncodingKey    = 'UTF-8',
                    LastName            = 'User',
                    languageLocaleKey   = 'en_US',
                    LocaleSidKey        = 'en_US',
                    ProfileId           = [ 
                        SELECT  Id 
                        FROM    Profile 
                        WHERE   Name    = 'System Administrator'
                    ].Id,
                    TimeZoneSidKey      = 'America/Los_Angeles',
                    HSUserId__c         = NULL
                )
            );
        }

        INSERT usersToCreate;
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
        createUsers( TEST_EMAILS, NO_OF_USERS );
    }

    ///////////////////////
    // Unit Test Methods //
    ///////////////////////

    testMethod
    static void doGetHS_Users_Test() {
        Test.startTest();

            Test.setMock( HttpCalloutMock.class, new MockHttpResponseGenerator() );

            HSUser hsUsrMgr = new HSUser();

            hsUsrMgr.doGetHS_Users();

        Test.stopTest();

        List<User> updatedUsers = [
            SELECT  HSUserId__c
            FROM    User
            WHERE   Email IN :TEST_EMAILS
        ];

        /**
         * Verify that HSUserId__c
         * field on the User Accounts
         * created in the Test Class has
         * been updated to a non-NULL
         * value.
         */
        for( User updatedUser : updatedUsers ) {
            System.assertEquals( TRUE, updatedUser.HSUserId__c != NULL );
        }
    }

    testMethod
    static void doDeleteHS_Users_Test() {
        Test.startTest();

            Test.setMock( HttpCalloutMock.class, new MockHttpResponseGenerator() );

            HSUser hsUsrMgr = new HSUser();

            hsUsrMgr.hsAgentId  = generateUniqueHSCompatId();
            hsUsrMgr.sfUserId   = [
                SELECT  Id 
                FROM    User
                WHERE   Email IN :TEST_EMAILS
                LIMIT   1
            ].Id;

            hsUsrMgr.doDeleteHS_Users();

        Test.stopTest();

        System.assertEquals( TRUE, hsUsrMgr.isAgentDeleted );
    }

    testMethod
    static void createHSUser_Test() {
        Test.startTest();

            Test.setMock( HttpCalloutMock.class, new MockHttpResponseGenerator() );
            
            HSUser hsUsrMgr = new HSUser();

            List<String> userIds = new List<String>();
            for( User testUser : [
                SELECT  Id
                FROM    User
                WHERE   Email IN : TEST_EMAILS
            ] ) {
                userIds.add( testUser.Id );
            }

            hsUsrMgr.selecteduSIds = String.join( userIds, ',' );

            hsUsrMgr.createHSUser();

        Test.stopTest();

        /**
         * Ensure that the Permission
         * Set for the 2 User Account(s)
         * were assigned.
         */
        System.assertEquals( 
            2, 
            [
                SELECT  COUNT() 
                FROM    PermissionSetAssignment 
                WHERE   AssigneeId IN : userIds AND 
                        PermissionSet.Name = 'Helpshift_App_Access'
            ]
        );

        /**
         * Ensure that the HS Profile
         * Id retrieved from the createAgent
         * call has been updated to the
         * respective User record.
         */
        System.assertEquals( 
            2, 
            [
                SELECT  COUNT() 
                FROM    User 
                WHERE   Id IN : userIds
                AND     HSUserId__c != NULL
            ]
        );
        
        System.assertEquals( TRUE, hsUsrMgr.isUserSynced );
    }
}