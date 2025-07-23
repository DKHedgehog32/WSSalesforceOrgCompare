/**
 * Invocable for the POST Persoonrelaties
 */
public with sharing class OkapiPostPersonRelationsInvocable {
    @InvocableMethod(Description='Create person relations on the Okapi service' Label='Post Person Relations')
    public static void postPersonRelations(List<PersoonRelatieModel> relaties) {
        OkapiClient.upsertPersoonRelaties(relaties, 'POST');
    }
}