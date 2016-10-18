global class CustomIterable implements Iterator<HelpshiftAdminAppSyncSetting__c> { 

   List<HelpshiftAdminAppSyncSetting__c> hsCredentialsList {get; set;}
   Integer i {get; set;}
 
   public CustomIterable(){ 
       hsCredentialsList = new List<HelpshiftAdminAppSyncSetting__c>();
       HelpshiftAdminAppSyncSetting__c hsCredentials =  HelpshiftAdminAppSyncSetting__c.getValues('HSSyncAdminSetting');
       if(hsCredentials != Null)  {
           hsCredentialsList.add(hsCredentials);
       }
       i = 0;
       System.debug(hsCredentialsList);
   }   

   global boolean hasNext(){ 
       System.debug(hsCredentialsList );
       if(hsCredentialsList != Null && i==0) 
           return true; 
       else 
           return false; 
       
   }    

   global HelpshiftAdminAppSyncSetting__c next(){
       System.debug(hsCredentialsList);
       if(hsCredentialsList != null && !hsCredentialsList.isEmpty() && i==0) {
           i++;
           return hsCredentialsList[0];
       }
       
       hsCredentialsList = null; 
       return null; 
   } 
}