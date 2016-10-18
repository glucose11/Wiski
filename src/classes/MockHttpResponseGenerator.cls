@isTest
public class MockHttpResponseGenerator implements HttpCalloutMock {    
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        
        //-- Issue GET API
        if(req.getEndpoint().endsWith('/issues') &&  req.getMethod() == 'GET'){                        
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"total-pages":1,"total-hits":1,"issues":[{"state_data":{"state":"resolved","changed_at":1453924610054},"assignee_name":"fffffff","domain":"niranja5457","author_name":"test Customer","title":"Test Issue title","created_at":1453924559226,"author_email":"test@customer.com","id":"niranja5457_issue_20160127195559231-1222f37b3bc3855","messages":[{"body":"First issue message","created_at":1453924559244,"author":{"name":"test Customer","id":"niranja5457_profile_20160127195559208-876c354bc6c2676","emails":["test@customer.com"]}},{"body":"test comment 1","created_at":1453924585349,"author":{"name":"fffffff","id":"niranja5457_profile_20160127195359125-91bd543c90f046c","emails":["fffffff@dazeworks.com"]}},{"body":"test comment 2","created_at":1453924595604,"author":{"name":"fffffff","id":"niranja5457_profile_20160127195359125-91bd543c90f046c","emails":["fffffff@dazeworks.com"]}},{"body":"test comment 3","created_at":1453924603146,"author":{"name":"fffffff","id":"niranja5457_profile_20160127195359125-91bd543c90f046c","emails":["fffffff@dazeworks.com"]}},{"body":"test comment 4","created_at":1453924610054,"author":{"name":"fffffff","id":"niranja5457_profile_20160127195359125-91bd543c90f046c","emails":["fffffff@dazeworks.com"]}}],"priority":1,"tags":[]}],"page-size":1000,"page":1}');
            res.setStatusCode(200);            
        }
        //-- Issue PUT API
        if(req.getEndpoint().endsWith('/issues') &&  req.getMethod() == 'PUT'){                        
            res.setHeader('Content-Type', 'application/json');
            /**
             * Please identify what the
             * '/issues/' PUT Verb API call returns and
             * replace the placeholder text
             * with that!
             */
            res.setBody('<INSERT AN EXAMPLE RESPONSE>');
            res.setStatusCode(200);            
        }
        //-- APP GET API
        if(req.getEndpoint().endsWith('/apps') &&  req.getMethod() == 'GET'){                        
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[  {    "id": "hshshs2_app_20160120191138234-392ed7364d03bc6",    "logo": "https://lh3.googleusercontent.com/ZZPdzvlpK9r_Df9C3M7j1rNRi7hhHRvPhlklJ3lfi5jk86Jd1s0Y5wcQ1QgbVaAP5Q=w300",    "platform_ids": [      "hshshs2_platform_20160120191139463-03839614f15d832"    ],    "publish_id": "3",    "title": "Facebook"  }]');
            res.setStatusCode(200);            
        }
        //-- Section GET API
        if(req.getEndpoint().endsWith('/sections') &&  req.getMethod() == 'GET'){                        
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{    "page": 1,    "sections": [        {            "app_id": "hshshs2_app_20160120191138234-392ed7364d03bc6",            "translations": {                "en": {                    "title": "General"                }            },            "title": "General",            "created_at": 1453317098243,            "id": "hshshs2_section_20160120191138244-420139164660782"        },        {            "app_id": "hshshs2_app_20160120191138234-392ed7364d03bc6",            "created_at": 1453317098252,            "id": "hshshs2_section_20160120191138254-8fcc597a535cee6",            "title": "Billing",            "translations": {                "en": {                    "title": "Billing"                }            }        },        {            "app_id": "hshshs2_app_20160120191138234-392ed7364d03bc6",            "translations": {                "en": {                    "title": "Privacy"                }            },            "title": "Privacy",            "created_at": 1453317098263,            "id": "hshshs2_section_20160120191138264-41556dbefe6779c"        },        {            "app_id": "hshshs2_app_20160120191138234-392ed7364d03bc6",            "created_at": 1453317215091,            "id": "hshshs2_section_20160120191335092-73dfa789bb9f3ce",            "title": "Test SA",            "translations": {                "en": {                    "title": "Test SA"                }            }        }    ]}');
            res.setStatusCode(200);            
        }
        //-- User POST API
        if(req.getEndpoint().endsWIth('/agents') &&  req.getMethod() == 'POST'){                        
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{  "existing": null,  "new": [    "adie+ww241@helpshift.com"  ]}');
            res.setStatusCode(200);            
        }
        //-- FAQ POST API
        if(req.getEndpoint().contains('/faqs/') &&  req.getMethod() == 'POST'){                        
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{  "translations": {    "en": {      "title": "Test",      "body": "Test"    }  },  "issue_tags": [],  "id": "hshshs2_faq_20160127190953844-f3ac6fca140a350",  "section_id": "hshshs2_section_20160120191335092-73dfa789bb9f3ce",  "app_id": "hshshs2_app_20160120191138234-392ed7364d03bc6",  "created_at": 1453921793838}');
            res.setStatusCode(200);            
        }
        //-- INTEGRATIONS POST API
        if(req.getEndpoint().contains('/integrations') &&  req.getMethod() == 'POST'){                        
            res.setHeader('Content-Type', 'application/json');
            /**
             * Please identify what the
             * '/integrations' POST Verb API call returns and
             * replace the placeholder text
             * with that!
             */
            res.setBody('<INSERT AN EXAMPLE RESPONSE>');
            res.setStatusCode(200);            
        }
        //-- Agents GET
        if(req.getEndpoint().contains('/agents') &&  req.getMethod() == 'GET'){                        
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"page" : 1, "page_size" : 100, "profiles" : [{"id" : "dazeworks3_profile_20160831183545534-12525d16308cf6f", "name" : "Dazeworks", "email" : "dazeworks@helpshift.com", "avatar" : "https://randomuser.me/api/portraits/men/86.jpg"}, {"id" : "niranja5457_profile_20160127195559208-876c354bc6c2676", "name" : "Niranja", "email" : "niranja@helpshift.com", "avatar" : "https://randomuser.me/api/portraits/women/79.jpg"} ], "total_profiles" : 2, "total_pages" : 1}');
            res.setStatusCode(200);            
        }
        //-- Agents DELETE
        if(req.getEndpoint().contains('/agents/') &&  req.getMethod() == 'DELETE'){                        
            res.setHeader('Content-Type', 'application/json');
            /**
             * Please identify what the
             * '/agents' DELETE Verb API call returns and
             * replace the placeholder text
             * with that!
             */
            res.setBody('<INSERT AN EXAMPLE RESPONSE>');
            res.setStatusCode(200);            
        }
        //-- Agents POST
        if(req.getEndpoint().contains('/agents') &&  req.getMethod() == 'POST'){                        
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"status": "ok", "email": "dazeworks@helpshift.com", "id": "dazeworks3_profile_20160831183545534-12525d16308cf6f"}, {"status": "ok", "email": "niranja@helpshift.com", "id": "niranja5457_profile_20160127195559208-876c354bc6c2676"}]');
            res.setStatusCode(201);            
        }
        
        return res;
    }
}