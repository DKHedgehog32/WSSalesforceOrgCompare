/**
 * Created by harm on 10/02/2025.
 */

global class ZaakSoortAttribuutModel {
    @AuraEnabled @InvocableVariable
    global BetalingsregelingModel betalingsregeling;
    @AuraEnabled @InvocableVariable
    global SocialeMeldingModel socialeMelding;
    @AuraEnabled @InvocableVariable
    global NaamplaatjeModel naamplaatje;

    public static ZaakSoortAttribuutModel getMock() {
        ZaakSoortAttribuutModel model = new ZaakSoortAttribuutModel();
        return model;
    }
}