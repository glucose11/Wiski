global class HSAdminSettingClass implements iterable<HelpshiftAdminAppSyncSetting__c>{
   global Iterator<HelpshiftAdminAppSyncSetting__c> Iterator(){
      return new CustomIterable();
   }
}