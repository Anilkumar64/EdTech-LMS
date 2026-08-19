@IsTest
private class ProgressCalculatorTest {

    @IsTest
    static void calculatesOneHundredPercent() {
        LmsTestDataFactory.Scenario data = LmsTestDataFactory.createScenario('PC1', 2, 1, false);

        Test.startTest();
        insert LmsTestDataFactory.buildScoredSubmissions(data, 100);
        Test.stopTest();

        Enrollment__c enrollment = [SELECT Progress__c FROM Enrollment__c WHERE Id = :data.enrollment.Id];
        System.assertEquals(100, enrollment.Progress__c);
    }

    @IsTest
    static void calculatesPartialProgress() {
        LmsTestDataFactory.Scenario data = LmsTestDataFactory.createScenario('PC2', 5, 1, false);
        List<Submission__c> submissions = new List<Submission__c>();
        for (Integer i = 0; i < 3; i++) {
            submissions.add(new Submission__c(
                Assignment__c = data.assignments[i].Id,
                Enrollment__c = data.enrollment.Id,
                Score__c = 100
            ));
        }

        Test.startTest();
        insert submissions;
        Test.stopTest();

        Enrollment__c enrollment = [SELECT Progress__c FROM Enrollment__c WHERE Id = :data.enrollment.Id];
        System.assertEquals(60, enrollment.Progress__c);
    }

    @IsTest
    static void calculatesZeroWhenNoModulesOrNoAssignments() {
        LmsTestDataFactory.Scenario noModules = LmsTestDataFactory.createScenario('PC3', 0, 0, false);
        LmsTestDataFactory.Scenario noAssignments = LmsTestDataFactory.createScenario('PC4', 2, 0, false);

        Test.startTest();
        ProgressCalculator.recalculateProgress(new Set<Id>{ noModules.enrollment.Id, noAssignments.enrollment.Id });
        Test.stopTest();

        Set<Id> enrollmentIds = new Set<Id>{ noModules.enrollment.Id, noAssignments.enrollment.Id };
        Map<Id, Enrollment__c> enrollments = new Map<Id, Enrollment__c>([
            SELECT Progress__c
            FROM Enrollment__c
            WHERE Id IN :enrollmentIds
        ]);
        System.assertEquals(0, enrollments.get(noModules.enrollment.Id).Progress__c);
        System.assertEquals(0, enrollments.get(noAssignments.enrollment.Id).Progress__c);
    }

    @IsTest
    static void supportsMultipleEnrollments() {
        LmsTestDataFactory.Scenario first = LmsTestDataFactory.createScenario('PC5A', 2, 1, false);
        LmsTestDataFactory.Scenario second = LmsTestDataFactory.createScenario('PC5B', 2, 1, false);
        List<Submission__c> submissions = LmsTestDataFactory.buildScoredSubmissions(first, 100);
        submissions.add(new Submission__c(
            Assignment__c = second.assignments[0].Id,
            Enrollment__c = second.enrollment.Id,
            Score__c = 100
        ));

        Test.startTest();
        insert submissions;
        Test.stopTest();

        Set<Id> enrollmentIds = new Set<Id>{ first.enrollment.Id, second.enrollment.Id };
        Map<Id, Enrollment__c> enrollments = new Map<Id, Enrollment__c>([
            SELECT Progress__c
            FROM Enrollment__c
            WHERE Id IN :enrollmentIds
        ]);
        System.assertEquals(100, enrollments.get(first.enrollment.Id).Progress__c);
        System.assertEquals(50, enrollments.get(second.enrollment.Id).Progress__c);
    }
}
