trigger ContractTrigger on Contract (after insert, after delete, after update) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            TargetController.incrementCurrentValue('Contracts', Trigger.new);
        } else if (Trigger.isDelete) {
            TargetController.decreaseCurrentValue('Contracts', Trigger.old);
        }

        if (Trigger.isUpdate) {
            for (Contract newContract : Trigger.new) {
                Contract oldContract = Trigger.oldMap.get(newContract.Id);
                if (newContract.Type__c != oldContract.Type__c) {
                    TargetController.decreaseCurrentValue('Contracts', new List<Contract>{oldContract});
                    TargetController.incrementCurrentValue('Contracts', new List<Contract>{newContract});
                }
            }
        }
    }
}