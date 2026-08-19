public with sharing class AssessmentGrader {

    /**
     * Auto-grades an MCQ submission by comparing Student_Answers__c (JSON map of questionId -> answer)
     * against Assessment_Answer_Key__mdt for the related course name.
     * Sets Score__c as percentage correct and Assessment_Passed__c based on pass percentage.
     */
    public static void gradeSubmission(Id submissionId) {
        if (submissionId == null) {
            return;
        }

        List<Submission__c> rows = [
            SELECT Id, Score__c, Student_Answers__c, Assessment_Passed__c,
                   Assignment__r.Module__r.Course__r.Name,
                   Assignment__r.Module__r.Course__c
            FROM Submission__c
            WHERE Id = :submissionId
            LIMIT 1
        ];
        if (rows.isEmpty()) {
            return;
        }
        Submission__c sub = rows[0];

        String courseName = sub.Assignment__r != null
            && sub.Assignment__r.Module__r != null
            && sub.Assignment__r.Module__r.Course__r != null
            ? sub.Assignment__r.Module__r.Course__r.Name
            : null;

        List<Assessment_Answer_Key__mdt> answerKeys = new List<Assessment_Answer_Key__mdt>();
        if (String.isNotBlank(courseName)) {
            answerKeys = [
                SELECT Question_Id__c, Correct_Answer__c
                FROM Assessment_Answer_Key__mdt
                WHERE Assessment_Name__c = :courseName
            ];
        }

        Integer totalQuestions = answerKeys.size();
        Integer correctCount = 0;

        Map<String, String> studentAnswers = parseStudentAnswers(sub.Student_Answers__c);

        for (Assessment_Answer_Key__mdt key : answerKeys) {
            String studentAnswer = studentAnswers.get(key.Question_Id__c);
            if (studentAnswer != null
                && key.Correct_Answer__c != null
                && studentAnswer.trim().equalsIgnoreCase(key.Correct_Answer__c.trim())) {
                correctCount++;
            }
        }

        Decimal pct = totalQuestions == 0 ? 0 : (correctCount * 100.0 / totalQuestions);
        sub.Score__c = pct.setScale(0);

        Decimal passPct = getPassPercentage(sub.Assignment__r.Module__r.Course__c, courseName);
        sub.Assessment_Passed__c = pct >= passPct;

        update sub;
    }

    private static Map<String, String> parseStudentAnswers(String raw) {
        Map<String, String> result = new Map<String, String>();
        if (String.isBlank(raw)) {
            return result;
        }
        try {
            // Expect JSON object: {"Q1":"A","Q2":"B"}
            Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(raw);
            for (String key : parsed.keySet()) {
                Object val = parsed.get(key);
                if (val != null) {
                    result.put(key, String.valueOf(val));
                }
            }
        } catch (Exception e) {
            // Fallback: pipe-delimited Q1=A|Q2=B
            for (String pair : raw.split('\\|')) {
                List<String> parts = pair.split('=', 2);
                if (parts.size() == 2) {
                    result.put(parts[0].trim(), parts[1].trim());
                }
            }
        }
        return result;
    }

    private static Decimal getPassPercentage(Id courseId, String courseName) {
        // Prefer Assessment__c on the course, then CMDT Assessment_Config__mdt, default 70
        if (courseId != null) {
            List<Assessment__c> assessments = [
                SELECT Pass_Percentage__c
                FROM Assessment__c
                WHERE Course__c = :courseId
                LIMIT 1
            ];
            if (!assessments.isEmpty() && assessments[0].Pass_Percentage__c != null) {
                return assessments[0].Pass_Percentage__c;
            }
        }
        try {
            List<Assessment_Config__mdt> configs = [
                SELECT Pass_Percentage__c
                FROM Assessment_Config__mdt
                WHERE MasterLabel = :courseName OR DeveloperName = 'Default'
                ORDER BY DeveloperName
                LIMIT 1
            ];
            if (!configs.isEmpty() && configs[0].Pass_Percentage__c != null) {
                return configs[0].Pass_Percentage__c;
            }
        } catch (Exception e) {
            // CMDT may not exist in all orgs
        }
        return 70;
    }
}
