public with Sharing Class HelpshiftOmniChannelSetting {
    private String OmniChannelSettingName = 'Omni-ChannelEnabled';
    public String omniMessage {get; set;}
    public HelpshiftSetting__c objHSSetting {get; set;}
    public HelpshiftOmniChannelSetting() {
        objHSSetting = new HelpshiftSetting__c(SettingName__c=OmniChannelSettingName);
        for(HelpshiftSetting__c temp : [SELECT IsOmniChannelEnabled__c FROM HelpshiftSetting__c WHERE SettingName__c= :OmniChannelSettingName Limit 1]) {
            objHSSetting = temp;
        }
        omniMessage = '';
    }
    
    public void SaveSetting() {
        makeHSApiCallForOmniChannelChange(objHSSetting.IsOmniChannelEnabled__c);
        objHSSetting.SettingName__c = OmniChannelSettingName;
        Upsert objHSSetting;
        omniMessage = 'Save successful.';
    }
    
    
    private HttpResponse makeHSApiCallForOmniChannelChange(Boolean isEnabled) {
        omniMessage = '';

        String status = 'false';
        if(isEnabled) 
            status = 'true';                                                                                                       
        HttpResponse resp = HS_credentials.makeApiCall('POST', '/integrations', 'username='+EncodingUtil.urlDecode(Userinfo.getUserName(), 'UTF-8')+'&status=false&email='+EncodingUtil.urlDecode(Userinfo.getUserEmail(), 'UTF-8')+'&type=omni'); // '{"type":"omni","status":'+ status + ',"email":"'+'sam55%40dazeworks.com'+'","username":"'+'niranja1%40dazeworks.com'+'"}');
        return resp;
    }
}