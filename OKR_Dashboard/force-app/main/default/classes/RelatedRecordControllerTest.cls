@isTest
public class RelatedRecordControllerTest {
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

        // Insert related records
        insertNewSurvey(kr.Id, 'Test Survey');
        insertNewReview(kr.Id, 'Test Review');
        insertNewGoogleReview(kr.Id, 'Test Google Review');
        insertNewCaseStudy(kr.Id, 'Test Case Study');
        insertNewCall(kr.Id, 'Test Call');
        insertNewEvent(kr.Id, 'Test Event');
        insertNewLead(kr.Id, 'Test Lead');
        insertNewOpportunity(kr.Id, 'Test Opportunity');
        insertNewContract(kr.Id, 'Test Contract');
    }
	
    private static void insertNewSurvey(Id keyResultId, String name) {
        Survey__c survey = new Survey__c(Name = name, KeyResult__c = keyResultId);
        insert survey;
    }
    
    private static void insertNewReview(Id keyResultId, String name) {
        Review__c review = new Review__c(Name = name, KeyResult__c = keyResultId);
        insert review;
    }

    private static void insertNewGoogleReview(Id keyResultId, String name) {
        GoogleReview__c googleReview = new GoogleReview__c(Name = name, KeyResult__c = keyResultId);
        insert googleReview;
    }

    private static void insertNewCaseStudy(Id keyResultId, String name) {
        CaseStudy__c caseStudy = new CaseStudy__c(Name = name, KeyResult__c = keyResultId);
        insert caseStudy;
    }

    private static void insertNewCall(Id keyResultId, String name) {
        Task call = new Task(Subject = name, KeyResult__c = keyResultId, Type = 'Call');
        insert call;
    }

    private static void insertNewEvent(Id keyResultId, String name) {
        Event event = new Event(Subject = name, DurationInMinutes = 60, ActivityDateTime = System.now(), KeyResult__c = keyResultId);
        insert event;
    }

    private static void insertNewLead(Id keyResultId, String name) {
        Lead lead = new Lead(LastName = name, Company = 'Default Company', KeyResult__c = keyResultId);
        insert lead;
    }

    private static void insertNewOpportunity(Id keyResultId, String name) {
        Opportunity opp = new Opportunity(Name = name, StageName = 'Prospecting', CloseDate = Date.today(), KeyResult__c = keyResultId);
        insert opp;
    }

    private static void insertNewContract(Id keyResultId, String name) {
        Contract con = new Contract(Name = name, AccountId = '001d2000004nM0MAAU', StartDate = Date.today(), ContractTerm = 3, KeyResult__c = keyResultId);
        insert con;
    }

    @isTest
    static void testGetRelatedRecords() {
        KeyResult__c kr = [SELECT Id FROM KeyResult__c LIMIT 1];
        Test.startTest();
        List<RelatedRecordController.RelatedRecordWrapper> relatedRecords = RelatedRecordController.getRelatedRecords(kr.Id);
        Test.stopTest();
        System.assertNotEquals(0, relatedRecords.size(), 'Expected related records');
    }

    @isTest
    static void testCreateRelatedRecord() {
        KeyResult__c kr = [SELECT Id FROM KeyResult__c LIMIT 1];
        Test.startTest();
        RelatedRecordController.RelatedRecordWrapper newSurvey = RelatedRecordController.createRelatedRecord(kr.Id, 'New Survey', 'Survey');
        RelatedRecordController.RelatedRecordWrapper newReview = RelatedRecordController.createRelatedRecord(kr.Id, 'New Review', 'Review');
        RelatedRecordController.RelatedRecordWrapper newGoogleReview = RelatedRecordController.createRelatedRecord(kr.Id, 'New Google Review', 'Google Review');
        RelatedRecordController.RelatedRecordWrapper newCaseStudy = RelatedRecordController.createRelatedRecord(kr.Id, 'New Case Study', 'Case Study');
        RelatedRecordController.RelatedRecordWrapper newCall = RelatedRecordController.createRelatedRecord(kr.Id, 'New Call', 'Call');
        RelatedRecordController.RelatedRecordWrapper newEvent = RelatedRecordController.createRelatedRecord(kr.Id, 'New Event', 'Event');
        RelatedRecordController.RelatedRecordWrapper newLead = RelatedRecordController.createRelatedRecord(kr.Id, 'New Lead', 'Lead');
        RelatedRecordController.RelatedRecordWrapper newOpportunity = RelatedRecordController.createRelatedRecord(kr.Id, 'New Opportunity', 'Opportunity');
        RelatedRecordController.RelatedRecordWrapper newContract = RelatedRecordController.createRelatedRecord(kr.Id, 'New Contract', 'Contract');
        Test.stopTest();

        System.assertNotEquals(null, newSurvey.recordId, 'Expected Survey to be created');
        System.assertNotEquals(null, newReview.recordId, 'Expected Review to be created');
        System.assertNotEquals(null, newGoogleReview.recordId, 'Expected Google Review to be created');
        System.assertNotEquals(null, newCaseStudy.recordId, 'Expected Case Study to be created');
        System.assertNotEquals(null, newCall.recordId, 'Expected Call to be created');
        System.assertNotEquals(null, newEvent.recordId, 'Expected Event to be created');
        System.assertNotEquals(null, newLead.recordId, 'Expected Lead to be created');
        System.assertNotEquals(null, newOpportunity.recordId, 'Expected Opportunity to be created');
        System.assertNotEquals(null, newContract.recordId, 'Expected Contract to be created');
    }
}