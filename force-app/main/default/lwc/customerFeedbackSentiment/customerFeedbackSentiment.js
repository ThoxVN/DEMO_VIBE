import { LightningElement, track, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord } from 'lightning/uiRecordApi';
import FEEDBACK_OBJECT from '@salesforce/schema/CustomerFeedback__c';
import FEEDBACK_TEXT_FIELD from '@salesforce/schema/CustomerFeedback__c.FeedbackText__c';
import SENTIMENT_FIELD from '@salesforce/schema/CustomerFeedback__c.Sentiment__c';

export default class CustomerFeedbackSentiment extends LightningElement {
    @track feedbackId = '';
    @track feedbackText = '';
    @track sentiment = '';
    @track isLoading = false;
    
    // Get the object info for CustomerFeedback__c
    @wire(getObjectInfo, { objectApiName: FEEDBACK_OBJECT })
    feedbackObjectInfo;
    
    // Get feedback record data
    @wire(getRecord, { recordId: '$feedbackId', fields: [FEEDBACK_TEXT_FIELD, SENTIMENT_FIELD] })
    wiredRecord({ error, data }) {
        if (data) {
            this.feedbackText = data.fields.FeedbackText__c.value;
            this.sentiment = data.fields.Sentiment__c.value;
        } else if (error) {
            console.error('Error fetching record:', error);
        }
    }
    
    handleFeedbackIdChange(event) {
        this.feedbackId = event.target.value;
        this.feedbackText = '';
        this.sentiment = '';
    }
    
    get hasFeedback() {
        return this.feedbackText && this.feedbackText.length > 0;
    }
    
    get sentimentClass() {
        if (!this.sentiment) return '';
        
        switch(this.sentiment.toUpperCase()) {
            case 'POSITIVE':
                return 'slds-text-color_success';
            case 'NEGATIVE':
                return 'slds-text-color_error';
            case 'NEUTRAL':
                return 'slds-text-color_default';
            default:
                return '';
        }
    }
    
    get sentimentIcon() {
        if (!this.sentiment) return 'utility:chat';
        
        switch(this.sentiment.toUpperCase()) {
            case 'POSITIVE':
                return 'utility:emoji2';
            case 'NEGATIVE':
                return 'utility:emoji';
            case 'NEUTRAL':
                return 'utility:conversation';
            default:
                return 'utility:chat';
        }
    }
}
