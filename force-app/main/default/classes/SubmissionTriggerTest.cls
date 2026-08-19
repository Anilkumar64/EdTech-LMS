@isTest
private class SubmissionTriggerTest {

    @isTest
    static void testProgressRecalculatesOnScore() {
        Contact student = TestDataFactory.createStudent();
        Course__c course = TestDataFactory.createCourse('Beginner');
        Module__c module1 = TestDataFactory.createModule(course.Id, 1);
        Enrollment__c enr = TestDataFactory.createEnrollment(student.Id, course.Id);
        Assignment__c assign = TestDataFactory.createAssignment(module1.Id);

        Test.startTest();
        Submission__c sub = TestDataFactory.createSubmission(assign.Id, enr.Id, 90);
        Test.stopTest();

        Enrollment__c updated = [SELECT Progress__c FROM Enrollment__c WHERE Id = :enr.Id];
        System.assertEquals(100, updated.Progress__c, 'Progress should be 100% with 1 of 1 modules complete');
    }

    @isTest
    static void testNoRecalcWhenScoreNull() {
        Contact student = TestDataFactory.createStudent();
        Course__c course = TestDataFactory.createCourse('Beginner');
        Module__c module1 = TestDataFactory.createModule(course.Id, 1);
        Enrollment__c enr = TestDataFactory.createEnrollment(student.Id, course.Id);
        Assignment__c assign = TestDataFactory.createAssignment(module1.Id);

        Test.startTest();
        Submission__c sub = new Submission__c(
            Assignment__c = assign.Id,
            Enrollment__c = enr.Id,
            Submitted_On__c = System.now()
        );
        insert sub;
        Test.stopTest();

        Enrollment__c updated = [SELECT Progress__c FROM Enrollment__c WHERE Id = :enr.Id];
        System.assertEquals(0, updated.Progress__c == null ? 0 : updated.Progress__c, 'Progress should stay 0 with no score');
    }
}