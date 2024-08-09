@IsTest
public class TargetControllerTest {

    @TestSetup
    static void setupTestData() {
        // Setup common test data

        // Create KeyResult records
        KeyResult__c keyResult1 = new KeyResult__c(Name='KeyResult 1');
        KeyResult__c keyResult2 = new KeyResult__c(Name='KeyResult 2');
        insert new List<KeyResult__c>{keyResult1, keyResult2};

        // Create Target records linked to KeyResults
        Target__c target1 = new Target__c(KeyResult__c = keyResult1.Id, Type__c = 'Calls', CurrentValue__c = 10);
        Target__c target2 = new Target__c(KeyResult__c = keyResult2.Id, Type__c = 'Calls', CurrentValue__c = 20);
        insert new List<Target__c>{target1, target2};
    }

    @IsTest
    static void testIncrementCurrentValue() {
        // Get test data
        KeyResult__c keyResult1 = [SELECT Id FROM KeyResult__c WHERE Name = 'KeyResult 1' LIMIT 1];
        
        // Create a list of tasks to increment value
        Task task1 = new Task(KeyResult__c = keyResult1.Id, Subject = 'Call 1');
        insert task1;

        // Invoke the incrementCurrentValue method
        TargetController.incrementCurrentValue('Calls', new List<SObject>{task1});

        // Verify that the CurrentValue__c was incremented
        Target__c target = [SELECT CurrentValue__c FROM Target__c WHERE KeyResult__c = :keyResult1.Id];
        System.assertEquals(11, target.CurrentValue__c);
    }

    @IsTest
    static void testDecreaseCurrentValue() {
        // Get test data
        KeyResult__c keyResult2 = [SELECT Id FROM KeyResult__c WHERE Name = 'KeyResult 2' LIMIT 1];
        
        // Create a list of tasks to increment value
        Task task2 = new Task(KeyResult__c = keyResult2.Id, Subject = 'Call 2');
        insert task2;

        // Invoke the incrementCurrentValue method
        TargetController.DecreaseCurrentValue('Calls', new List<SObject>{task2});

        // Verify that the CurrentValue__c was incremented
        Target__c target = [SELECT CurrentValue__c FROM Target__c WHERE KeyResult__c = :keyResult2.Id];
        System.assertEquals(19, target.CurrentValue__c);
    }

    @IsTest
    static void testNullKeyResultIdHandling() {
        // Create a task without a KeyResult__c (should be ignored)
        Task taskWithoutKeyResult = new Task(Subject = 'Call without KeyResult');
        insert taskWithoutKeyResult;

        // Invoke the incrementCurrentValue method
        TargetController.incrementCurrentValue('Calls', new List<SObject>{taskWithoutKeyResult});

        // Verify that no records were updated (as the KeyResult__c was null)
        Integer count = [SELECT COUNT() FROM Target__c WHERE CurrentValue__c = 10];
        System.assertEquals(1, count); // Ensuring the original value was not changed
    }

    @IsTest
    static void testInvalidTargetTypeHandling() {
        // Create an SObject with an invalid target type
        Case caseRecord = new Case(Subject = 'Case without KeyResult');
        insert caseRecord;

        // Invoke the incrementCurrentValue method with an invalid target type
        TargetController.incrementCurrentValue('InvalidType', new List<SObject>{caseRecord});

        // Verify no changes were made as the target type was invalid
        Integer count = [SELECT COUNT() FROM Target__c];
        System.assertEquals(2, count); // Ensuring no extra records were affected
    }

    @IsTest
    static void testEdgeCaseWithNoRecords() {
        // Invoke the incrementCurrentValue and decreaseCurrentValue methods with empty lists
        TargetController.incrementCurrentValue('Calls', new List<SObject>());
        TargetController.decreaseCurrentValue('Calls', new List<SObject>());

        // No changes should be made, but methods should still execute without error
        Integer count = [SELECT COUNT() FROM Target__c];
        System.assertEquals(2, count); // Ensuring no changes to original records
    }
}