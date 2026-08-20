public with sharing class ProgressController {

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getEnrollmentProgress(Id enrollmentId) {
        Map<String, Object> result = new Map<String, Object>{
            'progress' => 0,
            'assignmentStatus' => 'Not Started',
            'assessmentResult' => 'Pending'
        };

        if (enrollmentId == null) {
            return result;
        }

        Enrollment__c enroll = [
            SELECT Progress__c
            FROM Enrollment__c
            WHERE Id = :enrollmentId
            LIMIT 1
        ];
        result.put('progress', enroll.Progress__c != null ? enroll.Progress__c : 0);

        Integer totalSubs = [
            SELECT COUNT() FROM Submission__c WHERE Enrollment__c = :enrollmentId
        ];
        Integer scoredSubs = [
            SELECT COUNT() FROM Submission__c
            WHERE Enrollment__c = :enrollmentId AND Score__c != null
        ];

        if (totalSubs == 0) {
            result.put('assignmentStatus', 'Not Started');
        } else if (scoredSubs == totalSubs) {
            result.put('assignmentStatus', 'All Graded');
        } else {
            result.put('assignmentStatus', scoredSubs + ' of ' + totalSubs + ' graded');
        }

        result.put('assessmentResult', enroll.Progress__c == 100 ? 'Passed' : 'Pending');

        return result;
    }
}