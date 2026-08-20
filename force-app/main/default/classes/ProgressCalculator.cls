public with sharing class ProgressCalculator {

    public static void recalculate(Set<Id> enrollmentIds) {
        if (enrollmentIds == null || enrollmentIds.isEmpty()) {
            return;
        }

        // 1. Map Enrollment → Course
        Map<Id, Id> enrollmentToCourse = new Map<Id, Id>();
        for (Enrollment__c e : [
            SELECT Id, Course__c
            FROM Enrollment__c
            WHERE Id IN :enrollmentIds
        ]) {
            enrollmentToCourse.put(e.Id, e.Course__c);
        }

        Set<Id> courseIds = new Set<Id>(enrollmentToCourse.values());

        // 2. All Modules for these Courses
        Map<Id, List<Id>> modulesByCourse = new Map<Id, List<Id>>();
        Map<Id, Id> moduleToCourse = new Map<Id, Id>();

        for (Module__c m : [
            SELECT Id, Course__c
            FROM Module__c
            WHERE Course__c IN :courseIds
        ]) {
            if (!modulesByCourse.containsKey(m.Course__c)) {
                modulesByCourse.put(m.Course__c, new List<Id>());
            }
            modulesByCourse.get(m.Course__c).add(m.Id);
            moduleToCourse.put(m.Id, m.Course__c);
        }

        // 3. All Assignments under those Modules
        Map<Id, List<Id>> assignmentsByModule = new Map<Id, List<Id>>();
        for (Assignment__c a : [
            SELECT Id, Module__c
            FROM Assignment__c
            WHERE Module__c IN :moduleToCourse.keySet()
        ]) {
            if (!assignmentsByModule.containsKey(a.Module__c)) {
                assignmentsByModule.put(a.Module__c, new List<Id>());
            }
            assignmentsByModule.get(a.Module__c).add(a.Id);
        }

        // 4. All scored Submissions for these Enrollments
        // Map: EnrollmentId → Set of AssignmentIds that have Score != null
        Map<Id, Set<Id>> scoredAssignmentsByEnrollment = new Map<Id, Set<Id>>();
        for (Submission__c s : [
            SELECT Enrollment__c, Assignment__c
            FROM Submission__c
            WHERE Enrollment__c IN :enrollmentIds
              AND Score__c != null
        ]) {
            if (!scoredAssignmentsByEnrollment.containsKey(s.Enrollment__c)) {
                scoredAssignmentsByEnrollment.put(s.Enrollment__c, new Set<Id>());
            }
            scoredAssignmentsByEnrollment.get(s.Enrollment__c).add(s.Assignment__c);
        }

        // 5. Calculate progress per Enrollment
        List<Enrollment__c> toUpdate = new List<Enrollment__c>();
        Set<Id> completedEnrollmentIds = new Set<Id>();

        for (Id enrollmentId : enrollmentIds) {
            Id courseId = enrollmentToCourse.get(enrollmentId);
            List<Id> moduleIds = modulesByCourse.containsKey(courseId)
                ? modulesByCourse.get(courseId) : new List<Id>();

            Integer totalModules = moduleIds.size();
            Integer completedModules = 0;

            Set<Id> scoredAssignments = scoredAssignmentsByEnrollment.containsKey(enrollmentId)
                ? scoredAssignmentsByEnrollment.get(enrollmentId) : new Set<Id>();

            for (Id moduleId : moduleIds) {
                List<Id> assignmentIds = assignmentsByModule.containsKey(moduleId)
                    ? assignmentsByModule.get(moduleId) : new List<Id>();

                // Module is completed if it has no assignments OR all its assignments are scored
                Boolean moduleCompleted = true;
                for (Id assignmentId : assignmentIds) {
                    if (!scoredAssignments.contains(assignmentId)) {
                        moduleCompleted = false;
                        break;
                    }
                }
                if (moduleCompleted) {
                    completedModules++;
                }
            }

            Decimal pct = totalModules == 0 ? 0 : (completedModules * 100.0) / totalModules;

            toUpdate.add(new Enrollment__c(
                Id = enrollmentId,
                Progress__c = pct
            ));

            if (pct == 100) {
                completedEnrollmentIds.add(enrollmentId);
            }
        }

        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }

        if (!completedEnrollmentIds.isEmpty()) {
            CertificateService.checkEligibility(completedEnrollmentIds);
        }
    }
}