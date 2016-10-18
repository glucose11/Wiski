public without sharing class DomainChangeUrlPrototypeController {
	
	
	
	// getter and setters
	
	public string domainUrl{get;set;} 
	
	
	// constructor
	
	public DomainChangeUrlPrototypeController(){
		
	}
	
	
	
	public void changeTheDomainName(){
		
		
		string address = domainUrl;
		string content = 'wjfwjdfkwdjfkdjkfj <a href="/root/test.html" />';
		Url addressUri = new URL(address);
	   //finds all link atributes (href, src, etc.)
	   Pattern urlpattern = Pattern.compile('(href|src|action|background)=\"[^\"]*\"');
	   Matcher m = urlpattern.matcher(content);
	   //determines if the link is allready absolute
	   Pattern absoluteLinkPattern = Pattern.compile('[a-z]+://.+');
	   //buffer for result saving
	   String buffer = '';
	   //position from where should next interation take content to append to buffer
	   integer lastEnd = 0;
	   while(m.find()){
	       //position of link in quotes
	       integer startPos = content.indexOf('"',m.start())+1;
	       integer endPos = m.end()-1;
	       String link = content.substring(startPos,endPos);
	       System.debug('Link :' + link);
	       Matcher absoluteMatcher = absoluteLinkPattern.matcher(link);
	       //is the link relative?
	       if(!absoluteMatcher.find())
	       {
	           //create relative URL
	           Url tmpUri = new Url(addressUri.getProtocol(),addressUri.getHost(),link);
	           //append the string between links
	           buffer += '' + (content.substring(lastEnd,startPos-1));
	           //append new link
	           buffer += '"' +(tmpUri.toExternalForm()) + '"';
	           lastEnd =endPos+1;
	           System.debug('buffer '+ buffer);
	       }
	   }
	   //append the end of file
	   buffer+= '' +(content.substring(lastEnd));
       System.debug(buffer);
       
       //System.debug()
		
		
		Apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.CONFIRM,'Knowledge article Url Updated . Awesome Helpshift!!!!');
        Apexpages.addmessage(msg);
		
	}
	
	
	
	public void printURLs(){
		
		/*Set<String> hrefUrls = new Set<String>();
		for(Public_Article__kav ps : [SELECT Article_Body__c 
                              FROM Public_Article__kav 
                              WHERE PublishStatus='online' 
                              AND language ='en_US'
                              LIMIT 100]){
                              	
               Pattern urlpattern = Pattern.compile('(href)=\"[^\"]*\"');
			   if(ps.Article_Body__c != null){
			   	   Matcher m = urlpattern.matcher(ps.Article_Body__c);
				   //determines if the link is allready absolute
				   Pattern absoluteLinkPattern = Pattern.compile('[a-z]+://.+');
				   //buffer for result saving
				   String buffer = '';
				   //position from where should next interation take content to append to buffer
				   integer lastEnd = 0;
				   while(m.find()){
				       //position of link in quotes
				       integer startPos = content.indexOf('"',m.start())+1;
				       integer endPos = m.end()-1;
				       String link = content.substring(startPos,endPos);
				       hrefUrls.add(link);
		                   	
				   }
			   }
			            	
    
			}
		
		
		
		*/
		
		
		
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
    
}
