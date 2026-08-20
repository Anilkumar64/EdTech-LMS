import { LightningElement, api } from 'lwc';

export default class CourseCard extends LightningElement {
    @api course;

    get instructorName() {
        return this.course?.Instructor__r?.Name || 'TBA';
    }

    get rating() {
        return this.course?.Instructor__r?.Rating__c || 'N/A';
    }

    get priceLabel() {
        return this.course?.Price__c != null ? '₹' + this.course.Price__c : 'Free';
    }

    handleEnroll() {
        this.dispatchEvent(new CustomEvent('enroll', {
            detail: { courseId: this.course.Id }
        }));
    }
}