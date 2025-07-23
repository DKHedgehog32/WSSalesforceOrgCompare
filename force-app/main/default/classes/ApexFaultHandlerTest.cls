@IsTest
private class ApexFaultHandlerTest {
    @IsTest
    static void testBehavior1() {
        Test.startTest();
        Database.SaveResult res = ApexFaultHandler.publishErrorEvent('Apex Test', 'Unit Test Message', UserInfo.getUserId());
        Test.stopTest();
        System.assertEquals(true, res.success, 'Expected successful publication');
    }
    @IsTest
    static void testBehavior2() {
        Test.startTest();
        Database.SaveResult res = ApexFaultHandler.publishErrorEvent('Apex Test', 'Unit Test Message');
        Test.stopTest();
        System.assertEquals(true, res.success, 'Expected successful publication');
    }
}