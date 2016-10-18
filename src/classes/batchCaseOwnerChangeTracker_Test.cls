/**
 * Unit Test for the Apex Class - batchCaseOwnerChangeTracker
 *
 * @author  Deepak K Anand
 * @since   10 Sept 2016
 */
@isTest
public class batchCaseOwnerChangeTracker_Test {
    /**
     * We definitely need to test against
     * multiple records but that doesn't
     * really work in our case because if
     * we increase the number to handle multiple
     * Cases it throws the dreaded "No more than
     * one Database.executeBatch( ... ) can be
     * called from a Test Context" and hence this
     * dirty hack!
     */
    public static final Integer NO_OF_CASES = 1;

    public enum SyncIssueFlag {
        ISSUE_OWNER_LAST_SYNC_NULL,
        ISSUE_OWNER_LAST_SYNC_NOT_NULL
    }

    ////////////////////////////
    // Private Helper Methods //
    ////////////////////////////

    /**
     * createSyncIssueSettings          Create the 'Sync Issue' Custom Setting in 2
     *                                  ways so as to cover the different IF clauses.
     * @param                   flag    Different Modes of Execution for the Test Routine
     */
    static void createSyncIssueSettings( SyncIssueFlag flag ) {
        /**
         * Setting up data in the Custom Settings -
         * Sync_Issue__c
         */
        Sync_Issue__c syncIssue = new Sync_Issue__c();
        syncIssue.Name = 'Sync Issue';

        if( flag == SyncIssueFlag.ISSUE_OWNER_LAST_SYNC_NULL ) {
            /**
             * Reserved for future use
             * in case any!
             */
        }
        else if( flag == SyncIssueFlag.ISSUE_OWNER_LAST_SYNC_NOT_NULL ) {
            syncIssue.IssueOwnerLastSync__c = System.now();
        }

        INSERT syncIssue;
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
            TimeZoneSidKey      = 'America/Los_Angeles'
        );

        INSERT adminUser;

        return adminUser;
    }

    /**
     * createCases      Create Test Case Records.
     */
    static void createCases() {
        List<Case> testCaseRecords = new List<Case>();

        for( Integer counter = 1; counter <= NO_OF_CASES; counter++ ) {
            testCaseRecords.add(
                new Case(
                    Status = 'New',
                    Origin = 'Web'
                )
            );
        }

        INSERT testCaseRecords;

        /**
         * This will be the be Admin User.
         * This is in order to simulate
         * an Owner Change.
         */
        User adminUser = createUser();

       /**
         * Inserting CaseHistory records
         * for the Batch Job to run. You
         * can't really simulate the automatic
         * creation of CaseHistory records
         * instead this dirty hack!
         *
         * Also lot of blockers when it comes
         * to testing History table. These
         * records are not created in the
         * Test Context nor does Salesforce
         * allow us to set the NewValue or
         * OldValue field!
         */
        List<CaseHistory> testCaseHistories = new List<CaseHistory>();
        for( Case testCase : testCaseRecords ) {
            testCaseHistories.add(
                new CaseHistory(
                    CaseId      = testCase.Id,
                    Field       = 'Owner'
                )
            );
        }

        INSERT testCaseHistories;
    }

    ///////////////////////
    // Unit Test Methods //
    ///////////////////////
    
    testMethod
    static void batchCaseOwnerChangeTracker_LastSyncNull_Test() {
        Test.startTest();
            
            createSyncIssueSettings( SyncIssueFlag.ISSUE_OWNER_LAST_SYNC_NULL );

            createCases();

            batchCaseOwnerChangeTracker batchJob = new batchCaseOwnerChangeTracker();

            /**
             * Set the "currentTime" to somewhere
             * in the future to that Query Locator
             * will get CaseHistory records!
             */
            batchJob.currentTime = System.now().addMinutes( 5 );
        
            Database.executeBatch( batchJob, 1 );

        Test.stopTest();

        Sync_Issue__c syncIssueSettings = Sync_Issue__c.getValues( 'Sync Issue' );
        
        /**
         * That's pretty much all you can
         * assert!
         */
        System.assertEquals( TRUE, syncIssueSettings.IssueOwnerLastSync__c != NULL );
    }

    testMethod
    static void batchCaseOwnerChangeTracker_LastSyncNotNull_Test() {
        Test.startTest();

            createSyncIssueSettings( SyncIssueFlag.ISSUE_OWNER_LAST_SYNC_NOT_NULL );

            createCases();

            batchCaseOwnerChangeTracker batchJob = new batchCaseOwnerChangeTracker();

            /**
             * Set the "currentTime" to somewhere
             * in the future to that Query Locator
             * will get CaseHistory records!
             */
            batchJob.currentTime = System.now().addMinutes( 5 );
        
            Database.executeBatch( batchJob, 1 );

        Test.stopTest();

        Sync_Issue__c syncIssueSettings = Sync_Issue__c.getValues( 'Sync Issue' );

        /**
         * That's pretty much all you can
         * assert!
         */
        System.assertEquals( TRUE, syncIssueSettings.IssueOwnerLastSync__c != NULL );
    }
}