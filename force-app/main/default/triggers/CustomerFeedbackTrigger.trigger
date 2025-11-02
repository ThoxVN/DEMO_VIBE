trigger CustomerFeedbackTrigger on CustomerFeedback__c (after insert, after update) {
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        SentimentService.processFeedback(Trigger.new, Trigger.isInsert);
    }
}
