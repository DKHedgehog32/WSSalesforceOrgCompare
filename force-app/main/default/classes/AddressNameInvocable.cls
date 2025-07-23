//
// Invocable to construct the name for an address records
public class AddressNameInvocable {
    @InvocableMethod(label='Get name based on an address record')
    public static List<String> getAddressNames(List<Address__c> addresses) {
        return AddressService.getNameValues(addresses);
    }
}