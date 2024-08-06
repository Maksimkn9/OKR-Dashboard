trigger LeadTrigger on Lead (after insert, after delete, after update) {
    List<Lead> webLeads = new List<Lead>();
    List<Lead> oldWebLeads = new List<Lead>();

    if (Trigger.isInsert || Trigger.isUpdate) {
        for (Lead l : Trigger.new) {
            if (l.LeadSource == 'Web') {
                webLeads.add(l);
            }
        }
        if (!webLeads.isEmpty()) {
            TargetController.incrementCurrentValue('Leads', webLeads);
        }
    } else if (Trigger.isDelete) {
        for (Lead l : Trigger.old) {
            if (l.LeadSource == 'Web') {
                oldWebLeads.add(l);
            }
        }
        if (!oldWebLeads.isEmpty()) {
            TargetController.decreaseCurrentValue('Leads', oldWebLeads);
        }
    }

    if (Trigger.isUpdate) {
        for (Lead newLead : Trigger.new) {
            Lead oldLead = Trigger.oldMap.get(newLead.Id);
            if (newLead.LeadSource != oldLead.LeadSource) {
                if (oldLead.LeadSource == 'Web') {
                    oldWebLeads.add(oldLead);
                }
                if (newLead.LeadSource == 'Web') {
                    webLeads.add(newLead);
                }
            }
        }
        if (!oldWebLeads.isEmpty()) {
            TargetController.decreaseCurrentValue('Leads', oldWebLeads);
        }
        if (!webLeads.isEmpty()) {
            TargetController.incrementCurrentValue('Leads', webLeads);
        }
    }
}