public without sharing class DetailRecordController {
    
    //getter and setters
    
    /*public string name;
    public string ssn;
    public string email;
    public string phoneNumber;
    public string address;
     Select a.ShippingStreet, a.ShippingState, a.ShippingPostalCode, a.ShippingCountry, a.ShippingCity, a.Phone, a.Name From Account a
    
    */
    
    public Account personAccount{get;set;}
    
    // constructor
    public DetailRecordController(){
    	personAccount = new Account(); 
    	
    	
    }
    
    
    
    
}