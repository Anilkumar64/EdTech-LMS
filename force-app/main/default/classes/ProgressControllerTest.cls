@isTest
private class ProgressControllerTest {
    @isTest
    static void testGetEnrollmentProgress() {
        Instructor__c inst = TestDataFactory.createInstructor();
        Course__c course = TestDataFactory.createCourse(inst.Id);
        Contact student = TestDataFactory.createStudent();
        Enrollment__c enroll = TestDataFactory.createEnrollment(student.Id, course.Id);

        Test.startTest();
        Map<String, Object> result = ProgressController.getEnrollmentProgress(enroll.Id);
        Test.stopTest();

        System.assertNotEquals(null, result.get('progress'));
    }
}