/**
 * Created by harm on 02/09/2024.
 */

public with sharing class SharedUtils {
    //
    // Converts picklist values into a Set to do comparisons with in apex
    public static Set<String> convertPicklistValuesToSet(Schema.DescribeFieldResult dfr) {
        Set<String> output = new Set<String>();
        List<Schema.PicklistEntry> entries = dfr.getPicklistValues();
        for(Schema.PicklistEntry entry : entries) {
            if(entry.isActive()) {
                output.add(entry.getValue());
            }
        }
        return output;
    }

    public static String replaceNullWithEmptyString(Object input) {
        String output;
        if(input == null) {
            output = '';
        } else {
            output = (String) input.toString();
        }
        return output;
    }
    //
    //Bulkify and wrap?
    public static List<Database.SaveResult> createErrorEvent(String message, String location, String userId) {
        List<Database.SaveResult> results;
        List<Apex_Fault__e> errorEvents = new List<Apex_Fault__e>();
        Apex_Fault__e ev = new Apex_Fault__e();
        ev.Error_Location__c = '';
        ev.Error_Message__c = '';
        ev.Record_Id__c = '';
        errorEvents.add(ev);
        results = EventBus.publish(errorEvents);

        return results;
    }
}