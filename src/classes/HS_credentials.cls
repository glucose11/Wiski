public with sharing class HS_credentials {
    public static String hsConsumerKey  {get; set;}
    public static String hsSecretKey    {get; set;}
    public static String hsAccessKey    {get; set;}
    public static String hsApiUrlPrefix {get; set;}
    public static String hsDomain       {get; set;}
    public static String sfObject       {get; set;}
    public static String sfQue          {get; set;}
    public static String sfAns          {get; set;}
    
    public static String selectedHSAppId       {get; set;}
    public static String selectedHSSectionId   {get; set;}

    static {
        HelpshiftAdminAppSyncSetting__c hsAdminSetting = HelpshiftAdminAppSyncSetting__c.getValues('HSSyncAdminSetting');
        if(hsAdminSetting != Null) {
            hsDomain = hsAdminSetting.HSDomain__c;
            hsApiUrlPrefix = hsAdminSetting.FAQEndpointPrefix__c + hsAdminSetting.HSDomain__c;
            hsAccessKey = EncodingUtil.base64Encode(Blob.valueOf(hsAdminSetting.HSAccessKey__c + ':'));
        }
        
        HelpshiftAppFieldMapping__c fldSettingFAQ = HelpshiftAppFieldMapping__c.getValues('HS FAQ Field Mapping');
        if(fldSettingFAQ != Null) {
            sfObject = fldSettingFAQ.SF_KAArticleTypeApiName__c;
            sfQue = fldSettingFAQ.SFFieldName_For_HSQestion__c;
            sfAns = fldSettingFAQ.SFFieldName_For_HSAnswer__c; 
        }
    }
    
    public static HttpResponse makeApiCall(String type, String endUrlPostFix, String postBody) {
        http h = new http();
        httpRequest req = new HttpRequest();
        if(type == 'POST' || type == 'PUT') {
            req.setMethod(type);
            req.setBody(postBody);
        }
        else {
            req.setMethod('GET');
        }
        req.setEndPoint(hsApiUrlPrefix + endUrlPostFix);
        req.setTimeout(20000);
        req.setHeader('Authorization', 'Basic ' + hsAccessKey);  
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');  
        System.debug(req.getBody());
        System.debug(req);
        //System.debug('Request Body : ' + postBody);
        //System.debug('Request Endpoint : ' + hsApiUrlPrefix + endUrlPostFix);
        //System.debug('Request Auth : ' + 'Basic ' + hsAccessKey);
        httpResponse resp;
        System.debug(LoggingLevel.Error, 'Ignore Error keyword. Req: '+ req);
        resp = h.send(req);
        
        System.debug(resp.getStatusCode());
        System.debug(LoggingLevel.Error, 'Ignore Error keyword. Response: '+resp.getBody());
        return resp;
    }
    
    public static void log(String Type, String msg) {
        System.debug(LoggingLevel.Error, msg);
        Type = Type.toLowerCase();
        ApexPages.Severity msgType;
        if(Type=='info') { msgType = ApexPages.Severity.Info; }
        else if(Type=='error') { msgType = ApexPages.Severity.Error; }
        else if(Type=='confirm') { msgType = ApexPages.Severity.Confirm; }
        else { msgType = ApexPages.Severity.Warning; }
        ApexPages.addMessage(new ApexPages.Message(msgType, msg));
    }
    
}