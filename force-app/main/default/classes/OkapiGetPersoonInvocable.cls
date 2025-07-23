/**
 * Invocable for the GET Personen
 */
public with sharing class OkapiGetPersoonInvocable {
    @InvocableMethod(Description='Get persons from the Okapi service based on UUID' Label='Get Persons')
    public static List<PersoonModel> getPersons(List<String> uuids) {
        List<PersoonModel> persons = OkapiClient.getPersons(uuids);
        return persons;
    }
}