public with sharing class TargetController {
    public static void incrementCurrentValue(String targetType, List<SObject> newRecords) {
        processValueChange(targetType, newRecords, 1);
    }

    public static void decreaseCurrentValue(String targetType, List<SObject> oldRecords) {
        processValueChange(targetType, oldRecords, -1);
    }

    private static void processValueChange(String targetType, List<SObject> records, Integer changeFactor) {
        Map<Id, Integer> keyResultScoreMap = new Map<Id, Integer>();
        Map<Id, String> keyResultTypeMap = new Map<Id, String>();

        for (SObject record : records) {
            Id keyResultId = getKeyResultId(targetType, record);
            String additionalOption = getAdditionalOption(targetType, record);

            if (keyResultId != null) {
                if (!keyResultScoreMap.containsKey(keyResultId)) {
                    keyResultScoreMap.put(keyResultId, 0);
                }
                keyResultScoreMap.put(keyResultId, keyResultScoreMap.get(keyResultId) + changeFactor);
                keyResultTypeMap.put(keyResultId, additionalOption);
            }
        }

        List<Target__c> targetScoresToUpdate = new List<Target__c>();
        for (Id keyResultId : keyResultScoreMap.keySet()) {
            String type = keyResultTypeMap.get(keyResultId);
            List<Target__c> targetScores = [
                SELECT Id, CurrentValue__c 
                FROM Target__c 
                WHERE KeyResult__c = :keyResultId 
                AND Type__c = :targetType
                AND Subtype__c = :type
            ];

            for (Target__c targetScore : targetScores) {
                targetScore.CurrentValue__c += keyResultScoreMap.get(keyResultId);
                targetScoresToUpdate.add(targetScore);
            }
        }

        if (!targetScoresToUpdate.isEmpty()) {
            update targetScoresToUpdate;
        }
    }

    private static Id getKeyResultId(String targetType, SObject record) {
        switch on targetType {
            when 'Calls' {
                Task taskRecord = (Task)record;
                return taskRecord.WhatId != null ? [SELECT Id FROM KeyResult__c WHERE Id = :taskRecord.WhatId LIMIT 1].Id : null;
            }
            when 'Leads' {
                Lead lead = (Lead)record;
                return lead.KeyResult__c;
            }
            when 'Events' {
                Event eventRecord = (Event)record;
                return eventRecord.WhatId != null ? [SELECT Id FROM KeyResult__c WHERE Id = :eventRecord.WhatId LIMIT 1].Id : null;
            }
            when 'Opportunities' {
                return ((Opportunity)record).KeyResult__c;
            }
            when 'Contracts' {
                return ((Contract)record).KeyResult__c;
            }
            when 'Surveys' {
                return ((Survey__c)record).KeyResult__c;
            }
            when 'Reviews' {
                return ((Review__c)record).KeyResult__c;
            }
            when 'Google Reviews' {
                return ((GoogleReview__c)record).KeyResult__c;
            }
            when 'Case Studies' {
                return ((CaseStudy__c)record).KeyResult__c;
            }
            when else {
                return null;
            }
        }
    }

    private static String getAdditionalOption(String targetType, SObject record) {
        switch on targetType {
            when 'Events' {
                return ((Event)record).Type;
            }
            when 'Contracts' {
                return ((Contract)record).Type__c;
            }
            when else {
                return '';
            }
        }
    }
}