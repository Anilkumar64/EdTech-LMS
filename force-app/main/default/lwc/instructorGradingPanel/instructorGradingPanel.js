import { LightningElement, api, wire, track } from 'lwc';
import getSubmissionsForAssignment from '@salesforce/apex/GradingController.getSubmissionsForAssignment';
import saveGrade from '@salesforce/apex/GradingController.saveGrade';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class InstructorGradingPanel extends LightningElement {
    @api assignmentId;

    @track submissions = [];
    wiredResult;
    error;
    isLoading = true;
    isSaving = false;

    @wire(getSubmissionsForAssignment, { assignmentId: '$assignmentId' })
    wiredSubmissions(result) {
        this.wiredResult = result;
        this.isLoading = false;
        if (result.data) {
            this.submissions = result.data.map(s => ({
                ...s,
                draftScore: s.Score__c,
                draftFeedback: s.Feedback__c || ''
            }));
        } else if (result.error) {
            this.error = result.error;
        }
    }

    handleScoreChange(event) {
        const id = event.target.dataset.id;
        const value = event.target.value;
        this.submissions = this.submissions.map(s =>
            s.Id === id ? { ...s, draftScore: value } : s
        );
    }

    handleFeedbackChange(event) {
        const id = event.target.dataset.id;
        const value = event.target.value;
        this.submissions = this.submissions.map(s =>
            s.Id === id ? { ...s, draftFeedback: value } : s
        );
    }

    async handleSave(event) {
        const id = event.target.dataset.id;
        const sub = this.submissions.find(s => s.Id === id);
        if (!sub) return;

        this.isSaving = true;
        try {
            await saveGrade({
                submissionId: id,
                score: sub.draftScore ? Number(sub.draftScore) : null,
                feedback: sub.draftFeedback
            });
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Grade saved',
                variant: 'success'
            }));
            await refreshApex(this.wiredResult);
        } catch (e) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: e.body?.message || 'Unable to save grade',
                variant: 'error'
            }));
        } finally {
            this.isSaving = false;
        }
    }

    get hasSubmissions() {
        return this.submissions && this.submissions.length > 0;
    }
}
