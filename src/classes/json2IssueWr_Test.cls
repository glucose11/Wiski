@isTest
private class json2IssueWr_Test {

  private static testMethod void json2IssueWr_Test() {
      String jsonIssueStr = '{"total-pages":1,"total-hits":1,"issues":[{"state_data":{"state":"resolved","changed_at":1453924610054},"assignee_name":"fffffff","domain":"niranja5457","author_name":"test Customer","title":"Test Issue title","created_at":1453924559226,"author_email":"test@customer.com","id":"niranja5457_issue_20160127195559231-1222f37b3bc3855","messages":[{"body":"First issue message","created_at":1453924559244,"author":{"name":"test Customer","id":"niranja5457_profile_20160127195559208-876c354bc6c2676","emails":["test@customer.com"]}},{"body":"test comment 1","created_at":1453924585349,"author":{"name":"fffffff","id":"niranja5457_profile_20160127195359125-91bd543c90f046c","emails":["fffffff@dazeworks.com"]}},{"body":"test comment 2","created_at":1453924595604,"author":{"name":"fffffff","id":"niranja5457_profile_20160127195359125-91bd543c90f046c","emails":["fffffff@dazeworks.com"]}},{"body":"test comment 3","created_at":1453924603146,"author":{"name":"fffffff","id":"niranja5457_profile_20160127195359125-91bd543c90f046c","emails":["fffffff@dazeworks.com"]}},{"body":"test comment 4","created_at":1453924610054,"author":{"name":"fffffff","id":"niranja5457_profile_20160127195359125-91bd543c90f046c","emails":["fffffff@dazeworks.com"]}}],"priority":1,"tags":[]}],"page-size":1000,"page":1}';
      jsonIssueStr = jsonIssueStr.replace('"id"', '"IssueOrAuthorId"').replace('"state"', '"st"');
      Test.startTest();
          json2IssueWr clsObj = json2IssueWr.parse(jsonIssueStr);
          System.assertNotEquals(clsObj.page, Null);
      Test.stopTest();
      
  }

}