trigger EventTrigger on Event (after insert, after delete, after update) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            TargetController.incrementCurrentValue('Events', Trigger.new);
        } else if (Trigger.isDelete) {
            TargetController.decreaseCurrentValue('Events', Trigger.old);
        }

        if (Trigger.isUpdate) {
            for (Event newEvent : Trigger.new) {
                Event oldEvent = Trigger.oldMap.get(newEvent.Id);
                if (newEvent.Type != oldEvent.Type) {
                    TargetController.decreaseCurrentValue('Events', new List<Event>{oldEvent});
                    TargetController.incrementCurrentValue('Events', new List<Event>{newEvent});
                }
            }
        }
    }
}