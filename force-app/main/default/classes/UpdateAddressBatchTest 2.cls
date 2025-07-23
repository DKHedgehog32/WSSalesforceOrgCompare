/**
 * Created by harm on 23/06/2025.
 */

@IsTest
private class UpdateAddressBatchTest {
    @IsTest
    static void testAddress() {
        List<Address__c> testAddresses = TestDataFactory.getAddresses(300);
        insert testAddresses;
        Test.startTest();
        System.assertEquals(300, [SELECT count() FROM Address__c WHERE Correction__c = false],'Expected 300 addresses untouched');
        UpdateAddressesBatch.startBatch('SELECT Id FROM Address__c WHERE Correction__c=false LIMIT 200');
        Test.stopTest();
        System.assertEquals(100, [SELECT count() FROM Address__c WHERE Correction__c = false],'Expected 100 addresses untouched');
        System.assertEquals(200, [SELECT count() FROM Address__c WHERE Correction__c = true],'Expected 200 addresses updated');
    }
    @IsTest
    static void testContractUnit() {
        List<Contract_Unit__c> testUnits = new List<Contract_Unit__c>();
        testUnits.add(TestDataFactory.getContractUnit('apex1'));
        testUnits.add(TestDataFactory.getContractUnit('apex2'));
        insert testUnits;
        Test.startTest();
        System.assertEquals(2, [SELECT count() FROM Contract_Unit__c WHERE Correction__c = false],'Expected 2 contract units untouched');
        UpdateAddressesBatch.startBatch('SELECT Id FROM Contract_Unit__c WHERE Correction__c=false LIMIT 1');
        Test.stopTest();
        System.assertEquals(1, [SELECT count() FROM Contract_Unit__c WHERE Correction__c = false],'Expected 1 contract unit untouched');
        System.assertEquals(1, [SELECT count() FROM Contract_Unit__c WHERE Correction__c = true],'Expected 1 contract unit updated');
    }
}