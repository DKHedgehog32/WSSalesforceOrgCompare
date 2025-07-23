public with sharing class ExistingDossierService {

    public class AddressSearchRequest {
        @InvocableVariable public String street;
        @InvocableVariable public String houseNumber;
        @InvocableVariable public String postalCode;
        @InvocableVariable public String birthdate;
    }

    public class DossierResponse {
        @InvocableVariable public Id addressId;
        @InvocableVariable public String addressName;
        @InvocableVariable public Id caseId;
        @InvocableVariable public String caseNumber;
        @InvocableVariable public String subject;
        @InvocableVariable public String createdDate; // NEW
    }

    @AuraEnabled(cacheable=true)
    public static List<DossierResponse> findCasesByAddressAndPerson(
        String postalCode,
        String houseNumber,
        String birthdate,
        String selectedAddressId
    ) {
        List<DossierResponse> result = new List<DossierResponse>();

        if (String.isBlank(postalCode) || String.isBlank(houseNumber)) return result;

        List<Address__c> addresses = new List<Address__c>();

        if (String.isNotBlank(selectedAddressId)) {
            addresses = [
                SELECT Id, Name
                FROM Address__c
                WHERE Id = :selectedAddressId
            ];
        } else {
            addresses = [
                SELECT Id, Name
                FROM Address__c
                WHERE Postal_Code__c = :postalCode
                AND House_Number__c = :houseNumber
            ];
        }

        if (addresses.isEmpty()) return result;

        Set<Id> addressIds = new Set<Id>();
        for (Address__c a : addresses) {
            addressIds.add(a.Id);
        }

        List<Account_Address__c> accountLinks = [
            SELECT Account__c, Address__c
            FROM Account_Address__c
            WHERE Address__c IN :addressIds
        ];

        Set<Id> accountIds = new Set<Id>();
        for (Account_Address__c link : accountLinks) {
            accountIds.add(link.Account__c);
        }

        if (accountIds.isEmpty()) return result;

        List<Account> matchingAccounts = [
            SELECT Id, PersonBirthdate
            FROM Account
            WHERE Id IN :accountIds
        ];

        Date birthDateInput;
        try {
            birthDateInput = Date.valueOf(birthdate);
        } catch (Exception e) {
            return result;
        }

        Id matchedAccountId;
        for (Account acc : matchingAccounts) {
            if (acc.PersonBirthdate == birthDateInput) {
                matchedAccountId = acc.Id;
                break;
            }
        }

        if (matchedAccountId == null) return result;

        List<Case> openCases = [
            SELECT Id, CaseNumber, Subject, Status, CreatedDate
            FROM Case
            WHERE AccountId = :matchedAccountId
            AND Status NOT IN ('Closed-Accepted', 'Closed-Rejected')
        ];

        for (Case c : openCases) {
            DossierResponse dr = new DossierResponse();
            dr.addressId = addresses[0].Id;
            dr.addressName = addresses[0].Name;
            dr.caseId = c.Id;
            dr.caseNumber = c.CaseNumber;
            dr.subject = c.Subject;
            dr.createdDate = String.valueOf(c.CreatedDate.date()); // Only date
            result.add(dr);
        }

        return result;
    }
}