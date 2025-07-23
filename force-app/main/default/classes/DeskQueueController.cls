/**
 * Created by harm on 21/02/2025.
 */

public with sharing class DeskQueueController {
    @AuraEnabled
    public static List<Service_Desk_Registration__c> getQueue(ID locationId) {
        System.debug('### Getting queue for location *'+locationId+'*');
        List<Service_Desk_Registration__c> output = [SELECT Id, Service_Desk_Physical_Location__c, Type__c, Service_Desk_Physical_Location__r.Name, Display_Label__c, Is_Relevant__c, Status__c FROM Service_Desk_Registration__c WHERE Is_In_Queue__c=true AND Service_Desk_Physical_Location__c=:locationId AND Is_Relevant__c=true ORDER BY CreatedDate ASC];

        return output;
    }
    @AuraEnabled
    public static List<Service_Desk_Registration__c> getAtDesk(ID locationId) {
        System.debug('### Getting queue for location *'+locationId+'*');
        List<Service_Desk_Registration__c> output = [SELECT Id, Service_Desk_Physical_Location__c, Type__c, Service_Desk_Physical_Location__r.Name, Display_Label__c, Is_Relevant__c, Status__c FROM Service_Desk_Registration__c WHERE Is_At_Desk__c=true AND Service_Desk_Physical_Location__c=:locationId AND Is_Relevant__c=true ORDER BY CreatedDate ASC];

        return output;
    }
}