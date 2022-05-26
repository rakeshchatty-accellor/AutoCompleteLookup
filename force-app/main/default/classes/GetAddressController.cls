public class GetAddressController {
    private static final String ID_PREFIX_ACCOUNT = Account.getSObjectType().getDescribe().getKeyPrefix();
    private static final String ID_PREFIX_CONTACT = Contact.getSObjectType().getDescribe().getKeyPrefix();
    private static final String ID_PREFIX_LEAD = Lead.getSObjectType().getDescribe().getKeyPrefix();
    
    @AuraEnabled
    public static Map<String, String> getTypeOfAddress(String recordId){
        Map<String, String> options = new Map<String, String>();
        try {
            if (recordId.startsWith(ID_PREFIX_ACCOUNT)) {
                options.put('Billing Address','BillingAddress');
                options.put('Shipping Address','ShippingAddress');
                
                Account account = [SELECT IsPersonAccount FROM Account WHERE Id = :recordId];
                if (account.IsPersonAccount) {
                    options.put('Person Mailing Address','PersonMailingAddress');
                    options.put('Person Other Address','PersonOtherAddress');
                }
            } 
            if (recordId.startsWith(ID_PREFIX_CONTACT)) {
                options.put('Mailing Address','MailingAddress');
                options.put('Other Address','OtherAddress');
            } 
            return options;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getAddresses(String searchValue) {
        if (searchValue == null) {
            return null;
        }

        GetAddressService services = new GetAddressService();
        try {
            return JSON.serialize(services.suggestions(searchValue));
        } catch(ApiException e) {
			throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void setAddresses(Id recordId, String url, List<String> addressFields) {
        if (recordId == null || url == null) {
            return;
        }
        
        GetAddressService services = new GetAddressService();
        try {
            services.setAddress(recordId, url, addressFields);
        } catch(ApiException e) {
			throw new AuraHandledException(e.getMessage());
        }
    }
}