@IsTest
public class LmsTestDataFactory {
    public class Scenario {
        public Contact student;
        public Course__c course;
        public List<Module__c> modules = new List<Module__c>();
        public List<Assignment__c> assignments = new List<Assignment__c>();
        public Enrollment__c enrollment;
        public Assessment__c assessment;
    }

    public static Scenario createScenario(String token, Integer moduleCount, Integer assignmentsPerModule, Boolean withAssessment) {
        Scenario data = new Scenario();
        data.student = new Contact(
            LastName = 'Student ' + token,
            Email = 'student.' + token.toLowerCase() + '@example.com',
            MobilePhone = '+15555550100'
        );
        insert data.student;

        data.course = new Course__c(
            Name = 'Course ' + token,
            Status__c = 'Active'
        );
        insert data.course;

        for (Integer moduleIndex = 0; moduleIndex < moduleCount; moduleIndex++) {
            data.modules.add(new Module__c(
                Name = 'Module ' + token + ' ' + moduleIndex,
                Title__c = 'Module ' + token + ' ' + moduleIndex,
                Course__c = data.course.Id,
                Order__c = moduleIndex + 1
            ));
        }
        if (!data.modules.isEmpty()) {
            insert data.modules;
        }

        for (Module__c moduleRecord : data.modules) {
            for (Integer assignmentIndex = 0; assignmentIndex < assignmentsPerModule; assignmentIndex++) {
                data.assignments.add(new Assignment__c(
                    Name = 'Assignment ' + token + ' ' + moduleRecord.Order__c + '.' + assignmentIndex,
                    Title__c = 'Assignment ' + token + ' ' + moduleRecord.Order__c + '.' + assignmentIndex,
                    Module__c = moduleRecord.Id,
                    Max_Score__c = 100,
                    Due_Date__c = System.now().addDays(7),
                    Submission_Type__c = 'Text',
                    Status__c = 'Published'
                ));
            }
        }
        if (!data.assignments.isEmpty()) {
            insert data.assignments;
        }

        data.enrollment = new Enrollment__c(
            Name = 'Enrollment ' + token,
            Student__c = data.student.Id,
            Course__c = data.course.Id,
            Enrollment_Date__c = Date.today(),
            Payment_Status__c = 'Paid',
            Status__c = 'Active'
        );
        insert data.enrollment;

        if (withAssessment) {
            data.assessment = new Assessment__c(
                Name = 'TEST_ASSESSMENT_FULL',
                Course__c = data.course.Id,
                Pass_Percentage__c = 70,
                Total_Questions__c = 3
            );
            insert data.assessment;
        }

        return data;
    }

    public static List<Submission__c> buildScoredSubmissions(Scenario data, Decimal score) {
        List<Submission__c> submissions = new List<Submission__c>();
        for (Assignment__c assignmentRecord : data.assignments) {
            submissions.add(new Submission__c(
                Assignment__c = assignmentRecord.Id,
                Enrollment__c = data.enrollment.Id,
                Score__c = score,
                Submitted_On__c = System.now()
            ));
        }
        return submissions;
    }
}