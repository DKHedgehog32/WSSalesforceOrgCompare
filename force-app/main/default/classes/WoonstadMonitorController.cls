public with sharing class WoonstadMonitorController {
    /**
     * Returns Cases that have been accepted (assigned to agent or desk).
     */
    @AuraEnabled(cacheable=true)
    public static List<Case> getAcceptedVisitors() {
        return [
            SELECT Id, SuppliedName, Owner.Name, LastModifiedDate
            FROM Case
            WHERE Status = 'New' AND OwnerId != null
            ORDER BY LastModifiedDate DESC
            LIMIT 10
        ];
    }
}