trigger EventTrigger on Event (after insert, after delete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            TargetController.incrementCurrentValue('Events', Trigger.new);
        } else if (Trigger.isDelete) {
            TargetController.decreaseCurrentValue('Events', Trigger.old);
        }
    }
}