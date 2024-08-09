@isTest
public class ObjectiveControllerTest {
    @TestSetup
    static void makeData(){
        // Generate a unique username by appending a timestamp
        String uniqueUserName = 'testuser@test.com' + System.currentTimeMillis();
        
        User testUser = new User(
            Alias = 'testusr',
            Email = 'testuser@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = UserInfo.getProfileId(),
            TimeZoneSidKey = 'Europe/Riga',
            UserName = uniqueUserName
        );
        insert testUser;

        Objective__c obj = new Objective__c(
            Name = 'Test Objective',
            Year__c = '2023',
            User__c = testUser.Id
        );
        insert obj;

        KeyResult__c kr = new KeyResult__c(
            Name = 'Test Key Result',
            Objective__c = obj.Id
        );
        insert kr;
    }

    @isTest
    static void testGetObjectivesByUserAndYear() {
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser@test.com' LIMIT 1];
        Test.startTest();
        List<ObjectiveController.ObjectiveWrapper> objectives = ObjectiveController.getObjectivesByUserAndYear(testUser.Id, '2023');
        Test.stopTest();
        System.assertEquals(1, objectives.size(), 'Expected one objective');
    }

    @isTest
    static void testCreateObjective() {
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser@test.com' LIMIT 1];
        Test.startTest();
        ObjectiveController.createObjective('New Objective', '2024', testUser.Id);
        Test.stopTest();
        List<Objective__c> objectives = [SELECT Id FROM Objective__c WHERE Year__c = '2024'];
        System.assertEquals(1, objectives.size(), 'Expected one new objective');
    }

    @isTest
    static void testGetNearest10Years() {
        Test.startTest();
        List<String> years = ObjectiveController.getNearest10Years();
        Test.stopTest();
        System.assertEquals(10, years.size(), 'Expected 10 years');
    }
}