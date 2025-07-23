/**
 * Invocable to have persons pushed to SF
 */
public inherited sharing class FetchPersonenInvocable {
    @InvocableMethod(label='Request a Persoon from Okapi' description='Requests Okapi to push a persoon to Salesforce based on their External or UUID')
    public static List<OkapiResponseModel> fetchPersonen(List<PersoonModel> personen) {
        return OkapiClient.requestPersonsPush(personen);
    }
}