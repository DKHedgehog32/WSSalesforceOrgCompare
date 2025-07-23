//
// Utility to publish error events in apex
// Could be bulkified
public inherited sharing class ApexFaultHandler {
    public static Database.SaveResult publishErrorEvent(String location, String message, ID recordId) {
        Apex_Fault__e ev = new Apex_Fault__e();
        ev.Error_Location__c = location;
        ev.Error_Message__c = message;
        ev.Record_Id__c = recordId;
        Database.SaveResult result = EventBus.publish(ev);
        return result;
    }
    public static Database.SaveResult publishErrorEvent(String location, String message) {
        Apex_Fault__e ev = new Apex_Fault__e();
        ev.Error_Location__c = location;
        ev.Error_Message__c = message;

        Database.SaveResult result = EventBus.publish(ev);
        return result;
    }
}