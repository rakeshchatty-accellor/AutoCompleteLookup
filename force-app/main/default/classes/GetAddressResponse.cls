public class GetAddressResponse {
    public String postcode;
    public Decimal latitude;
    public Decimal longitude;
    public List<String> formatted_address;
    public String thoroughfare;
    public String building_name;
    public String sub_building_name;
    public String sub_building_number;
    public String building_number;
    public String line_1;
    public String line_2;
    public String line_3;
    public String line_4;
    public String locality;
    public String town_or_city;
    public String county;
    public String district;
    public String country;
    public String residential;
    public String street {
		get {
            String formatedAddress;
            if (line_1 != '') {
                formatedAddress = line_1;
            }
            if (line_2 != '') {
                formatedAddress += '\n'+line_2;
            }
            
            if (line_3 != '') {
                formatedAddress += '\n'+line_3;
            }
            
            if (line_4 != '') {
                formatedAddress += '\n'+line_4;
            }
            return formatedAddress; 
        }
    }
}