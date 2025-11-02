import { LightningElement, track, api } from 'lwc';
import analyzeSentiment from '@salesforce/apex/SentimentService.analyzeSentiment';

export default class SentimentAnalyzer extends LightningElement {
    @api textToAnalyze = '';
    @track sentimentResult = '';
    @track isLoading = false;
    
    handleAnalyze() {
        if (!this.textToAnalyze.trim()) {
            this.sentimentResult = 'Please enter some text to analyze.';
            return;
        }
        
        this.isLoading = true;
        this.sentimentResult = '';
        
        analyzeSentiment({ text: this.textToAnalyze })
            .then(result => {
                this.sentimentResult = result;
                this.isLoading = false;
            })
            .catch(error => {
                this.sentimentResult = 'Error analyzing sentiment: ' + error.body.message;
                this.isLoading = false;
            });
    }
    
    handleTextChange(event) {
        this.textToAnalyze = event.target.value;
    }
    
    get sentimentClass() {
        if (!this.sentimentResult) return '';
        
        switch(this.sentimentResult.toUpperCase()) {
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
        if (!this.sentimentResult) return 'utility:chat';
        
        switch(this.sentimentResult.toUpperCase()) {
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
