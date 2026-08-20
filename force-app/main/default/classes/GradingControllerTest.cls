@isTest
private class GradingControllerTest {

    @isTest
    static void testGetAndSave() {
        Instructor__c inst = TestDataFactory.createInstructor();
        Course__c course = TestDataFactory.createCourse(inst.Id);
        Module__c mod = TestDataFactory.createModule(course.Id);
        Assignment__c assign = TestDataFactory.createAssignment(mod.Id);
        Contact student = TestDataFactory.createStudent();
        Enrollment__c enroll = TestDataFactory.createEnrollment(student.Id, course.Id);
        Submission__c sub = TestDataFactory.createSubmission(assign.Id, enroll.Id, null);

        Test.startTest();
        List<Submission__c> listResult = GradingController.getSubmissionsForAssignment(assign.Id);
        GradingController.saveGrade(sub.Id, 85, 'Good work');
        Test.stopTest();

        System.assertEquals(1, listResult.size());
        Submission__c updated = [SELECT Score__c FROM Submission__c WHERE Id = :sub.Id];
        System.assertEquals(85, updated.Score__c);
    }
}