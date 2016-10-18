public with sharing class SA_Test {
    public string s {get; set;}
    public string h {get; set;}
    public WR_Data data {get; set;}
    public SA_Test() {
        s = apexpages.currentpage().getparameters().get('signed_request');
        h = apexpages.currentpage().getHeaders().get('signed_request');
        System.debug(apexpages.currentpage().getparameters());
        
        
        
String r = '{"type": "moby.core.exceptions/can-not-be-reassigned","status": 400,"msg": "Can not Reassign Issue <issue ID>","data": {"issue-id": "sadsasd"}}';
SA_Test DataResp = (SA_Test ) JSON.deserialize(r.replace('issue-id', 'issue_id'), SA_Test .class);
System.debug(LoggingLevel.Error, DataResp);



        System.debug(s);
        System.debug(h);
    
    }
    
    
class WR_Data {
        public String issue_id {get;set;}
}

}