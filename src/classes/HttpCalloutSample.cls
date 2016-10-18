public class HttpCalloutSample {

  // Pass in the endpoint to be used using the string url
  public String getCalloutResponseContents() {

    // Instantiate a new http object
    Http h = new Http();
    String bodyRes = '';

     // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
    HttpRequest req = new HttpRequest();
    req.setEndpoint('https://d.la10.salesforceliveagent.com/chat/rest/System/SessionId');
    req.setMethod('GET');
    req.setHeader('X-LIVEAGENT-API-VERSION','36');
    req.setHeader('X-LIVEAGENT-AFFINITY', '');
    
    
    try{
        HttpResponse res = h.send(req);
        bodyRes = res.getBody();
        System.debug('[Client] Get Session id=============' + bodyRes);
        return bodyRes;
        }catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage()));
            return null;
        }
        
    
    
  }
}