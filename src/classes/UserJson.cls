public class UserJson {
    public Integer page;
    public Integer page_size;
    public List<Profiles> profiles;
    public Integer total_profiles;
    public Integer total_pages;

    public class Profiles {
        public String id;
        public String name;
        public String email;
        public String avatar;
    }
}