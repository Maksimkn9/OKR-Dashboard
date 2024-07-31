trigger ReviewTrigger on Review__c (after insert, after delete) {
    if (Trigger.isInsert) {
        TargetController.incrementCurrentValue('Reviews', Trigger.new);
    } else if (Trigger.isDelete) {
        TargetController.decreaseCurrentValue('Reviews', Trigger.old);
    }
}