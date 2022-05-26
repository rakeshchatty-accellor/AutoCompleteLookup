public class GetAddressSuggestionsResponse {
    List<Suggestions> suggestions;
    
    class Suggestions {
        String address;
        String url;
        String id;
    }
}