import { LightningElement, wire, track } from 'lwc';
import getActiveCourses from '@salesforce/apex/CourseController.getActiveCourses';

export default class CourseCatalogPage extends LightningElement {
    @track courses = [];
    @track filteredCourses = [];
    @track error;
    isLoading = true;

    levelFilter = '';
    minDuration = null;
    maxPrice = null;

    levelOptions = [
        { label: 'All Levels', value: '' },
        { label: 'Beginner', value: 'Beginner' },
        { label: 'Intermediate', value: 'Intermediate' },
        { label: 'Advanced', value: 'Advanced' }
    ];

    @wire(getActiveCourses)
    wiredCourses({ data, error }) {
        this.isLoading = false;
        if (data) {
            this.courses = data;
            this.applyFilters();
        } else if (error) {
            this.error = error;
            this.courses = [];
        }
    }

    handleLevelChange(event) {
        this.levelFilter = event.detail.value;
        this.applyFilters();
    }

    handleDurationChange(event) {
        this.minDuration = event.target.value ? Number(event.target.value) : null;
        this.applyFilters();
    }

    handlePriceChange(event) {
        this.maxPrice = event.target.value ? Number(event.target.value) : null;
        this.applyFilters();
    }

    applyFilters() {
        this.filteredCourses = this.courses.filter(c => {
            const matchLevel = !this.levelFilter || c.Level__c === this.levelFilter;
            const matchDuration = this.minDuration == null || (c.Duration_Hours__c >= this.minDuration);
            const matchPrice = this.maxPrice == null || (c.Price__c <= this.maxPrice);
            return matchLevel && matchDuration && matchPrice;
        });
    }

    handleEnroll(event) {
        const courseId = event.detail.courseId;
        this.dispatchEvent(new CustomEvent('enrollrequest', {
            detail: { courseId }
        }));
    }

    get hasNoCourses() {
        return !this.isLoading && this.filteredCourses.length === 0;
    }
}

