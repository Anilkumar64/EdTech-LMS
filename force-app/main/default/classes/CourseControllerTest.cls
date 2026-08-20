@isTest
private class CourseControllerTest {
    @isTest
    static void testGetActiveCourses() {
        Instructor__c inst = TestDataFactory.createInstructor();
        TestDataFactory.createCourse(inst.Id);

        Test.startTest();
        List<Course__c> courses = CourseController.getActiveCourses();
        Test.stopTest();

        System.assert(!courses.isEmpty(), 'Should return active courses');
    }
}