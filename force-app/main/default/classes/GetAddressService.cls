public class GetAddressService {
    private static final String ID_PREFIX_ACCOUNT = Account.getSObjectType().getDescribe().getKeyPrefix();
    private static final String ID_PREFIX_CONTACT = Contact.getSObjectType().getDescribe().getKeyPrefix();
    private static final String ID_PREFIX_LEAD = Lead.getSObjectType().getDescribe().getKeyPrefix();
    
    public GetAddressSuggestionsResponse suggestions(String searchValue) {        
        try {
            return new GetAddressApiEndpoint().getSuggestions(searchValue); 
        } catch (ApiException e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public void setAddress(String recordId, String url, List<String> addressFields) {
        try { 
            GetAddressResponse response = (GetAddressResponse) new GetAddressApiEndpoint().lookup(url);

            Account acc = new Account();
            if (recordId.startsWith(ID_PREFIX_ACCOUNT)) {
                acc.Id = recordId;
				if (addressFields.contains('BillingAddress')){
                    acc.BillingStreet = response.street;                
                    acc.BillingState = response.county;
                    acc.BillingCity = response.town_or_city;
                    acc.BillingCountry = response.country;
                    acc.BillingPostalCode = response.postcode;
                    acc.BillingLatitude = response.Latitude;
                    acc.BillingLongitude = response.Longitude;
                }

                if (addressFields.contains('ShippingAddress')) {
                    acc.ShippingStreet = response.street;
                    acc.ShippingState = response.county;
                    acc.ShippingCity = response.town_or_city;
                    acc.ShippingCountry = response.country;
                    acc.ShippingPostalCode = response.postcode;
                    acc.ShippingLatitude = response.Latitude;
                    acc.ShippingLongitude = response.Longitude;
                }

                if (addressFields.contains('PersonMailingAddress')) {
                    acc.PersonMailingStreet = response.street;
                    acc.PersonMailingState = response.county;
                    acc.PersonMailingCity = response.town_or_city;
                    acc.PersonMailingCountry = response.country;
                    acc.PersonMailingPostalCode = response.postcode;
                    acc.PersonMailingLatitude = response.Latitude;
                    acc.PersonMailingLongitude = response.Longitude;
                }

                if (addressFields.contains('PersonOtherAddress')) {
                    acc.PersonOtherStreet= response.street;
                    acc.PersonOtherState = response.county;
                    acc.PersonOtherCity = response.town_or_city;
                    acc.PersonOtherCountry = response.country;
                    acc.PersonOtherPostalCode = response.postcode;
                    acc.PersonOtherLatitude = response.Latitude;
                    acc.PersonOtherLongitude =response.Longitude;
                }
                UPDATE acc;
                
            } else if (recordId.startsWith(ID_PREFIX_CONTACT)) {
                Contact con = new Contact();
                con.Id = recordId;
                if (addressFields.contains('MailingAddress')) {
                    con.MailingStreet = response.street;
                    con.MailingState = response.county;
                    con.MailingCity = response.town_or_city;
                    con.MailingCountry = response.country;
                    con.MailingPostalCode = response.postcode;
                    con.MailingLatitude = response.Latitude;
                    con.MailingLongitude = response.Longitude;
                }

                if (addressFields.contains('OtherAddress')) {
                    con.OtherStreet = response.street;
                    con.OtherState = response.county;
                    con.OtherCity = response.town_or_city;
                    con.OtherCountry = response.country;
                    con.OtherPostalCode = response.postcode;
                    con.OtherLatitude = response.Latitude;
                    con.OtherLongitude = response.Longitude;
                }
                UPDATE con;

            } else if (recordId.startsWith(ID_PREFIX_LEAD)) {
                Lead lead = new Lead();
                lead.Id = recordId;
                lead.Street = response.street;
                lead.State = response.county;
                lead.City = response.town_or_city;
                lead.Country = response.country;
                lead.PostalCode = response.postcode;
                lead.Latitude = response.Latitude;
                lead.Longitude = response.Longitude;
                UPDATE lead;
            } else {
                throw new AuraHandledException(Label.MsgUnsupportedObjectAddressLookUp);
            }
        } catch (ApiException e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}