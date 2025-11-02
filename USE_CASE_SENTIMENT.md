# Use Case: Phát Hiện Cảm Xúc Khách Hàng & Route Agent

## Mô Tả Use Case

### Tình huống thực tế:
Một công ty chăm sóc khách hàng muốn:
1. **Phát hiện cảm xúc** từ các cuộc trò chuyện khách hàng (email, chat, call)
2. **Tự động phân loại** cảm xúc thành: POSITIVE, NEGATIVE, NEUTRAL
3. **Tự động route** cuộc trò chuyện đến agent phù hợp dựa trên cảm xúc:
   - NEGATIVE: Route đến agent chuyên xử lý khiếu nại
   - POSITIVE: Route đến agent chăm sóc khách hàng thân thiết
   - NEUTRAL: Route đến agent hỗ trợ thông thường

## Kiến trúc Hệ Thống

### 1. Các Thành Phần Chính

#### A. Custom Object: CustomerFeedback__c
```
CustomerFeedback__c
├── Name (Text)
├── CustomerName__c (Text)
├── FeedbackText__c (LongTextArea)
├── Sentiment__c (Picklist: POSITIVE, NEGATIVE, NEUTRAL)
├── AgentAssigned__c (Lookup to User)
├── Status__c (Picklist: New, In Progress, Resolved)
└── CreatedDate
```

#### B. Enum: Sentiment (Apex)
```apex
public enum Sentiment {
    POSITIVE,
    NEGATIVE,
    NEUTRAL
}
```

#### C. Apex Service: SentimentService
- Phân tích cảm xúc từ văn bản
- Gán nhãn cảm xúc cho feedback
- Cung cấp API cho trigger/flow

#### D. Trigger/Flow: Routing Logic
- Tự động route khi có feedback mới
- Gán agent phù hợp theo cảm xúc

## Chi Tiết Implementation

### 1. Custom Object: CustomerFeedback__c

```xml
<!-- force-app/main/default/objects/CustomerFeedback__c/CustomerFeedback__c.object-meta.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<CustomObject xmlns="http://soap.sforce.com/2006/04/metadata">
    <label>Customer Feedback</label>
    <pluralLabel>Customer Feedbacks</pluralLabel>
    <nameField>
        <label>Feedback Name</label>
        <type>Text</type>
    </nameField>
    <deploymentStatus>Deployed</deploymentStatus>
    <sharingModel>ReadWrite</sharingModel>
    
    <fields>
        <fullName>CustomerName__c</fullName>
        <label>Customer Name</label>
        <type>Text</type>
        <length>255</length>
    </fields>
    
    <fields>
        <fullName>FeedbackText__c</fullName>
        <label>Feedback Text</label>
        <type>LongTextArea</type>
        <visibleLines>5</visibleLines>
        <length>32768</length>
    </fields>
    
    <fields>
        <fullName>Sentiment__c</fullName>
        <label>Sentiment</label>
        <type>Picklist</type>
        <picklist>
            <picklistValues>
                <fullName>POSITIVE</fullName>
                <default>false</default>
            </picklistValues>
            <picklistValues>
                <fullName>NEGATIVE</fullName>
                <default>false</default>
            </picklistValues>
            <picklistValues>
                <fullName>NEUTRAL</fullName>
                <default>false</default>
            </picklistValues>
        </picklist>
    </fields>
    
    <fields>
        <fullName>AgentAssigned__c</fullName>
        <label>Agent Assigned</label>
        <type>Lookup</type>
        <referenceTo>User</referenceTo>
    </fields>
    
    <fields>
        <fullName>Status__c</fullName>
        <label>Status</label>
        <type>Picklist</type>
        <picklist>
            <picklistValues>
                <fullName>New</fullName>
                <default>true</default>
            </picklistValues>
            <picklistValues>
                <fullName>In Progress</fullName>
                <default>false</default>
            </picklistValues>
            <picklistValues>
                <fullName>Resolved</fullName>
                <default>false</default>
            </picklistValues>
        </picklist>
    </fields>
</CustomObject>
```

### 2. Enum: Sentiment

```apex
// force-app/main/default/classes/Sentiment.cls
public enum Sentiment {
    POSITIVE,
    NEGATIVE,
    NEUTRAL
}
```

### 3. Apex Service: SentimentService

