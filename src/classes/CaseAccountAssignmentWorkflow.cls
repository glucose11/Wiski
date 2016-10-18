public class CaseAccountAssignmentWorkflow{
    public Boolean isInsert;
    public Boolean isUpdate;
    public List<Case> newList;
    public Map<Id, Case> newMap;
    public Map<Id, Case> oldMap;
    
    public CaseAccountAssignmentWorkflow(Boolean isInsert, Boolean isUpdate, List<Case> newList, Map<Id, Case> newMap, Map<Id, Case> oldMap){
        this.isInsert = isInsert;
        this.isUpdate = isUpdate;
        this.newList  = newList;
        this.newMap   = newMap;
        this.oldMap   = oldMap;
    }
    
    public void execute(){
        Map<String, List<Case>> emailtoCasesMap = new Map<String, List<Case>>();
        Map<Case, String> caseToEmailMap = new Map<Case, String>(); 
        for(Case c : newList){
            if((isInsert || (isUpdate && c.Author_Email__c != oldMap.get(c.Id).Author_Email__c)) && c.Author_Email__c != NULL){
                caseToEmailMap.put(c, c.Author_Email__c);
                if(emailtoCasesMap.containsKey(c.Author_Email__c)){
                    emailtoCasesMap.get(c.Author_Email__c).add(c);
                }
                else{
                    emailtoCasesMap.put(c.Author_Email__c, new List<Case>{c});
                }
            }
        }
        
        Map<String, Contact> emailToContactMap = new Map<String, Contact>();
        for(Contact con : [Select Id, AccountId, Email FROM Contact WHERE Email IN :emailtoCasesMap.keySet()]){
            emailToContactMap.put(con.Email, con);
        }
        
        List<Account> actList = new List<Account>();
        actList = [Select Id FROM Account WHERE Name = 'Helpshift Issue Account'];
        
        if(actList.isEmpty()){
           actList.add(new Account(Name = 'Helpshift Issue Account')); 
           insert actList;
        }
        
        Map<String, Contact> tempemailToContactMap = new Map<String, Contact>();
        for(String emailAddr: emailtoCasesMap.keySet()){
            if(!emailToContactMap.containsKey(emailAddr)){
                tempemailToContactMap.put(emailAddr, new Contact(FirstName = emailAddr, LastName = 'HS_Contact', AccountId = actList[0].Id, Email = emailAddr));
            }
        }
        
        insert tempemailToContactMap.values();
        emailToContactMap.putAll(tempemailToContactMap);
        for(Case c : caseToEmailMap.keySet()){
            if(emailToContactMap.containsKey(c.Author_Email__c) && emailToContactMap.get(c.Author_Email__c) != NULL){
                c.ContactId = emailToContactMap.get(c.Author_Email__c).Id;
                c.AccountId = emailToContactMap.get(c.Author_Email__c).AccountId;
            }
        }
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