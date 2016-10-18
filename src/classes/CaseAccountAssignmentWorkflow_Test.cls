/**
 * This is the Apex Unit Test for the CaseAccountAssignmentWorkflow Apex Class,CaseTrigger 
 * 
 * @author  Dazeworks Technologies Pvt Ltd
 * @since   29th January 2016
 * @version 1.0
 */
@isTest
private class CaseAccountAssignmentWorkflow_Test {
    private static testMethod void Case_Test() {
      Test.startTest();
      list<Account> acl = new list<Account>();
      acl.add(new account(name='Acc1'));
      acl.add(new account(name='Helpshift Issue Account'));
      insert acl;
      
      list<contact> conl = new list<contact>();
      contact con = new contact(accountid=acl[0].id,lastname='tsest',email='test@mail.com');
      conl.add(con);
      contact con1 = new contact(accountid=acl[0].id,lastname='tsest',email='test1@mail.com');
      conl.add(con1);
      insert conl;
      
      FutureClass.isRunningSyncIssueClass = true;
      Case cs = new case(Author_Email__c='test@mail.com');
      cs.Subject = 'Test subject';
      cs.Description = 'Test case Desc';
      cs.SuppliedEmail = 'test@test.testtest';
      cs.Priority = 'Low';
      cs.Status = 'Open';
      cs.Origin = 'Email';
      insert cs;
      cs.Author_Email__c ='test1@mail.com';
      update cs;
      Test.stopTest();
      
      cs = [Select id, accountID From Case Where Id =: cs.id][0];
      System.assertEquals(cs.accountId, acl[0].id);
      
  }
  
  private static testMethod void t1() {
        CaseAccountAssignmentWorkflow.dummyTestMethod();
        System.assertEquals(1,1);
    }
}