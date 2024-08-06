public with sharing class RelatedRecordController {
    @AuraEnabled(cacheable=true)
    public static List<RelatedRecordWrapper> getRelatedRecords(Id keyResultId) {
        List<RelatedRecordWrapper> relatedRecords = new List<RelatedRecordWrapper>();

        relatedRecords.addAll(getSurveys(keyResultId));
        relatedRecords.addAll(getReviews(keyResultId));
        relatedRecords.addAll(getGoogleReviews(keyResultId));
        relatedRecords.addAll(getCaseStudies(keyResultId));
        relatedRecords.addAll(getCalls(keyResultId));
        relatedRecords.addAll(getEvents(keyResultId));
        relatedRecords.addAll(getLeads(keyResultId));
        relatedRecords.addAll(getOpportunities(keyResultId));
        relatedRecords.addAll(getContracts(keyResultId));

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

    private static List<RelatedRecordWrapper> getCalls(Id keyResultId) {
        List<RelatedRecordWrapper> calls = new List<RelatedRecordWrapper>();
        for (Task call : [SELECT Id, NameC__c FROM Task WHERE KeyResult__c = :keyResultId AND Type = 'Call']) {
            calls.add(new RelatedRecordWrapper(call.Id, call.NameC__c, 'Call'));
        }
        return calls;
    }

    private static List<RelatedRecordWrapper> getEvents(Id keyResultId) {
        List<RelatedRecordWrapper> events = new List<RelatedRecordWrapper>();
        for (Event event : [SELECT Id, NameC__c FROM Event WHERE KeyResult__c = :keyResultId]) {
            events.add(new RelatedRecordWrapper(event.Id, event.NameC__c, 'Event'));
        }
        return events;
    }

    private static List<RelatedRecordWrapper> getLeads(Id keyResultId) {
        List<RelatedRecordWrapper> leads = new List<RelatedRecordWrapper>();
        for (Lead lead : [SELECT Id, Name FROM Lead WHERE KeyResult__c = :keyResultId]) {
            leads.add(new RelatedRecordWrapper(lead.Id, lead.Name, 'Lead'));
        }
        return leads;
    }

    private static List<RelatedRecordWrapper> getOpportunities(Id keyResultId) {
        List<RelatedRecordWrapper> opportunities = new List<RelatedRecordWrapper>();
        for (Opportunity opp : [SELECT Id, Name FROM Opportunity WHERE KeyResult__c = :keyResultId]) {
            opportunities.add(new RelatedRecordWrapper(opp.Id, opp.Name, 'Opportunity'));
        }
        return opportunities;
    }

    private static List<RelatedRecordWrapper> getContracts(Id keyResultId) {
        List<RelatedRecordWrapper> contracts = new List<RelatedRecordWrapper>();
        for (Contract con : [SELECT Id, Name FROM Contract WHERE KeyResult__c = :keyResultId]) {
            contracts.add(new RelatedRecordWrapper(con.Id, con.Name, 'Contract'));
        }
        return contracts;
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
            when 'Call' {
                newRecord = new Task(NameC__c = recordName, KeyResult__c = keyResultId, Type = 'Call');
                recordTypeName = 'Call';
            }
            when 'Event' {
                newRecord = new Event(NameC__c = recordName, DurationInMinutes = 60, ActivityDateTime = System.now(), KeyResult__c = keyResultId);
                recordTypeName = 'Event';
            }
            when 'Lead' {
                newRecord = new Lead(LastName = recordName, Company = 'Default Company', KeyResult__c = keyResultId);
                recordTypeName = 'Lead';
            }
            when 'Opportunity' {
                newRecord = new Opportunity(Name = recordName, StageName = 'Prospecting', CloseDate = Date.today(), KeyResult__c = keyResultId);
                recordTypeName = 'Opportunity';
            }
            when 'Contract' {
                newRecord = new Contract(Name = recordName, AccountId = '001d2000004nM0MAAU', StartDate = Date.today(), ContractTerm = 3, KeyResult__c = keyResultId);
                recordTypeName = 'Contract';
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