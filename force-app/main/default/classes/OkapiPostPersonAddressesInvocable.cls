/**
 * Invocable for the POST person addresses
 */
public with sharing class OkapiPostPersonAddressesInvocable {
    @InvocableMethod(Description='Create person addresses on the Okapi service' Label='Post Person Addresses')
    public static void postPersonAddresses(List<PersoonAdresModel> personAddresses) {
        OkapiClient.upsertPersonAddresses(personAddresses, 'POST');
    }
}