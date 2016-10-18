public without sharing class ChangeTheUrlDomain {
    
   //getter and setters
   public FAQ__kav faqArticle{get;set;} 
   
   //constructor
   public ChangeTheUrlDomain(){
   	
   	faqArticle  = new FAQ__kav();
   	changeDomainOfURL();
   	
   }
   
   // query the knowledge articles
   public void changeDomainOfURL(){
   	
   	for(FAQ__kav fa  : [SELECT Title , Answer__c 
    					FROM FAQ__kav 
    					WHERE  language='en_US'  and publishstatus='online' LIMIT 1]){
    	
    	faqArticle = fa;
    	
    }
   	
   	
   	
   	
   	
   	
   	
   }
   
    
    
    
    
    
}