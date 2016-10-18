Global with sharing class HS_ConfigureFAQSettings {
    Global static String HS_ConfigureFAQSettings(String KAObj, String Que, String Ans) {
        Try {
            HelpshiftAppFieldMapping__c clsObj = HelpshiftAppFieldMapping__c.getValues('HS FAQ Field Mapping');
            if(clsObj == Null)
                clsObj = new HelpshiftAppFieldMapping__c(Name='HS FAQ Field Mapping');
            if(Que == Ans) {
                HS_credentials.log('Error', 'Question & Answer can not be mapped with same field.');
                return 'Question & Answer can not be mapped with same field.';
            }
            clsObj.SF_KAArticleTypeApiName__c = KAObj;
            clsObj.SFFieldName_For_HSQestion__c = Que;
            clsObj.SFFieldName_For_HSAnswer__c  = Ans;
            if(Schema.sObjectType.HelpshiftAppFieldMapping__c.isCreateable() && Schema.sObjectType.HelpshiftAppFieldMapping__c.isUpdateable()) {       
                Upsert clsObj;
            }  else {HS_credentials.log('Error', 'You don\'t have permission on Custom Setting HelpshiftAppFieldMapping__c.'); }
            return 'success';
        }
        catch (Exception ex) {
            return ex.getMessage();
        }
    }
}