@isTest
public class TestDataFactory {

    public static Instructor__c createInstructor() {
        Instructor__c inst = new Instructor__c(
            Qualification__c = 'M.Tech CS',
            Rating__c = 4.5
        );
        insert inst;
        return inst;
    }

    public static Course__c createCourse(Id instructorId) {
        Course__c course = new Course__c(
            Name = 'Test Course',
            Level__c = 'Beginner',
            Duration_Hours__c = 20,
            Price__c = 999,
            Instructor__c = instructorId,
            Status__c = 'Active'
        );
        insert course;
        return course;
    }

    public static Module__c createModule(Id courseId) {
        Module__c mod = new Module__c(
            Course__c = courseId,
            Order__c = 1,
            Title__c = 'Module 1'
        );
        insert mod;
        return mod;
    }

    public static Assignment__c createAssignment(Id moduleId) {
        Assignment__c a = new Assignment__c(
            Module__c = moduleId,
            Title__c = 'Test Assignment',
            Max_Score__c = 100,
            Due_Date__c = Date.today().addDays(7),
            Submission_Type__c = 'Text'
        );
        insert a;
        return a;
    }

    public static Contact createStudent() {
        Contact c = new Contact(
            FirstName = 'Test',
            LastName = 'Student',
            Email = 'teststudent@example.com'
        );
        insert c;
        return c;
    }

public static Enrollment__c createEnrollment(Id studentId, Id courseId) {
    Enrollment__c e = new Enrollment__c(
        Student__c = studentId,
        Course__c = courseId,
        Status__c = 'Active',
        Payment_Status__c = 'Paid',
        Enrollment_Date__c = Date.today()
    );
    insert e;
    return e;
}

    public static Submission__c createSubmission(Id assignmentId, Id enrollmentId, Decimal score) {
        Submission__c s = new Submission__c(
            Assignment__c = assignmentId,
            Enrollment__c = enrollmentId,
            Score__c = score,
            Submitted_On__c = System.now()
        );
        insert s;
        return s;
    }
}