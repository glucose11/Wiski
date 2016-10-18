public class HttpCalloutSampleFinal {

  // Pass in the endpoint to be used using the string url
  public static void getCalloutResponseContents() {

    // Instantiate a new http object
    Http h = new Http();
    String bodyRes = '';
    String key = '';
    String affnityToken;

     // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
    HttpRequest req = new HttpRequest();
    req.setEndpoint('https://d.la10.salesforceliveagent.com/chat/rest/System/SessionId');
    req.setMethod('GET');
    req.setHeader('X-LIVEAGENT-API-VERSION','30');
    req.setHeader('X-LIVEAGENT-AFFINITY', 'null');
    string sessionid ='';
    
    try{
        HttpResponse res = h.send(req);
        bodyRes = res.getBody();
        System.debug('[Client] Get Session id=============' + bodyRes);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(bodyRes);
        sessionid = (String)m.get('id');
        key = (String)m.get('key');
        affnityToken = (String)m.get('affinityToken');
        System.debug('key>>> ' + key) ;
        }catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage()));
           /// return null;
        }
        
        
        HttpRequest req1 = new HttpRequest();
        req1.SetEndPoint('https://d.la10.salesforceliveagent.com/chat/rest/Chasitor/ChasitorInit'); 
        req1.setMethod('POST');
        req1.setHeader('X-LIVEAGENT-API-VERSION','30');
        req1.setHeader('X-LIVEAGENT-SESSION-KEY', key);
        req1.setHeader('X-LIVEAGENT-AFFINITY', affnityToken);
        req1.setHeader('X-LIVEAGENT-SEQUENCE', '0');
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('organizationId', '00D28000001jQIU');
        gen.writeStringField('deploymentId', '57228000000L2JS');
        gen.writeStringField('buttonId', '573280000004FwI');
        gen.writeBooleanField('doFallback', true);
        gen.writeStringField('sessionId', sessionid);
        gen.writeStringField('userAgent', 'Mozilla/5.0 (Macintosh; Intel Mac (KHTML, like Gecko) Chrome/28.0.1500.95 Safari/537.36');
        gen.writeStringField('language', 'en-US');
        gen.writeStringField('screenResolution', '1366x768');
        gen.writeStringField('visitorName', 'KAPIL TILWANI');
        gen.writeFieldName('prechatDetails');
        gen.writeStartArray();
        gen.writeEndArray();
        gen.writeFieldName('prechatEntities');
        gen.writeStartArray();
        gen.writeEndArray();
        gen.writeBooleanField('receiveQueueUpdates', true);
        gen.writeBooleanField('isPost', true);
        gen.writeEndObject();
        
        
        String sendMsg = gen.getAsString();
        System.debug('sendMsg in json==============' + sendMsg);
       // System.assert(false,sendMsg);
        req1.setBody(sendMsg);

        try {
            HttpResponse resx = h.send(req1);
            bodyRes = resx.getBody();System.debug('bodyRes==============' + bodyRes);            
        } catch (System.CalloutException e) {
            System.debug('Callout error: '+ e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage()));
        }
  }
}