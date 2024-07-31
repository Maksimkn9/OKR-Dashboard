trigger CaseStudyTrigger on CaseStudy__c (after insert, after delete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            TargetController.incrementCurrentValue('Case Studies', Trigger.new);
        } else if (Trigger.isDelete) {
            TargetController.decreaseCurrentValue('Case Studies', Trigger.old);
        }
    }
}