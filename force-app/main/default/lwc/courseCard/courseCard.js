import { LightningElement, api } from 'lwc';

export default class CourseCard extends LightningElement {
    @api course;

    get courseName() {
        return this.course?.Name || 'Untitled Course';
    }

    get instructorName() {
        return this.course?.Instructor__r?.Name || 'TBA';
    }

    get rating() {
        return this.course?.Instructor__r?.Rating__c || 'N/A';
    }

    get level() {
        return this.course?.Level__c || '-';
    }

    get duration() {
        return this.course?.Duration_Hours__c != null
            ? this.course.Duration_Hours__c + ' hrs'
            : '-';
    }

    get priceLabel() {
        return this.course?.Price__c != null
            ? '₹' + this.course.Price__c
            : 'Free';
    }

    handleEnroll() {
        if (!this.course?.Id) return;
        this.dispatchEvent(new CustomEvent('enroll', {
            detail: { courseId: this.course.Id }
        }));
    }
}