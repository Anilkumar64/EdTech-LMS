@isTest
private class SubmissionTriggerTest {

    @TestSetup
    static void setup() {
        Instructor__c inst = TestDataFactory.createInstructor();
        Course__c course = TestDataFactory.createCourse(inst.Id);
        Module__c mod = TestDataFactory.createModule(course.Id);
        TestDataFactory.createAssignment(mod.Id);
        Contact student = TestDataFactory.createStudent();
        TestDataFactory.createEnrollment(student.Id, course.Id);
    }

    @isTest
    static void testScoreInsertRecalculatesProgress() {
        Assignment__c assignment = [SELECT Id FROM Assignment__c LIMIT 1];
        Enrollment__c enrollment = [SELECT Id, Progress__c FROM Enrollment__c LIMIT 1];

        Test.startTest();
        TestDataFactory.createSubmission(assignment.Id, enrollment.Id, 90);
        Test.stopTest();

        Enrollment__c updated = [SELECT Progress__c FROM Enrollment__c WHERE Id = :enrollment.Id];
        System.assertEquals(100, updated.Progress__c);
    }

    @isTest
    static void testScoreUpdateTriggersRecalc() {
        Assignment__c assignment = [SELECT Id FROM Assignment__c LIMIT 1];
        Enrollment__c enrollment = [SELECT Id FROM Enrollment__c LIMIT 1];
        Submission__c sub = TestDataFactory.createSubmission(assignment.Id, enrollment.Id, null);

        Test.startTest();
        sub.Score__c = 75;
        update sub;
        Test.stopTest();

        Enrollment__c updated = [SELECT Progress__c FROM Enrollment__c WHERE Id = :enrollment.Id];
        System.assertEquals(100, updated.Progress__c);
    }

    @isTest
    static void testUnrelatedFieldUpdateDoesNotErrorOut() {
        Assignment__c assignment = [SELECT Id FROM Assignment__c LIMIT 1];
        Enrollment__c enrollment = [SELECT Id FROM Enrollment__c LIMIT 1];
        Submission__c sub = TestDataFactory.createSubmission(assignment.Id, enrollment.Id, 50);

        Test.startTest();
        sub.Feedback__c = 'Good effort';
        update sub;
        Test.stopTest();

        System.assert(true);
    }

    @isTest
    static void testBulkInsertOfSubmissionsIsSafe() {
        Assignment__c assignment = [SELECT Id FROM Assignment__c LIMIT 1];
        Enrollment__c enrollment = [SELECT Id FROM Enrollment__c LIMIT 1];

        List<Submission__c> bulkSubs = new List<Submission__c>();
        for (Integer i = 0; i < 200; i++) {
            bulkSubs.add(new Submission__c(
                Assignment__c = assignment.Id,
                Enrollment__c = enrollment.Id,
                Score__c = 80
            ));
        }

        Test.startTest();
        insert bulkSubs;
        Test.stopTest();

        System.assert(true);
    }
}