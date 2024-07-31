trigger GoogleReviewTrigger on GoogleReview__c (after insert, after delete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            TargetController.incrementCurrentValue('Google Reviews', Trigger.new);
        } else if (Trigger.isDelete) {
            TargetController.decreaseCurrentValue('Google Reviews', Trigger.old);
        }
    }
}