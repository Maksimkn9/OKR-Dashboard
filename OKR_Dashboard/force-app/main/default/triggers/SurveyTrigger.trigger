trigger SurveyTrigger on Survey__c (after insert, after delete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            TargetController.incrementCurrentValue('Surveys', Trigger.new);
        } else if (Trigger.isDelete) {
            TargetController.decreaseCurrentValue('Surveys', Trigger.old);
        }
    }
}