@isTest
public class KeyResultControllerTest {
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

        Target__c target = new Target__c(
            Type__c = 'Test Type',
            CurrentValue__c = 1,
            TargetValue__c = 100,
            KeyResult__c = kr.Id
        );
        insert target;
    }

    @isTest
    static void testGetKeyResultsWithTargets() {
        Objective__c obj = [SELECT Id FROM Objective__c LIMIT 1];
        System.assertNotEquals(null, obj, 'Objective should be inserted');

        Test.startTest();
        List<KeyResultController.KeyResultWrapper> keyResults = KeyResultController.getKeyResultsWithTargets(obj.Id);
        Test.stopTest();

        System.assertEquals(1, keyResults.size(), 'Expected one key result');
        System.assertNotEquals(0, keyResults[0].targets.size(), 'KeyResultWrapper should have TargetWrappers');
    }

    @isTest
    static void testCreateKeyResult() {
        Objective__c obj = [SELECT Id FROM Objective__c LIMIT 1];
        System.assertNotEquals(null, obj, 'Objective should be inserted');

        Test.startTest();
        KeyResultController.createKeyResult('New Key Result', obj.Id);
        Test.stopTest();

        List<KeyResult__c> keyResults = [SELECT Id FROM KeyResult__c WHERE Name = 'New Key Result'];
        System.assertEquals(1, keyResults.size(), 'Expected one new key result');
    }

    @isTest
    static void testSaveNewTarget() {
        KeyResult__c kr = [SELECT Id FROM KeyResult__c LIMIT 1];
        System.assertNotEquals(null, kr, 'KeyResult should be inserted');

        Test.startTest();
        KeyResultController.saveNewTarget(kr.Id, new List<String>{'Test Type'}, 100, 'Subtype Option');
        Test.stopTest();

        List<Target__c> targets = [SELECT Id, Subtype__c FROM Target__c WHERE KeyResult__c = :kr.Id];
        System.assertEquals(2, targets.size(), 'Expected two targets');
        System.assertEquals('Subtype Option', targets[1].Subtype__c, 'Expected Subtype to be set');
    }

    @isTest
    static void testTargetWrapper() {
        Target__c target = [SELECT Id, Type__c, CurrentValue__c, TargetValue__c, Subtype__c FROM Target__c LIMIT 1];
        KeyResultController.TargetWrapper wrapper = new KeyResultController.TargetWrapper(target);

        System.assertEquals(target.Type__c, wrapper.objectType, 'ObjectType should match');
        System.assertEquals(target.CurrentValue__c, wrapper.currentValue, 'CurrentValue should match');
        System.assertEquals(target.TargetValue__c, wrapper.targetValue, 'TargetValue should match');
        System.assertEquals(target.Subtype__c, wrapper.additionalOption, 'AdditionalOption should match');
    }

    @isTest
    static void testKeyResultWrapper() {
        KeyResult__c kr = [SELECT Id, Name FROM KeyResult__c LIMIT 1];
        List<Target__c> targets = [SELECT Id, Type__c, CurrentValue__c, TargetValue__c, Subtype__c FROM Target__c WHERE KeyResult__c = :kr.Id];
        List<KeyResultController.TargetWrapper> targetWrappers = new List<KeyResultController.TargetWrapper>();
        for (Target__c t : targets) {
            targetWrappers.add(new KeyResultController.TargetWrapper(t));
        }

        KeyResultController.KeyResultWrapper wrapper = new KeyResultController.KeyResultWrapper(kr, targetWrappers);

        System.assertEquals(kr.Id, wrapper.id, 'Id should match');
        System.assertEquals(kr.Name, wrapper.name, 'Name should match');
        System.assertEquals(targetWrappers.size(), wrapper.targets.size(), 'Targets size should match');
    }

    @isTest
    static void testTargetsMapAndKeyResultWrappers() {
        KeyResult__c kr = [SELECT Id FROM KeyResult__c LIMIT 1];
        List<Target__c> targets = [SELECT Id, Type__c, CurrentValue__c, TargetValue__c, Subtype__c, KeyResult__c FROM Target__c WHERE KeyResult__c = :kr.Id];

        Map<Id, List<KeyResultController.TargetWrapper>> targetsMap = new Map<Id, List<KeyResultController.TargetWrapper>>();
        for (Target__c target : targets) {
            if (!targetsMap.containsKey(target.KeyResult__c)) {
                targetsMap.put(target.KeyResult__c, new List<KeyResultController.TargetWrapper>());
            }
            targetsMap.get(target.KeyResult__c).add(new KeyResultController.TargetWrapper(target));
        }

        System.assert(targetsMap.containsKey(kr.Id), 'TargetsMap should contain the KeyResult Id');
        System.assertNotEquals(0, targetsMap.get(kr.Id).size(), 'TargetsMap should have TargetWrappers');

        List<KeyResultController.KeyResultWrapper> keyResultWrappers = new List<KeyResultController.KeyResultWrapper>();
        for (KeyResult__c keyResult : [SELECT Id, Name FROM KeyResult__c WHERE Id = :kr.Id]) {
            keyResultWrappers.add(new KeyResultController.KeyResultWrapper(keyResult, targetsMap.get(keyResult.Id)));
        }

        System.assertEquals(1, keyResultWrappers.size(), 'Expected one KeyResultWrapper');
        System.assertNotEquals(0, keyResultWrappers[0].targets.size(), 'KeyResultWrapper should have TargetWrappers');
    }
}