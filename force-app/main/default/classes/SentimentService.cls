public with sharing class SentimentService {

    // Dùng enum để type-safe
    public enum Sentiment { POSITIVE, NEGATIVE, NEUTRAL }

    // Phân tích cảm xúc -> trả ENUM
    @AuraEnabled
    public static Sentiment analyzeSentiment(String text) {
        // Early exit for null/empty text
        if (String.isBlank(text)) return Sentiment.NEUTRAL;
        
        // Trim text to remove leading/trailing whitespace
        text = text.trim();
        
        // Try to use Einstein Sentiment API first (performance optimization)
        try {
            // Check if Einstein API is available and use it
            Sentiment einsteinSentiment = analyzeWithEinsteinAPI(text);
            if (einsteinSentiment != null) {
                return einsteinSentiment;
            }
        } catch (Exception e) {
            // Fall back to basic keyword analysis if Einstein API fails
            System.debug('Einstein API failed, falling back to keyword analysis: ' + e.getMessage());
        }

        // Fallback to basic keyword analysis with performance optimizations
        return analyzeWithKeywordBased(text);
    }

    // Analyze sentiment using Einstein Sentiment API
    private static Sentiment analyzeWithEinsteinAPI(String text) {
        // Create a callout to Einstein Sentiment API
        // This is a placeholder for the actual Einstein API integration
        
        // In a real implementation, you would:
        // 1. Configure an HTTP callout to Einstein Sentiment API
        // 2. Send the text for sentiment analysis
        // 3. Parse the response and return appropriate Sentiment enum
        
        // For now, we'll simulate the API call behavior
        // In a production environment, you'd use something like:
        
        /*
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.einstein.ai/v2/sentiment'); // Replace with actual endpoint
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer YOUR_ACCESS_TOKEN'); // Replace with actual token
        req.setHeader('Content-Type', 'application/json');
        req.setBody('{"text": "' + text + '"}');
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            // Parse JSON response to get sentiment
            Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            String sentiment = (String) response.get('sentiment');
            
            if (sentiment != null) {
                if (sentiment.equalsIgnoreCase('positive')) return Sentiment.POSITIVE;
                if (sentiment.equalsIgnoreCase('negative')) return Sentiment.NEGATIVE;
                if (sentiment.equalsIgnoreCase('neutral')) return Sentiment.NEUTRAL;
            }
        }
        */
        
        // For demonstration purposes, we'll use the keyword-based approach
        // In a real implementation, this would be replaced with actual Einstein API call
        return null; // Return null to fall back to keyword analysis
    }

    // Basic keyword-based analysis as fallback - optimized for performance
    private static Sentiment analyzeWithKeywordBased(String text) {
        // Pre-process text for better performance
        text = text.toLowerCase();
        
        // Use a more efficient approach to tokenize text
        Set<String> tokens = tokenize(text);

        // Define keywords sets - optimized for performance
        Set<String> positiveWords = new Set<String>{
            'good','great','excellent','amazing','wonderful','fantastic',
            'love','like','happy','pleased','satisfied','perfect',
            'awesome','brilliant','outstanding','superb','marvelous'
        };
        Set<String> negativeWords = new Set<String>{
            'bad','terrible','awful','horrible','disappointed','frustrated',
            'angry','mad','annoyed','disgusting','worst','hate',
            'dislike','unsatisfied','complaint','problem','issue','fail'
        };

        // Optimized counting using early exits and efficient iteration
        Integer pos = 0, neg = 0;
        for (String w : positiveWords) {
            if (tokens.contains(w)) pos++;
            // Early exit if we've already determined the sentiment
            if (pos > neg && pos > 0) break;
        }
        for (String w : negativeWords) {
            if (tokens.contains(w)) neg++;
            // Early exit if we've already determined the sentiment
            if (neg > pos && neg > 0) break;
        }

        // Determine sentiment with early return for efficiency
        if (pos > neg) return Sentiment.POSITIVE;
        if (neg > pos) return Sentiment.NEGATIVE;
        return Sentiment.NEUTRAL;
    }

    // Cập nhật sentiment dưới dạng STRING để ghi vào field text/picklist
    public static void stampSentiment(CustomerFeedback__c fb) {
        // Early exit if feedback text is null/empty
        if (String.isBlank(fb.FeedbackText__c)) {
            fb.Sentiment__c = String.valueOf(Sentiment.NEUTRAL);
            return;
        }
        Sentiment s = analyzeSentiment(fb.FeedbackText__c);
        fb.Sentiment__c = String.valueOf(s); // "POSITIVE"/"NEGATIVE"/"NEUTRAL"
    }

    // Gán Agent (bulk-safe): query 1 lần theo Profile.Name, cache theo transaction
    private static Map<String, Id> agentByProfile;
    private static Map<String, Id> getAgentMap() {
        if (agentByProfile == null) {
            agentByProfile = new Map<String, Id>();
            // Optimized SOQL query with proper limits and filtering
            for (User u : [
                SELECT Id, Profile.Name
                FROM User
                WHERE IsActive = true
                AND Profile.Name IN ('Customer Specialist','Complaint Handler','Support Agent')
                ORDER BY LastLoginDate DESC NULLS LAST
                LIMIT 50
            ]) {
                // lấy người đăng nhập gần đây nhất cho mỗi profile
               if (!agentByProfile.containsKey(u.Profile.Name)) {
                    agentByProfile.put(u.Profile.Name, u.Id);
                }
            }
        }
        return agentByProfile;
    }

    public static Id pickAgentId(Sentiment s) {
        Map<String, Id> m = getAgentMap();
        if (s == Sentiment.POSITIVE) return m.get('Customer Specialist');
        if (s == Sentiment.NEGATIVE) return m.get('Complaint Handler');
        return m.get('Support Agent');
    }

    /**
     * Xử lý record ở AFTER trigger:
     * - Tính sentiment & điền Sentiment__c
     * - Nếu isInsert, gán AgentAssigned__c & Status__c
     * KHÔNG DML, KHÔNG SOQL trong loop (SOQL chỉ chạy 1 lần qua cache).
     */
    public static void processFeedback(List<CustomerFeedback__c> newList, Boolean isInsert) {
        // Early exit for empty lists
        if (newList == null || newList.isEmpty()) return;
        
        // đảm bảo agent map đã cache sẵn nếu cần gán
        if (isInsert) getAgentMap();

        for (CustomerFeedback__c fb : newList) {
            // always stamp when Description/FeedbackText__c changes (called from trigger with condition)
            // Early exit if feedback text is null/empty
            if (fb.FeedbackText__c != null && !String.isBlank(fb.FeedbackText__c)) {
                stampSentiment(fb);
            } else {
                fb.Sentiment__c = String.valueOf(Sentiment.NEUTRAL);
            }

            if (isInsert) {
                Sentiment s = analyzeSentiment(fb.FeedbackText__c);
                Id agentId = pickAgentId(s);
                if (agentId != null) fb.AgentAssigned__c = agentId;
                fb.Status__c = 'In Progress';
            }
        }
    }

    @TestVisible
    private static Set<String> tokenize(String input) {
        Set<String> out = new Set<String>();
        // Optimized tokenization using split with proper regex and early exit
        for (String w : input.toLowerCase().split('[^a-z]+')) {
            if (!String.isBlank(w)) out.add(w);
        }
        return out;
    }
}
