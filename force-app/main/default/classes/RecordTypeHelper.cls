//
// OBSOLETE NAME NOT GOOD
public with sharing class RecordTypeHelper {
    @InvocableMethod(label='Get picklist values for a specified record type id')
    public static List<String> getCasePicklistValues(List<Id> recordTypeIds) {
        for(ID rtId : recordTypeIds) {

        }
        return new List<String> {'RT12' };
    }
}