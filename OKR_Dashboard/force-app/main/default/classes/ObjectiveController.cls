public with sharing class ObjectiveController {
    @AuraEnabled(cacheable=true)
    public static List<ObjectiveWrapper> getObjectivesByUserAndYear(Id userId, String year) {
        List<ObjectiveWrapper> objectiveWrappers = new List<ObjectiveWrapper>();
        Map<Id, List<KeyResultWrapper>> keyResultsMap = new Map<Id, List<KeyResultWrapper>>();

        for (KeyResult__c keyResult : [
            SELECT Id, Name, Objective__c 
            FROM KeyResult__c 
            WHERE Objective__c IN (SELECT Id FROM Objective__c WHERE User__c = :userId AND Year__c = :year)
        ]) {
            if (!keyResultsMap.containsKey(keyResult.Objective__c)) {
                keyResultsMap.put(keyResult.Objective__c, new List<KeyResultWrapper>());
            }
            keyResultsMap.get(keyResult.Objective__c).add(new KeyResultWrapper(keyResult));
        }

        for (Objective__c objective : [
            SELECT Id, Name, Year__c, User__c, User__r.Name 
            FROM Objective__c 
            WHERE User__c = :userId AND Year__c = :year
        ]) {
            ObjectiveWrapper wrapper = new ObjectiveWrapper(objective, keyResultsMap.get(objective.Id));
            objectiveWrappers.add(wrapper);
        }

        return objectiveWrappers;
    }

    @AuraEnabled
    public static void createObjective(String name, String year, Id userId) {
        Objective__c newObjective = new Objective__c(
            Name = name,
            Year__c = year,
            User__c = userId
        );
        insert newObjective;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getNearest10Years() {
        Integer currentYear = Date.today().year();
        List<String> years = new List<String>();
        for (Integer i = 0; i < 10; i++) {
            years.add(String.valueOf(currentYear + i));
        }
        return years;
    }

    public class ObjectiveWrapper {
        @AuraEnabled public Id id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String year { get; set; }
        @AuraEnabled public Id userId { get; set; }
        @AuraEnabled public String userName { get; set; }
        @AuraEnabled public List<KeyResultWrapper> keyResults { get; set; }

        public ObjectiveWrapper(Objective__c objective, List<KeyResultWrapper> keyResults) {
            this.id = objective.Id;
            this.name = objective.Name;
            this.year = objective.Year__c;
            this.userId = objective.User__c;
            this.userName = objective.User__r.Name;
            this.keyResults = keyResults;
        }
    }

    public class KeyResultWrapper {
        @AuraEnabled public Id id { get; set; }
        @AuraEnabled public String name { get; set; }

        public KeyResultWrapper(KeyResult__c keyResult) {
            this.id = keyResult.Id;
            this.name = keyResult.Name;
        }
    }
}