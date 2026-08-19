@isTest
public class TestDataFactory {

    public static Contact createStudent() {
        Contact c = new Contact(
            LastName = 'TestStudent',
            Email = 'student@test.com',
            MobilePhone = '+15555550123'
        );
        insert c;
        return c;
    }

    public static Course__c createCourse(String level) {
        Course__c c = new Course__c(
            Name = 'Test Course ' + level,
            Level__c = level,
            Duration_Hours__c = 40,
            Price__c = 999,
            Status__c = 'Active'
        );
        insert c;
        return c;
    }

    public static Module__c createModule(Id courseId, Integer orderVal) {
        Module__c m = new Module__c(
            Name = 'Module ' + orderVal,
            Course__c = courseId,
            Title__c = 'Module ' + orderVal,
            Order__c = orderVal
        );
        insert m;
        return m;
    }

    public static Enrollment__c createEnrollment(Id studentId, Id courseId) {
        Enrollment__c e = new Enrollment__c(
            Name = 'Enrollment ' + String.valueOf(System.now().getTime()),
            Student__c = studentId,
            Course__c = courseId,
            Status__c = 'Active',
            Payment_Status__c = 'Paid',
            Enrollment_Date__c = System.today(),
            Progress__c = 0
        );
        insert e;
        return e;
    }

    public static Assignment__c createAssignment(Id moduleId) {
        Assignment__c a = new Assignment__c(
            Name = 'Test Assignment',
            Module__c = moduleId,
            Title__c = 'Test Assignment',
            Max_Score__c = 100,
            Due_Date__c = System.now().addDays(7),
            Submission_Type__c = 'Text'
        );
        insert a;
        return a;
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