```apex
// force-app/main/default/classes/SentimentService.cls
public with sharing class SentimentService {
    
    // Phân tích cảm xúc từ văn bản
    public static Sentiment analyzeSentiment(String text) {
        if (String.isBlank(text)) {
            return Sentiment.NEUTRAL;
        }
        
        text = text.toLowerCase();
        
        // Danh sách từ khóa cảm xúc
        Set<String> positiveWords = new Set<String>{
            'good', 'great', 'excellent', 'amazing', 'wonderful', 'fantastic',
            'love', 'like', 'happy', 'pleased', 'satisfied', 'perfect',
            'awesome', 'brilliant', 'outstanding', 'superb', 'marvelous'
        };
        
        Set<String> negativeWords = new Set<String>{
            'bad', 'terrible', 'awful', 'horrible', 'disappointed', 'frustrated',
            'angry', 'mad', 'annoyed', 'disgusting', 'worst', 'hate',
            'dislike', 'unsatisfied', 'complaint', 'problem', 'issue', 'fail'
        };
        
        Integer positiveCount = 0;
        Integer negativeCount = 0;
        
        // Đếm từ khóa
        for (String word : positiveWords) {
            if (text.contains(word)) {
                positiveCount++;
            }
        }
        
        for (String word : negativeWords) {
            if (text.contains(word)) {
                negativeCount++;
            }
        }
        
        // Quyết định cảm xúc
        if (positiveCount > negativeCount) {
            return Sentiment.POSITIVE;
        } else if (negativeCount > positiveCount) {
            return Sentiment.NEGATIVE;
        } else {
            return Sentiment.NEUTRAL;
        }
    }
    
    // Cập nhật cảm xúc cho feedback
    public static void updateSentiment(CustomerFeedback__c feedback) {
        if (feedback.FeedbackText__c != null) {
            feedback.Sentiment__c = String.valueOf(analyzeSentiment(feedback.FeedbackText__c));
        }
    }
    
    // Gán agent theo cảm xúc
    public static User assignAgent(Sentiment sentiment) {
        // Trong thực tế, có thể lấy từ custom setting hoặc lookup
        // Đây là ví dụ đơn giản
        switch on sentiment {
            when POSITIVE {
                return getSpecialistAgent(); // Agent chăm sóc khách hàng thân thiết
            }
            when NEGATIVE {
                return getComplaintAgent(); // Agent xử lý khiếu nại
            }
            when NEUTRAL {
                return getSupportAgent(); // Agent hỗ trợ thông thường
            }
        }
        return null;
    }
    
    // Các phương thức hỗ trợ (giả định)
    private static User getSpecialistAgent() {
        // Trả về user có role "Customer Specialist"
        return [SELECT Id FROM User WHERE Profile.Name = 'Customer Specialist' LIMIT 1];
    }
    
    private static User getComplaintAgent() {
        // Trả về user có role "Complaint Handler"
        return [SELECT Id FROM User WHERE Profile.Name = 'Complaint Handler' LIMIT 1];
    }
    
    private static User getSupportAgent() {
        // Trả về user có role "Support Agent"
        return [SELECT Id FROM User WHERE Profile.Name = 'Support Agent' LIMIT 1];
    }
}
```

### 4. Trigger: Auto Routing

```apex
// force-app/main/default/triggers/CustomerFeedbackTrigger.trigger
trigger CustomerFeedbackTrigger on CustomerFeedback__c (after insert, after update) {
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        SentimentService.processFeedback(Trigger.new);
    }
}
```

```apex
// force-app/main/default/classes/SentimentService.cls (phần mở rộng)
public static void processFeedback(List<CustomerFeedback__c> feedbackList) {
    List<CustomerFeedback__c> feedbackToUpdate = new List<CustomerFeedback__c>();
    
    for (CustomerFeedback__c fb : feedbackList) {
        // Chỉ xử lý nếu chưa có cảm xúc
        if (fb.Sentiment__c == null || fb.Sentiment__c == '') {
            updateSentiment(fb);
            
            // Gán agent nếu là mới
            if (Trigger.isInsert) {
                User assignedAgent = assignAgent((Sentiment)Enum.valueOf(Sentiment.class, fb.Sentiment__c));
                if (assignedAgent != null) {
                    fb.AgentAssigned__c = assignedAgent.Id;
                }
                fb.Status__c = 'In Progress';
            }
            
            feedbackToUpdate.add(fb);
        }
    }
    
    if (!feedbackToUpdate.isEmpty()) {
        update feedbackToUpdate;
    }
}
```

### 5. Test Class: SentimentServiceTest

