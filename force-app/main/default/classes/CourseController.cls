public with sharing class CourseController {

    @AuraEnabled(cacheable=true)
    public static List<Course__c> getActiveCourses() {
        return [
            SELECT Id, Name, Level__c, Duration_Hours__c, Price__c,
                   Instructor__r.Name, Instructor__r.Rating__c
            FROM Course__c
            WHERE Status__c = 'Active'
            ORDER BY Name
        ];
    }
}