public with sharing class GetRecordId {
    public GetRecordId() {

    }

    @AuraEnabled(cacheable = true)
    public static List<Report> getReport() {
        return [SELECT Id, Name FROM Report WHERE Name = 'Program Enrollments by Program' ORDER BY LastModifiedDate DESC NULLS LAST LIMIT 1];
    }

    @AuraEnabled(cacheable = true)
    public static List<Referral> getReferral() {
        return [SELECT Id, Name FROM Referral WHERE Name = 'REF-0000000011' ORDER BY LastModifiedDate DESC NULLS LAST LIMIT 1];
    }
    
    @AuraEnabled(cacheable = true)
    public static List<Case> getCase() {
        return [SELECT Id, CaseNumber FROM Case WHERE CaseNumber = '00001022' ORDER BY LastModifiedDate DESC NULLS LAST LIMIT 1];
    }

}