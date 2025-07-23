/**
 * Invocable to call the zaak api on okapi
 */
public with sharing class OkapiPostZaakInvocable {
    @InvocableMethod(Description='Create a new zaak on the Okapi service (async)' Label='Post Zaken')
    public static void postZaken(List<ZaakModel> zaken) {
        ZaakService.enrichZaakWithFilesByReference(zaken);
        //OkapiClient.upsertZaken(zaken, 'POST');
        sendAsync(JSON.serialize(zaken));
    }
    @Future(Callout=true)
    private static void sendAsync(String serializedZaken) {
        List<ZaakModel> zaken = (List<ZaakModel>) JSON.deserialize(serializedZaken, List<ZaakModel>.class);
        OkapiClient.upsertZaken(zaken, 'POST');
    }
}