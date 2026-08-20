public with sharing class ProgressCalculator {

    public static void recalculateProgress(Set<Id> enrollmentIds) {
        if (enrollmentIds == null || enrollmentIds.isEmpty()) {
            return;
        }

        List<Enrollment__c> enrollmentsToUpdate = new List<Enrollment__c>();
        List<Enrollment__c> enrollments = [
            SELECT Id, Course__c, Progress__c, Status__c
            FROM Enrollment__c
            WHERE Id IN :enrollmentIds
        ];

        Set<Id> courseIds = new Set<Id>();
        for (Enrollment__c enr : enrollments) {
            if (enr.Course__c != null) {
                courseIds.add(enr.Course__c);
            }
        }

        Map<Id, Set<Id>> moduleIdsByCourse = new Map<Id, Set<Id>>();
        Set<Id> moduleIds = new Set<Id>();
        for (Module__c module : [
            SELECT Id, Course__c
            FROM Module__c
            WHERE Course__c IN :courseIds
        ]) {
            if (!moduleIdsByCourse.containsKey(module.Course__c)) {
                moduleIdsByCourse.put(module.Course__c, new Set<Id>());
            }
            moduleIdsByCourse.get(module.Course__c).add(module.Id);
            moduleIds.add(module.Id);
        }

        Map<Id, Set<Id>> assignmentIdsByModule = new Map<Id, Set<Id>>();
        Set<Id> assignmentIds = new Set<Id>();
        for (Assignment__c assignment : [
            SELECT Id, Module__c
            FROM Assignment__c
            WHERE Module__c IN :moduleIds
        ]) {
            if (!assignmentIdsByModule.containsKey(assignment.Module__c)) {
                assignmentIdsByModule.put(assignment.Module__c, new Set<Id>());
            }
            assignmentIdsByModule.get(assignment.Module__c).add(assignment.Id);
            assignmentIds.add(assignment.Id);
        }

        Map<Id, Set<Id>> completedAssignmentIdsByEnrollment = new Map<Id, Set<Id>>();
        for (Submission__c sub : [
            SELECT Enrollment__c, Assignment__c
            FROM Submission__c
            WHERE Enrollment__c IN :enrollmentIds
            AND Assignment__c IN :assignmentIds
            AND Score__c != null
        ]) {
            if (!completedAssignmentIdsByEnrollment.containsKey(sub.Enrollment__c)) {
                completedAssignmentIdsByEnrollment.put(sub.Enrollment__c, new Set<Id>());
            }
            completedAssignmentIdsByEnrollment.get(sub.Enrollment__c).add(sub.Assignment__c);
        }

        List<Id> eligibleForCertificate = new List<Id>();

        for (Enrollment__c enr : enrollments) {
            Set<Id> courseModules = moduleIdsByCourse.get(enr.Course__c);
            Integer total = courseModules == null ? 0 : courseModules.size();
            Integer completed = 0;
            Set<Id> completedAssignments = completedAssignmentIdsByEnrollment.containsKey(enr.Id)
                ? completedAssignmentIdsByEnrollment.get(enr.Id)
                : new Set<Id>();

            if (courseModules != null) {
                for (Id moduleId : courseModules) {
                    Set<Id> moduleAssignments = assignmentIdsByModule.get(moduleId);
                    if (moduleAssignments != null && !moduleAssignments.isEmpty()
                        && completedAssignments.containsAll(moduleAssignments)) {
                        completed++;
                    }
                }
            }

            Decimal pct = (total == null || total == 0) ? 0 : (completed * 100.0 / total);
            enr.Progress__c = pct.setScale(2);

            if (pct == 100) {
                eligibleForCertificate.add(enr.Id);
            }
            enrollmentsToUpdate.add(enr);
        }

        if (!enrollmentsToUpdate.isEmpty()) {
            update enrollmentsToUpdate;
        }

        if (!eligibleForCertificate.isEmpty()) {
            CertificateService.evaluateAndIssue(new Set<Id>(eligibleForCertificate));
        }
    }
}