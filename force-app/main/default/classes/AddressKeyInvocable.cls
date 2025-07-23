//
// Invocable to get an address key
public class AddressKeyInvocable {
    @InvocableMethod(label='Get unique key based on an address record')
    public static List<String> getAddressKeys(List<Address__c> addresses) {
        return AddressService.getAddressKeys(addresses);
    }
}