```apex
// force-app/main/default/classes/SentimentServiceTest.cls
@isTest
private class SentimentServiceTest {
    
    @isTest
    static void testAnalyzeSentiment_positive() {
        String positiveText = 'This is great! I love this product. Excellent service!';
        Sentiment result = SentimentService.analyzeSentiment(positiveText);
        System.assertEquals(Sentiment.POSITIVE, result);
    }
    
    @isTest
    static void testAnalyzeSentiment_negative() {
        String negativeText = 'This is terrible! I hate this product. Bad service!';
        Sentiment result = SentimentService.analyzeSentiment(negativeText);
        System.assertEquals(Sentiment.NEGATIVE, result);
    }
    
    @isTest
    static void testAnalyzeSentiment_neutral() {
        String neutralText = 'This is a product. It works. Nothing special.';
        Sentiment result = SentimentService.analyzeSentiment(neutralText);
        System.assertEquals(Sentiment.NEUTRAL, result);
    }
    
    @isTest
    static void testUpdateSentiment() {
        CustomerFeedback__c fb = new CustomerFeedback__c(
            Name = 'Test Feedback',
            FeedbackText__c = 'Great product!'
        );
        
        SentimentService.updateSentiment(fb);
        System.assertEquals('POSITIVE', fb.Sentiment__c);
    }
    
    @isTest
    static void testBlankText() {
        Sentiment result = SentimentService.analyzeSentiment('');
        System.assertEquals(Sentiment.NEUTRAL, result);
        
        result = SentimentService.analyzeSentiment(null);
        System.assertEquals(Sentiment.NEUTRAL, result);
    }
}
```

## End-to-End Workflow Test

### 1. Test Scenario

**Test Case 1: Positive Feedback**
1. Tạo CustomerFeedback__c với nội dung tích cực
2. Trigger tự động phân tích cảm xúc
3. Gán agent chuyên chăm sóc khách hàng
4. Status chuyển thành "In Progress"

**Test Case 2: Negative Feedback**
1. Tạo CustomerFeedback__c với nội dung tiêu cực
2. Trigger tự động phân tích cảm xúc
3. Gán agent xử lý khiếu nại
4. Status chuyển thành "In Progress"

**Test Case 3: Neutral Feedback**
1. Tạo CustomerFeedback__c với nội dung trung lập
2. Trigger tự động phân tích cảm xúc
3. Gán agent hỗ trợ thông thường
4. Status chuyển thành "In Progress"

### 2. Test Execution

```bash
# Deploy các thành phần
sf project deploy start --source-dir force-app/main/default --target-org scratch-org

# Chạy test
sf apex run test --class-names SentimentServiceTest --target-org scratch-org --result-format human

# Tạo sample data để test end-to-end
```

### 3. Sample Data

```apex
// Tạo test data trong Developer Console
CustomerFeedback__c fb1 = new CustomerFeedback__c(
    Name = 'Positive Feedback',
    CustomerName__c = 'John Doe',
    FeedbackText__c = 'This product is amazing! Great service and support.'
);
insert fb1;

CustomerFeedback__c fb2 = new CustomerFeedback__c(
    Name = 'Negative Feedback',
    CustomerName__c = 'Jane Smith',
    FeedbackText__c = 'Terrible experience. Product broke after one day.'
);
insert fb2;

CustomerFeedback__c fb3 = new CustomerFeedback__c(
    Name = 'Neutral Feedback',
    CustomerName__c = 'Bob Johnson',
    FeedbackText__c = 'Product works as expected. No complaints.'
);
insert fb3;
```

## Kết Quả Mong Đợi

### 1. Khi tạo feedback:
- **POSITIVE**: Gán agent "Customer Specialist", status = "In Progress"
- **NEGATIVE**: Gán agent "Complaint Handler", status = "In Progress"  
- **NEUTRAL**: Gán agent "Support Agent", status = "In Progress"

### 2. Kiểm tra kết quả:
1. Trong Salesforce org:
   - Truy cập CustomerFeedback__c
   - Kiểm tra các trường Sentiment__c, AgentAssigned__c, Status__c
2. Trong UI:
   - Các feedback được phân loại và route đúng
   - Agent nhận được công việc phù hợp

## Lợi Ích

### 1. Tự Động Hóa
- Không cần nhân viên phân tích cảm xúc thủ công
- Tự động phân loại và route theo quy trình

### 2. Tăng Hiệu Suất
- Giảm thời gian xử lý feedback
- Đảm bảo khách hàng được xử lý đúng nhóm chuyên môn

### 3. Tăng Trải Nghiệm Khách Hàng
- Phản hồi nhanh chóng
- Xử lý đúng nhu cầu khách hàng

## Mở Rộng

### 1. Tích Hợp AI
- Sử dụng Salesforce Einstein để phân tích cảm xúc chính xác hơn
- Học từ dữ liệu cũ để cải thiện độ chính xác

### 2. Tăng Cường Routing
- Route theo thời gian làm việc của agent
- Route theo kinh nghiệm xử lý cảm xúc
- Route theo ngôn ngữ khách hàng

### 3. Báo Cáo
- Báo cáo phân tích cảm xúc hàng ngày
- Báo cáo hiệu suất agent theo cảm xúc
- Dashboard theo dõi mức độ hài lòng khách hàng
