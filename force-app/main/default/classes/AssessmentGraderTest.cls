@isTest
private class AssessmentGraderTest {

    @isTest
    static void testGradingRunsWithoutError() {
        Course__c course = TestDataFactory.createCourse('Beginner');
        Module__c module1 = TestDataFactory.createModule(course.Id, 1);
        Assignment__c assign = TestDataFactory.createAssignment(module1.Id);
        Contact student = TestDataFactory.createStudent();
        Enrollment__c enr = TestDataFactory.createEnrollment(student.Id, course.Id);
        Submission__c sub = TestDataFactory.createSubmission(assign.Id, enr.Id, null);

        Test.startTest();
        AssessmentGrader.gradeSubmission(sub.Id);
        Test.stopTest();

        Submission__c result = [SELECT Score__c FROM Submission__c WHERE Id = :sub.Id];
        System.assertNotEquals(null, result.Score__c, 'Score should be set after grading');
    }
}