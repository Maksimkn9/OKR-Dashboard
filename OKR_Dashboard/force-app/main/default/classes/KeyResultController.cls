public with sharing class KeyResultController {
    @AuraEnabled(cacheable=true)
    public static List<KeyResultWrapper> getKeyResultsWithTargets(Id objectiveId) {
        List<KeyResultWrapper> keyResultWrappers = new List<KeyResultWrapper>();
        Map<Id, List<TargetWrapper>> targetsMap = new Map<Id, List<TargetWrapper>>();

        for (Target__c target : [
            SELECT Id, Type__c, CurrentValue__c, TargetValue__c, Subtype__c, KeyResult__c 
            FROM Target__c 
            WHERE KeyResult__c IN (SELECT Id FROM KeyResult__c WHERE Objective__c = :objectiveId)
        ]) {
            if (!targetsMap.containsKey(target.KeyResult__c)) {
                targetsMap.put(target.KeyResult__c, new List<TargetWrapper>());
            }
            targetsMap.get(target.KeyResult__c).add(new TargetWrapper(target));
        }

        for (KeyResult__c keyResult : [
            SELECT Id, Name 
            FROM KeyResult__c 
            WHERE Objective__c = :objectiveId
        ]) {
            keyResultWrappers.add(new KeyResultWrapper(keyResult, targetsMap.get(keyResult.Id)));
        }

        return keyResultWrappers;
    }

    @AuraEnabled
    public static void createKeyResult(String name, Id objectiveId) {
        KeyResult__c newKeyResult = new KeyResult__c(
            Name = name,
            Objective__c = objectiveId
        );
        insert newKeyResult;
    }

    @AuraEnabled
    public static void saveNewTarget(String keyResultId, List<String> targets, Integer targetValue, String additionalOption) {
        List<Target__c> targetValues = new List<Target__c>();

        for (String target : targets) {
            Target__c targetValueRecord = new Target__c(
                KeyResult__c = keyResultId,
                Type__c = target,
                TargetValue__c = targetValue,
                CurrentValue__c = 0,
                Name = 'Target for ' + target
            );
            if (additionalOption != null && additionalOption != '') {
                targetValueRecord.Subtype__c = additionalOption;
            }
            targetValues.add(targetValueRecord);
        }

        insert targetValues;
    }

    public class KeyResultWrapper {
        @AuraEnabled public Id id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public List<TargetWrapper> targets { get; set; }

        public KeyResultWrapper(KeyResult__c keyResult, List<TargetWrapper> targets) {
            this.id = keyResult.Id;
            this.name = keyResult.Name;
            this.targets = targets;
        }
    }

    public class TargetWrapper {
        @AuraEnabled public String objectType { get; set; }
        @AuraEnabled public Decimal currentValue { get; set; }
        @AuraEnabled public Decimal targetValue { get; set; }
        @AuraEnabled public String additionalOption { get; set; }

        public TargetWrapper(Target__c target) {
            this.objectType = target.Type__c;
            this.currentValue = target.CurrentValue__c;
            this.targetValue = target.TargetValue__c;
            this.additionalOption = target.Subtype__c;
        }
    }
}