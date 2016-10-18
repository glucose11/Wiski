/**
 * @revision    R.1         Modified the createHSUser routine to
 *                          to utilize the response from the
 *                          <createAgent> API Call and store the
 *                          Profile Id onto the corresponding
 *                          User in Salesforce.
 *
 */
public with sharing class HSUser {

    public String selectedUsIds             {get; set;}  
    public List<User> userList              {get;set;}
    public List<User> syncUserList          {get;set;}
    public Integer pageNo                   {get; set;}
    public boolean isHSAccountCreated {get; set;}
    public HSUser() {
        InitUser();
    
    }
    public void InitUser() {
        isHSAccountCreated = String.isNotBlank(HS_credentials.hsDomain);
        userList = [SELECT Name, Email, UserRole.Name, SmallPhotoUrl, isHSUser__c, isHSAdmin__c FROM User 
                        WHERE isActive = True AND UserType != 'CsnOnly' Limit 1000]; //AND isHSUser__c = False 
        syncUserList = new List<User>();
        /*
        syncUserList = [SELECT Name, Email, UserRole.Name, SmallPhotoUrl, isHSUser__c, isHSAdmin__c FROM User 
                        WHERE isActive = True AND isHSUser__c = TRUE Limit 1000];
        */
    }
    
    public String HS_Users {get; set;}
    public void doGetHS_Users() {
        if(pageNo == Null)
            pageNo = 1;
        HttpResponse resp = HS_credentials.makeApiCall('GET', '/agents?provider=salesforce&page='+pageNo, Null);
        System.debug(resp.getBody());
        if(resp.getStatusCode() == 200) {
            HS_Users = resp.getBody();
            WR_App HS_Users = (WR_App) Json.deserialize(resp.getBody(), WR_App.class);
            if(HS_Users != null && HS_Users.Profiles != null) {
                map<String, String> mapUserList = new map<String, String>();
                for(profiles p : HS_Users.Profiles) {
                    mapUserList.put(p.email, p.id);
                }
                List<User> usList = new List<User>();
                for(User us : [SELECT Email, HSUserId__c FROM User WHERE Email IN : mapUserList.keySet() ]) {
                    us.HSUserId__c = mapUserList.get(us.Email);
                    usList.add(us);
                }
                if(! usList.isEmpty() ) {
                    Update usList;
                }
            }
        }
    }
    
    public String hsAgentId {get; set;}
    public String sfUserEmail {get; set;}
    public String sfUserId {get; set;}
    public Boolean isAgentDeleted {get; set;}
    public void doDeleteHS_Users() {
        isAgentDeleted = false;
        if(String.isNotBlank(hsAgentId) && String.isNotBlank(sfUserId)) {
            hsAgentId = string.escapesinglequotes(hsAgentId);
            HttpResponse resp = HS_credentials.makeApiCall('DELETE', '/agents/' + hsAgentId + '?provider=salesforce', Null);
            System.debug(resp.getBody());
            if(resp.getStatusCode() == 200) {
                isAgentDeleted = true;
                sfUserId = string.escapesinglequotes(sfUserId);
            }
        }
    }
    
    
    public Boolean isUserSynced {get; set;}
    public void createHSUser() {
        Boolean haveDMLPermission =  Schema.sObjectType.User.isUpdateable() && Schema.sObjectType.User.fields.isHSUser__c.isUpdateable();
        Boolean canAsgnPermissionset =  Schema.sObjectType.PermissionSetAssignment.isCreateable();
        if(haveDMLPermission==false) { HS_credentials.log('Error', 'You don\'t have Update permission on isHSUser__c field on User object.'); }
        else if(!canAsgnPermissionset){ HS_credentials.log('Error', 'You can not permission to assign permissionset to Users.'); }
        else {
            try{
            System.debug(LoggingLevel.Error, 'selecteduSIds<---->'+selecteduSIds);
            isUserSynced = false;
                if(String.isNotBlank(selecteduSIds)) {
                    System.debug(LoggingLevel.Error, 'selecteduSIds<---->'+selecteduSIds);
                    PermissionSet objPrmset = [SELECT Id FROM PermissionSet WHERE Name = 'Helpshift_App_Access' and NamespacePrefix = 'DazeworksDemo' Limit 1];
                    String UsIdsList = String.escapeSingleQuotes(selectedUsIds);
                    List<String> usList = UsIdsList.split(',');
                    List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
                    String tempStr = '';
                    List<User> tempUserList = [SELECT Id, FirstName, LastName, Email, (SELECT Id FROM PermissionSetAssignments WHERE PermissionSetId= :objPrmset.Id Limit 1) 
                                                        FROM User WHERE Id IN : usList Limit 10000];
                    System.debug(LoggingLevel.Error, 'tempUserList <---->'+tempUserList );
                    for(User us : tempUserList) {
                        us.isHSUser__c = true;
                        tempStr = tempStr +',{"provider":"salesforce","email": "'+encodeStr(us.Email)+'","password":"'+encodeStr(us.Id)+'", "first-name": "'+encodeStr(us.FirstName)+'", "last-name":"'+encodeStr(us.LastName)+'"}';
                        System.debug(objPrmset.Id+'---us.PermissionSetAssignments---->'+us.PermissionSetAssignments);
                        if(us.PermissionSetAssignments.isEmpty()) {
                            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId=objPrmset.Id, AssigneeId=us.Id);
                            psaList.add(psa);
                        }
                        System.debug(LoggingLevel.Error, 'psaList---->'+psaList);
                    }
                    tempStr = 'agents=[' + tempStr.substring(1, tempStr.length()) + ']';
                    HttpResponse resp = HS_credentials.makeApiCall('POST', '/agents', tempStr);
                    System.debug(LoggingLevel.Error, 'resp ---->'+resp.getBody() );
                    if(! tempUserList.isEmpty() && resp.getStatusCode() == 201 || resp.getStatusCode() == 409) {
                        System.debug('tempUserList---->'+tempUserList);
                        System.debug('psaList---->'+psaList);
                        isUserSynced = true;

                        /**
                         * Added by Deepak K Anand( 10 Sept 2016 )
                         * Refer Revision R.1
                         */
                        tempUserList = storeHSAgentProfileId( resp.getBody(), tempUserList );

                        Update tempUserList;
                        if(!psaList.isEmpty())
                            Insert psaList;
                    }
                 }   
             } catch(Exception ex){ HS_credentials.log('Error', ex.getMessage()); }
         }
    }
    
    private String encodeStr(String strToEncode) {
        if(String.isNotBlank(strToEncode)) {
            strToEncode = EncodingUtil.urlEncode(strToEncode, 'UTF-8');
        }
        return strToEncode;
    }
    
    ////////////////////////
    // Refer Revision R.1 //
    ////////////////////////
    /**
     * Parse the response from the the "createAgent"
     * API call(provided a 200 OK) to retrieve the Profile Id
     * and store the same on the User record being created.
     * 
     * @param       createAgentResponse     The JSON response retrieved as
     *                                      a result of the createAgent API
     *                                      call. Typically a response upon
     *                                      a 200 OK would look like this:
     *                                      [
     *                                          {
     *                                              "status"    : "ok",
     *                                              "email"     : "adie+daze@helpshift.com",
     *                                              "id"        : "dazeworks3_profile_20160831183545534-12525d16308cf6f"
     *                                          }
     *                                      ]
     * @param       usersSendToHS           The List of User records that were send to
     *                                      HelpShift system.
     * @return      List<User>              The List of Users into which their corresponding
     *                                      Profile Id from HS has been mapped.
     * @see         HSUser.createHSUser
     * @version     1.0
     * @author      Deepak K Anand
     * @since       10 Sept 2016
     */
    private List<User> storeHSAgentProfileId( String createAgentResponse, List<User> usersSendToHS ) {
        List<HSAgent> createdHSAgents = ( List<HSAgent> )JSON.deserialize( createAgentResponse, List<HSAgent>.class );

        Map<String, User> emailToUserMap = new Map<String, User>();
        for( User usr : usersSendToHS ) {
            emailToUserMap.put( usr.Email, usr );
        }

        List<User> profileMappedUsers = new List<User>();
        for( HSAgent createdAgent : createdHSAgents ) {
            User usr = emailToUserMap.get( createdAgent.email );

            /**
             * Store the Profile Id
             * onto a Custom Field on
             * the User record.
             */
            //usr.HSProfileId__c = createdAgent.id;
            usr.HSUserId__c = createdAgent.id;
            profileMappedUsers.add( usr );
        }

        return profileMappedUsers;
    }

    ////////////////////////
    // Refer Revision R.1 //
    ////////////////////////
    /**
     * The Data Structure representing an ideal
     * response from the createAgent
     * API Call upon 200 OK.
     */
    public class HSAgent {
        public String status    { get; set; } 
        public String email     { get; set; } 
        public String id        { get; set; }
    }
        
    
    public class WR_App {

        public Integer page;
        public Integer page_size;
        public List<Profiles> profiles;
        public Integer total_profiles;
        public Integer total_pages;
    
        
    }
     
     public class Profiles {
            public String id;
            public String name;
            public String email;
            public String avatar;
        }
   
}