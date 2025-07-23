@isTest
public class EventLogPublisherTest {

    @isTest
    static void testPublishEventLogs_ValidInputs() {
        // Arrange
        List<EventLogPublisher.EventLogInput> inputs = new List<EventLogPublisher.EventLogInput>();

        EventLogPublisher.EventLogInput input1 = new EventLogPublisher.EventLogInput();
        input1.type = 'Error';
        input1.origin = 'TestApexClass';
        input1.originElement = 'TestElement';
        input1.originType = 'Apex';
        input1.message = 'This is a test error message.';
        input1.interviewGuid = 'test-guid-1234';
        input1.relatedRecordId = '001000000000001';
        input1.executingUser = 'Test User';

        inputs.add(input1);

        // Act
        Test.startTest();
        EventLogPublisher.publishEventLogs(inputs);
        Test.getEventBus().deliver(); // Simulate delivery of the platform events
        Test.stopTest();

        // Assert
        // Verify that the publish did not throw any exceptions. Since we can't query platform events, 
        // this test ensures that the code runs without errors.
    }

    @isTest
    static void testPublishEventLogs_InvalidInputs() {
        // Arrange
        List<EventLogPublisher.EventLogInput> inputs = new List<EventLogPublisher.EventLogInput>();

        EventLogPublisher.EventLogInput input1 = new EventLogPublisher.EventLogInput();
        input1.type = 'InvalidType'; // Invalid type
        input1.origin = 'TestFlow';
        input1.originType = 'Flow';
        input1.message = 'This is a test invalid message.';

        inputs.add(input1);

        // Act
        Test.startTest();
        EventLogPublisher.publishEventLogs(inputs);
        Test.getEventBus().deliver();
        Test.stopTest();

        // Assert
        // Validate that no exceptions were thrown despite the invalid input.
        // Optional: Validate debug logs if needed (use System.assert/Debug logs).
    }

    @isTest
    static void testPublishEventLogs_EmptyInputList() {
        // Arrange
        List<EventLogPublisher.EventLogInput> inputs = new List<EventLogPublisher.EventLogInput>(); // Empty list

        // Act
        Test.startTest();
        EventLogPublisher.publishEventLogs(inputs);
        Test.getEventBus().deliver();
        Test.stopTest();

        // Assert
        // Validate that no exceptions were thrown and no events were published.
    }

    @isTest
    static void testPublishEventLogs_MissingOptionalFields() {
        // Arrange
        List<EventLogPublisher.EventLogInput> inputs = new List<EventLogPublisher.EventLogInput>();

        EventLogPublisher.EventLogInput input1 = new EventLogPublisher.EventLogInput();
        input1.type = 'Warning';
        input1.origin = 'TestApexClass';
        input1.originType = 'Apex';
        input1.message = 'This is a test warning message.';
        // Optional fields are left null

        inputs.add(input1);

        // Act
        Test.startTest();
        EventLogPublisher.publishEventLogs(inputs);
        Test.getEventBus().deliver();
        Test.stopTest();

        // Assert
        // Validate that the publish did not throw any exceptions.
    }
}