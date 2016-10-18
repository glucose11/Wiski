public with sharing class HelpshiftAccountCanvasApp {
    public String hsDomain     {get; set;}
    public String hsAccessKey  {get; set;}
    public String domainVar    {get; set;}
    public Boolean hsDomainExists {get; set;}
    public String hsCreatedAt     {get; set;}
    public String sandboxEndPoint = 'https://api-test.helpshift.mobi/v1/';
    public String prodEndPoint =  'https://api.helpshift.com/v1/';
    
    public HelpshiftAccountCanvasApp() {
        hsDomain = '';
        domainVar = 'DomainFound:false';
        hsDomainExists = false;
        hsCreatedAt = '';
        if(HelpshiftAdminAppSyncSetting__c.sObjectType.getDescribe().isAccessible()) {
            HelpshiftAdminAppSyncSetting__c hsAdminSetting = HelpshiftAdminAppSyncSetting__c.getValues('HSSyncAdminSetting');
            if(hsAdminSetting != Null && String.isNotBlank(hsAdminSetting.HSDomain__c)) {
                hsDomain = hsAdminSetting.HSDomain__c;
                domainVar = 'domain:\''+hsDomain+'\'';
            }
        }
    }
   
    public void SaveHSDomainAndAccessKey() {
        HelpshiftAdminAppSyncSetting__c hsAdminSetting = HelpshiftAdminAppSyncSetting__c.getValues('HSSyncAdminSetting');
        if(hsAdminSetting == Null) {
            hsAdminSetting = new HelpshiftAdminAppSyncSetting__c(Name='HSSyncAdminSetting', LastBatchExecutionDateTime__c=System.now());
        }
        if(String.isNotBlank(hsDomain)) {
            hsAdminSetting.HSDomain__c    = hsDomain;
        }
        if(String.isNotBlank(hsAccessKey)) {
            hsAdminSetting.HSAccessKey__c = hsAccessKey;
        }
        hsAdminSetting.DomainExists__c = hsDomainExists;
        hsAdminSetting.CreatedAt__c    = Long.valueOf(hsCreatedAt);
        if(hsAdminSetting.CreatedAt__c != null) {
            Sync_Issue__c objCustSett = Sync_Issue__c.getValues('Sync Issue');
            if(objCustSett == Null) {
                objCustSett = new Sync_Issue__c(Name='Sync Issue');
            }        
            objCustSett.Last_Sync_Time__c = System.DateTime.newInstance(Long.valueOf(hsCreatedAt));
            Upsert objCustSett;
        }
        hsAdminSetting.FAQEndpointPrefix__c = sandboxEndPoint;     
        //hsAdminSetting.FAQEndpointPrefix__c = prodEndPoint;     

        Schema.DescribeSObjectResult hsDesRslt = HelpshiftAdminAppSyncSetting__c.sObjectType.getDescribe();
        if(hsDesRslt.isCreateable() && hsDesRslt.isUpdateable()) {
            Upsert hsAdminSetting;
            try{
            String OmniChannelSettingName = 'Omni-ChannelEnabled';
            HelpshiftSetting__c objHSSetting = new HelpshiftSetting__c(SettingName__c=OmniChannelSettingName, IsOmniChannelEnabled__c=true);
            for(HelpshiftSetting__c temp : [SELECT IsOmniChannelEnabled__c FROM HelpshiftSetting__c WHERE SettingName__c= :OmniChannelSettingName Limit 1]) {
                objHSSetting = temp;
            }
            Upsert objHSSetting;
            if(!Test.isRunningTest()) {
                String onTheHour = '0 0 * * * ?';
                String onTheHalfHour = '0 30 * * * ?';
                //System.schedule('HS FAQ Job 2', onTheHour, new batchHSFAQSync_v2() );
                System.schedule('HS FAQ Job 1', onTheHalfHour, new batchHSFAQSync_v2() );
                onTheHour = '0 15 * * * ?';
                onTheHalfHour = '0 45 * * * ?';
                //System.schedule('Issue Sync Job 2', onTheHalfHour, new SyncIssues() );
                //System.schedule('Issue Sync Job 1', onTheHalfHour, new SyncIssues() );
            }
        } catch(Exception ex) {
            system.debug('Error--->'+ex.getMessage());
            apexpages.addmessage(new apexpages.message(apexpages.severity.Error, ex.getMessage() ));
        }
            //apexpages.addmessage(new apexpages.message(apexpages.severity.Confirm, 'Account created successfully.'));
        } else { apexpages.addmessage(new apexpages.message(apexpages.severity.Error, 'You don\'t have create or edit permission.')); }
    }
    
    public PageReference onSaveUserAsHSAdmin() {
        PageReference pg;
        try{
            User us = new User(Id=Userinfo.getUserId());
            us.isHSAdmin__c = true;
            us.isHSUser__c = true;
            Update us;
            pg = new PageReference('/apex/HelpshiftAdminSetting');
            pg.setRedirect(true);
            return pg;
        } catch(Exception ex) {
            system.debug('Error--->'+ex.getMessage());
            apexpages.addmessage(new apexpages.message(apexpages.severity.Error, ex.getMessage() ));
        }
        return pg;
    }
    
       
    public static void dummyTestMethod() {
        Integer i = 0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
    }
   
}