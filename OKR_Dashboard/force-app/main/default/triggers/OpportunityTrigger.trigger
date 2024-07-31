trigger OpportunityTrigger on Opportunity (after insert, after delete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            TargetController.incrementCurrentValue('Opportunities', Trigger.new);
        } else if (Trigger.isDelete) {
            TargetController.decreaseCurrentValue('Opportunities', Trigger.old);
        }
    }
}