@IsTest
private class SentimentServiceTest {
    
    @IsTest
    static void testAnalyzeSentiment_positive() {
        String positiveText = 'This is great! I love this product. Excellent service!';
        SentimentService.Sentiment result = SentimentService.analyzeSentiment(positiveText);
        System.assertEquals(SentimentService.Sentiment.POSITIVE, result);
    }
    
    @IsTest
    static void testAnalyzeSentiment_negative() {
        String negativeText = 'This is terrible! I hate this product. Bad service!';
        SentimentService.Sentiment result = SentimentService.analyzeSentiment(negativeText);
        System.assertEquals(SentimentService.Sentiment.NEGATIVE, result);
    }
    
    @IsTest
    static void testAnalyzeSentiment_neutral() {
        String neutralText = 'This is a product. It works. Nothing special.';
        SentimentService.Sentiment result = SentimentService.analyzeSentiment(neutralText);
        System.assertEquals(SentimentService.Sentiment.NEUTRAL, result);
    }   
    
    
    @IsTest
    static void testBlankText() {
        SentimentService.Sentiment result = SentimentService.analyzeSentiment('');
        System.assertEquals(SentimentService.Sentiment.NEUTRAL, result);
        
        result = SentimentService.analyzeSentiment(null);
        System.assertEquals(SentimentService.Sentiment.NEUTRAL, result);
    }
    
    @IsTest
    static void testProcessFeedback() {
        // Create test feedback records
        CustomerFeedback__c fb1 = new CustomerFeedback__c(
            Name = 'Test Feedback 1',
            FeedbackText__c = 'This is great! I love this product.'
        );
        CustomerFeedback__c fb2 = new CustomerFeedback__c(
            Name = 'Test Feedback 2',
            FeedbackText__c = 'This is terrible! I hate this product.'
        );
        CustomerFeedback__c fb3 = new CustomerFeedback__c(
            Name = 'Test Feedback 3',
            FeedbackText__c = 'This is okay. Nothing special.'
        );
        
        List<CustomerFeedback__c> feedbackList = new List<CustomerFeedback__c>{fb1, fb2, fb3};
        
        // Test processFeedback method
        SentimentService.processFeedback(feedbackList, true); // isInsert = true
        
        // Verify that sentiment was set correctly
        System.assertEquals('POSITIVE', fb1.Sentiment__c);
        System.assertEquals('NEGATIVE', fb2.Sentiment__c);
        System.assertEquals('NEUTRAL', fb3.Sentiment__c);
    }
    
    @IsTest
    static void testAnalyzeSentimentAuraEnabled() {
        // Test the @AuraEnabled method directly
        String positiveText = 'This is great! I love this product. Excellent service!';
        SentimentService.Sentiment result = SentimentService.analyzeSentiment(positiveText);
        System.assertEquals(SentimentService.Sentiment.POSITIVE, result);
    }
}
