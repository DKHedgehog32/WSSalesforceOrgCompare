/**
 * Created by harm on 07/02/2025.
 */

global class InformatieObjectModel {
    @AuraEnabled @InvocableVariable
    global String id;
    @AuraEnabled @InvocableVariable
    global String beschrijving;
    @AuraEnabled @InvocableVariable
    global String bestand; // base-64
    @AuraEnabled @InvocableVariable
    global String bestandslocatie; // URI for remote file; alternative to this.bestand

    // See https://www.iana.org/assignments/media-types/media-types.xhtml, for Salesforce a simplified list is available, allowing us to map contenttype
    // from the contentdocument. Salesforce has no mime-type. Okapi does the conversion
    @AuraEnabled @InvocableVariable
    global String formaat;
}