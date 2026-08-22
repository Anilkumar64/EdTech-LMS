import { LightningElement, api, wire } from 'lwc';
import getEnrollmentProgress from '@salesforce/apex/ProgressController.getEnrollmentProgress';

export default class StudentProgressBar extends LightningElement {
    @api enrollmentId;

    progress = 0;
    assignmentStatus = 'Not Started';
    assessmentResult = 'Pending';
    error;
    isLoading = true;

    @wire(getEnrollmentProgress, { enrollmentId: '$enrollmentId' })
    wiredProgress({ data, error }) {
        this.isLoading = false;
        if (data) {
            this.progress = data.progress || 0;
            this.assignmentStatus = data.assignmentStatus || 'Not Started';
            this.assessmentResult = data.assessmentResult || 'Pending';
            this.error = undefined;
        } else if (error) {
            this.error = error;
        }
    }

    get progressVariant() {
        if (this.progress >= 100) return 'success';
        if (this.progress >= 50) return 'warning';
        return 'base';
    }

    get progressLabel() {
        return this.progress + '% Complete';
    }
}