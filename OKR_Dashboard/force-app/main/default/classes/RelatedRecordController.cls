public with sharing class RelatedRecordController {
    @AuraEnabled(cacheable=true)
    public static List<RelatedRecordWrapper> getRelatedRecords(Id keyResultId) {
        List<RelatedRecordWrapper> relatedRecords = new List<RelatedRecordWrapper>();

        relatedRecords.addAll(getSurveys(keyResultId));
        relatedRecords.addAll(getReviews(keyResultId));
        relatedRecords.addAll(getGoogleReviews(keyResultId));
        relatedRecords.addAll(getCaseStudies(keyResultId));

        return relatedRecords;
    }

    private static List<RelatedRecordWrapper> getSurveys(Id keyResultId) {
        List<RelatedRecordWrapper> surveys = new List<RelatedRecordWrapper>();
        for (Survey__c survey : [SELECT Id, Name FROM Survey__c WHERE KeyResult__c = :keyResultId]) {
            surveys.add(new RelatedRecordWrapper(survey.Id, survey.Name, 'Survey'));
        }
        return surveys;
    }

    private static List<RelatedRecordWrapper> getReviews(Id keyResultId) {
        List<RelatedRecordWrapper> reviews = new List<RelatedRecordWrapper>();
        for (Review__c review : [SELECT Id, Name FROM Review__c WHERE KeyResult__c = :keyResultId]) {
            reviews.add(new RelatedRecordWrapper(review.Id, review.Name, 'Review'));
        }
        return reviews;
    }

    private static List<RelatedRecordWrapper> getGoogleReviews(Id keyResultId) {
        List<RelatedRecordWrapper> googleReviews = new List<RelatedRecordWrapper>();
        for (GoogleReview__c googleReview : [SELECT Id, Name FROM GoogleReview__c WHERE KeyResult__c = :keyResultId]) {
            googleReviews.add(new RelatedRecordWrapper(googleReview.Id, googleReview.Name, 'Google Review'));
        }
        return googleReviews;
    }

    private static List<RelatedRecordWrapper> getCaseStudies(Id keyResultId) {
        List<RelatedRecordWrapper> caseStudies = new List<RelatedRecordWrapper>();
        for (CaseStudy__c caseStudy : [SELECT Id, Name FROM CaseStudy__c WHERE KeyResult__c = :keyResultId]) {
            caseStudies.add(new RelatedRecordWrapper(caseStudy.Id, caseStudy.Name, 'Case Study'));
        }
        return caseStudies;
    }

    @AuraEnabled
    public static RelatedRecordWrapper createRelatedRecord(Id keyResultId, String recordName, String recordType) {
        SObject newRecord;
        String recordTypeName;

        switch on recordType {
            when 'Survey' {
                newRecord = new Survey__c(Name = recordName, KeyResult__c = keyResultId);
                recordTypeName = 'Survey';
            }
            when 'Review' {
                newRecord = new Review__c(Name = recordName, KeyResult__c = keyResultId);
                recordTypeName = 'Review';
            }
            when 'Google Review' {
                newRecord = new GoogleReview__c(Name = recordName, KeyResult__c = keyResultId);
                recordTypeName = 'Google Review';
            }
            when 'Case Study' {
                newRecord = new CaseStudy__c(Name = recordName, KeyResult__c = keyResultId);
                recordTypeName = 'Case Study';
            }
        }

        insert newRecord;
        return new RelatedRecordWrapper(newRecord.Id, recordName, recordTypeName);
    }

    public class RelatedRecordWrapper {
        @AuraEnabled public Id recordId { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String recordType { get; set; }

        public RelatedRecordWrapper(Id recordId, String name, String recordType) {
            this.recordId = recordId;
            this.name = name;
            this.recordType = recordType;
        }
    }
}