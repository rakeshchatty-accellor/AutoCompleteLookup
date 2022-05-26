public class GetAddressApiEndpoint extends Rest {

    private transient GetAddressSettings__c getAddressSettings = GetAddressSettings__c.getOrgDefaults();

    public GetAddressApiEndpoint() {
        calloutName = 'GetAddressApi';
    }

    public GetAddressSuggestionsResponse getSuggestions(String searchValue) {
         String endpoint = '/autocomplete/'
         + searchValue.replace(' ', '%20')
         + '?api-key=' + getAddressSettings.Apikey__c
         + '&top=' + getAddressSettings.Count__c
         + '&all=true';
        return (GetAddressSuggestionsResponse) invoke('GET', endpoint, null, GetAddressSuggestionsResponse.class);
    }
     public GetAddressResponse lookup(String url) {
        String endpoint = url + '?api-key=' + getAddressSettings.Apikey__c;
        return (GetAddressResponse) invoke('GET', endpoint, null, GetAddressResponse.class);
    }
}