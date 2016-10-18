public class json2IssueWr {

    public class State_data {
        //public String states;
        public Long changed_at;
    }

    public class Messages {
        public String body;
        public Long created_at;
        public Author author;
    }

    public Integer total_pages;
    public Integer total_hits;
    public List<Issues> issues;
    public Integer page_size;
    public Integer page;

    public class Issues {
        //public List<Tags> tags;
        public String IssueOrAuthorId;
        public String assignee_name;
        public String title;
        public List<Messages> messages;
        public Integer priority;
        public String author_name;
        public String author_email;
        public String domain;
        public State_data state_data;
        public Long created_at;
    }

    public class Author {
        public String name;
        public String IssueOrAuthorId;
        public List<String> emails;
    }

    public class Tags {
    }

    
    public static json2IssueWr parse(String json) {
        return (json2IssueWr) System.JSON.deserialize(json, json2IssueWr.class);
    }
    
 
}