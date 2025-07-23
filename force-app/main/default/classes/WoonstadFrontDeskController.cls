public with sharing class WoonstadFrontDeskController {
    /**
     * Creates a new Case based on visitor input.
     *
     * @param firstName    Visitor's first name
     * @param lastName     Visitor's last name
     * @param contactInfo  Phone or email input
     * @param visitReason  Reason selected from picklist
     * @param notes        Optional visitor comments
     */
    @AuraEnabled
    public static void registerVisitor(
        String firstName,
        String lastName,
        String contactInfo,
        String visitReason,
        String notes
    ) {
        Case caseRecord = new Case();
        caseRecord.Origin = 'Experience Cloud';
        caseRecord.Status = 'New';
        caseRecord.Subject = 'Aanmelding balie - ' + visitReason;
        caseRecord.SuppliedName = firstName + ' ' + lastName;
        caseRecord.SuppliedPhone = contactInfo;
        caseRecord.Reason = visitReason;
        caseRecord.Description = notes;

        insert caseRecord;
    }
}