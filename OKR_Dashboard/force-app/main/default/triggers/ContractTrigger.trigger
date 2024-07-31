trigger ContractTrigger on Contract (after insert, after delete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            TargetController.incrementCurrentValue('Contracts', Trigger.new);
        } else if (Trigger.isDelete) {
            TargetController.decreaseCurrentValue('Contracts', Trigger.old);
        }
    }
}