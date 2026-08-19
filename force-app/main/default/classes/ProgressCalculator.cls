public with sharing class ProgressCalculator {

    /**
     * Recalculates Enrollment__c.Progress__c as % of modules fully completed
     * (all assignments in the module have a scored submission for that enrollment).
     * When progress reaches 100, delegates to CertificateService.
     */
    public static void recalculateProgress(Set<Id> enrollmentIds) {
        if (enrollmentIds == null || enrollmentIds.isEmpty()) {
            return;
        }

        List<Enrollment__c> enrollments = [
            SELECT Id, Course__c, Progress__c, Status__c
            FROM Enrollment__c
            WHERE Id IN :enrollmentIds
        ];
        if (enrollments.isEmpty()) {
            return;
        }

        Set<Id> courseIds = new Set<Id>();
        for (Enrollment__c enr : enrollments) {
            if (enr.Course__c != null) {
                courseIds.add(enr.Course__c);
            }
        }

        Map<Id, Set<Id>> moduleIdsByCourse = new Map<Id, Set<Id>>();
        Set<Id> moduleIds = new Set<Id>();
        if (!courseIds.isEmpty()) {
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
        }

        Map<Id, Set<Id>> assignmentIdsByModule = new Map<Id, Set<Id>>();
        Set<Id> assignmentIds = new Set<Id>();
        if (!moduleIds.isEmpty()) {
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
        }

        Map<Id, Set<Id>> completedAssignmentIdsByEnrollment = new Map<Id, Set<Id>>();
        if (!assignmentIds.isEmpty()) {
            for (Submission__c sub : [
                SELECT Enrollment__c, Assignment__c
                FROM Submission__c
                WHERE Enrollment__c IN :enrollmentIds
                AND Assignment__c IN :assignmentIds
                AND Score__c != null
            ]) {
                if (sub.Enrollment__c == null || sub.Assignment__c == null) {
                    continue;
                }
                if (!completedAssignmentIdsByEnrollment.containsKey(sub.Enrollment__c)) {
                    completedAssignmentIdsByEnrollment.put(sub.Enrollment__c, new Set<Id>());
                }
                completedAssignmentIdsByEnrollment.get(sub.Enrollment__c).add(sub.Assignment__c);
            }
        }

        List<Enrollment__c> enrollmentsToUpdate = new List<Enrollment__c>();
        List<Id> eligibleForCertificate = new List<Id>();

        for (Enrollment__c enr : enrollments) {
            Set<Id> courseModules = moduleIdsByCourse.get(enr.Course__c);
            Integer total = (courseModules == null) ? 0 : courseModules.size();
            Integer completed = 0;
            Set<Id> completedAssignments = completedAssignmentIdsByEnrollment.containsKey(enr.Id)
                ? completedAssignmentIdsByEnrollment.get(enr.Id)
                : new Set<Id>();

            if (courseModules != null) {
                for (Id moduleId : courseModules) {
                    Set<Id> moduleAssignments = assignmentIdsByModule.get(moduleId);
                    if (moduleAssignments != null
                        && !moduleAssignments.isEmpty()
                        && completedAssignments.containsAll(moduleAssignments)) {
                        completed++;
                    }
                }
            }

            Decimal pct = (total == 0) ? 0 : (completed * 100.0 / total);
            pct = pct.setScale(2);
            enr.Progress__c = pct;

            if (pct >= 100) {
                eligibleForCertificate.add(enr.Id);
                if (enr.Status__c != 'Completed') {
                    enr.Status__c = 'Completed';
                }
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
