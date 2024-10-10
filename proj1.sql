-------------------------
-- Project 1 Solution
-- COMP9311 24T3
-- Name: 
-- zID: 
-------------------------
-- Q1
DROP VIEW IF EXISTS Q1 CASCADE;

CREATE OR REPLACE VIEW Q1(count) AS
-- SQL query
SELECT
    COUNT(DISTINCT t2.student)
FROM (
    SELECT
        student,
        mark
    FROM
        course_enrolments ce
        INNER JOIN (
            SELECT
                c.id,
                s.code
            FROM
                courses c,
                subjects s
            WHERE
                s.code LIKE 'COMP%'
                AND s.id = c.subject) t1 ON ce.course = t1.id) t2
WHERE
    t2.mark > 85;

-- Q2
DROP VIEW IF EXISTS Q2 CASCADE;

CREATE OR REPLACE VIEW Q2(count) AS
-- SQL query
WITH course_subjects AS (
    SELECT
        c.id,
        s.code
    FROM
        courses c
        INNER JOIN subjects s ON s.id = c.subject
    WHERE
        s.code LIKE 'COMP%'
),
enrolled_students AS (
    SELECT
        ce.student,
        ce.mark
    FROM
        course_enrolments ce
        INNER JOIN course_subjects cs ON ce.course = cs.id
    WHERE
        ce.mark IS NOT NULL
),
student_comp AS (
    SELECT
        es.student,
        AVG(es.mark) AS avg
    FROM
        enrolled_students es
    GROUP BY
        es.student
    HAVING
        AVG(es.mark) > 85
)
SELECT
    COUNT(sc.student)
FROM
    student_comp sc;

-- Q3
DROP VIEW IF EXISTS Q3 CASCADE;

CREATE OR REPLACE VIEW Q3(unswid, name) AS
WITH enrolled_students AS (
    SELECT
        ce.student,
        ce.mark
    FROM
        course_enrolments ce,
        subjects s,
        courses c
    WHERE
        s.code LIKE 'COMP%'
        AND s.id = c.subject
        AND ce.course = c.id
        AND ce.mark IS NOT NULL
),
enrolled_comp_lt_6 AS (
    SELECT
        es.student,
        COUNT(*)
    FROM
        enrolled_students es
    GROUP BY
        es.student
    HAVING
        COUNT(*) >= 6
),
enrolled_comp_avg AS (
    SELECT
        es.student,
        AVG(es.mark) AS avg
    FROM
        enrolled_students es
    GROUP BY
        es.student
    HAVING
        AVG(es.mark) > 85
),
student_ids AS (
    SELECT
        student AS id
    FROM
        enrolled_comp_lt_6
    INTERSECT
    SELECT
        student
    FROM
        enrolled_comp_avg
)
SELECT
    p.unswid,
    p.name
FROM
    students st,
    people p,
    student_ids un
WHERE
    st.id = p.id
    AND un.id = st.id
ORDER BY
    p.unswid ASC;

-- Q4
DROP VIEW IF EXISTS Q4 CASCADE;

CREATE OR REPLACE VIEW Q4(unswid, name) AS
WITH enrolled_students_raw AS (
    SELECT
        ce.student,
        ce.mark,
        c.subject,
        s.uoc
    FROM
        course_enrolments ce,
        subjects s,
        courses c
    WHERE
        s.code LIKE 'COMP%'
        AND s.id = c.subject
        AND ce.course = c.id
        AND ce.mark IS NOT NULL
),
enrolled_students AS (
    SELECT
        esr1.student,
        esr1.mark,
        esr1.subject,
        esr1.uoc
    FROM
        enrolled_students_raw esr1
        LEFT JOIN enrolled_students_raw esr2 ON esr1.student = esr2.student
            AND esr1.subject = esr2.subject
    WHERE
        esr2.mark IS NULL
        OR esr1.mark >= esr2.mark
),
enrolled_comp_lt_6 AS (
    SELECT
        es.student,
        COUNT(DISTINCT es.subject) AS subject_count
    FROM
        enrolled_students es
    GROUP BY
        es.student
    HAVING
        COUNT(DISTINCT es.subject) >= 6
),
comp_wam_lt_85 AS (
    SELECT
        es.student,
        SUM((es.mark * es.uoc)::float) / SUM(es.uoc)
    FROM
        enrolled_students es
    GROUP BY
        es.student
    HAVING
        SUM((es.mark * es.uoc)::float) / SUM(es.uoc) > 85
),
student_ids AS (
    SELECT
        student AS id
    FROM
        enrolled_comp_lt_6
    INTERSECT
    SELECT
        student
    FROM
        comp_wam_lt_85
)
SELECT
    p.unswid,
    p.name
FROM
    students st
    JOIN people p ON st.id = p.id
    JOIN student_ids un ON un.id = st.id
ORDER BY
    p.unswid ASC;

-- Q5
DROP VIEW IF EXISTS Q5 CASCADE;

CREATE OR REPLACE VIEW Q5(count) AS
-- SQL query
WITH cse_courses_in_2012 AS (
    SELECT
        s.id
    FROM
        subjects s
        JOIN orgunits o ON s.offeredby = o.id
        JOIN courses c ON c.subject = s.id
        JOIN semesters sem ON c.semester = sem.id
    WHERE
        o.longname = 'School of Computer Science and Engineering'
        AND sem.year = 2012
)
SELECT
    COUNT(DISTINCT id)
FROM
    cse_courses_in_2012;

-- Q6
DROP VIEW IF EXISTS Q6 CASCADE;

CREATE OR REPLACE VIEW Q6(count) AS
-- SQL query
WITH course_hold_in_2012 AS (
    SELECT
        courses.id
    FROM
        courses,
        semesters
    WHERE
        courses.semester = semesters.id
        AND semesters.year = 2012
),
all_ces_staff AS (
    SELECT
        staff
    FROM
        affiliations,
        orgunits
    WHERE
        affiliations.orgunit = orgunits.id
        AND orgunits.longname = 'School of Computer Science and Engineering'
),
course_ces_staff AS (
    SELECT
        course_staff.staff
    FROM
        all_ces_staff,
        course_staff,
        staff_roles,
        course_hold_in_2012
    WHERE
        course_hold_in_2012.id = course_staff.course
        AND all_ces_staff.staff = course_staff.staff
        AND course_staff.role = staff_roles.id
        AND staff_roles.name = 'Course Lecturer'
)
SELECT
    COUNT(DISTINCT course_ces_staff.staff)
FROM
    course_ces_staff;

-- Q7
DROP VIEW IF EXISTS Q7 CASCADE;

CREATE OR REPLACE VIEW Q7(course_id, unswid) AS
-- SQL query
WITH course_hold_in_2012 AS (
    SELECT DISTINCT
        c.id
    FROM
        subjects s
        JOIN orgunits o ON s.offeredby = o.id
        JOIN courses c ON c.subject = s.id
        JOIN semesters sem ON c.semester = sem.id
    WHERE
        o.longname = 'School of Computer Science and Engineering'
        AND sem.year = 2012
),
all_ces_staff AS (
    SELECT
        staff
    FROM
        affiliations,
        orgunits
    WHERE
        affiliations.orgunit = orgunits.id
        AND orgunits.longname = 'School of Computer Science and Engineering'
),
course_ces_staff AS (
    SELECT
        course_staff.staff,
        course_staff.course,
        people.unswid
    FROM
        course_hold_in_2012
        JOIN course_staff ON course_hold_in_2012.id = course_staff.course
        JOIN all_ces_staff ON all_ces_staff.staff = course_staff.staff
        JOIN staff_roles ON course_staff.role = staff_roles.id
        JOIN people ON people.id = all_ces_staff.staff
    WHERE
        staff_roles.name = 'Course Lecturer'
)
SELECT DISTINCT
    course,
    unswid
FROM
    course_ces_staff;

-- Q8
DROP VIEW IF EXISTS Q8 CASCADE;

CREATE OR REPLACE VIEW Q8(course_id, unswid) AS
-- SQL query
WITH course_hold_in_2012 AS (
    SELECT DISTINCT
        c.id
    FROM
        subjects s
        JOIN orgunits o ON s.offeredby = o.id
        JOIN courses c ON c.subject = s.id
        JOIN semesters sem ON c.semester = sem.id
    WHERE
        o.longname = 'School of Computer Science and Engineering'
        AND sem.year = 2012
),
cse_affiliation_id AS (
    SELECT DISTINCT
        affiliations.orgunit
    FROM
        affiliations,
        orgunits
    WHERE
        affiliations.orgunit = orgunits.id
        AND orgunits.longname = 'School of Computer Science and Engineering'
),
cse_courses_lecturers AS (
    SELECT
        course_staff.staff,
        course_staff.course,
        people.unswid,
        affiliations.orgunit
    FROM
        course_hold_in_2012
        JOIN course_staff ON course_hold_in_2012.id = course_staff.course
        JOIN staff_roles ON course_staff.role = staff_roles.id
        JOIN people ON people.id = course_staff.staff
        JOIN affiliations ON affiliations.staff = course_staff.staff
    WHERE
        staff_roles.name = 'Course Lecturer'
),
cse_courses_only_from_cse_lecturers AS (
    SELECT
        unswid,
        course,
        orgunit
    FROM
        cse_courses_lecturers c
    WHERE
        c.orgunit IN (
            SELECT
                orgunit
            FROM
                cse_affiliation_id))
SELECT
    course,
    unswid
FROM
    cse_courses_only_from_cse_lecturers;

-- Q9
DROP FUNCTION IF EXISTS Q9 CASCADE;

CREATE OR REPLACE FUNCTION Q9(subject1 integer, subject2 integer)
    RETURNS text
    AS $$
    --Function body
DECLARE
    _is_pre_course boolean := FALSE;
    _course_text text := '';
    _subject1_code text := 'NULL';
BEGIN
    SELECT
        code INTO _subject1_code
    FROM
        subjects
    WHERE
        id = $1;
        SELECT
            _prereq INTO _course_text
        FROM
            subjects
        WHERE
            id = $2
            AND char_length(_prereq) > 0;
            IF position(_subject1_code IN _course_text) > 0 THEN
                _is_pre_course := TRUE;
            END IF;
            IF _is_pre_course THEN
                RETURN format('%s is a direct prerequisite of %s.', subject1::text, subject2::text);
            ELSE
                RETURN format('%s is not a direct prerequisite of %s.', subject1::text, subject2::text);
            END IF;
END
$$
LANGUAGE plpgsql;

-- Q10
CREATE OR REPLACE FUNCTION IsCodeContained(course_codes text[], content text)
    RETURNS text[]
    AS $$
DECLARE
    codes_contained text[];
    code text;
BEGIN
    FOREACH code IN ARRAY course_codes LOOP
        IF position(code IN content) > 0 THEN
            codes_contained := array_append(codes_contained, code);
        END IF;
    END LOOP;
    RETURN codes_contained;
END;
$$
LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS Q10 CASCADE;

CREATE OR REPLACE FUNCTION Q10(subject1 integer, subject2 integer)
    RETURNS text
    AS $$
    --Function body
DECLARE
    _is_pre_course boolean := FALSE;
    _course_text text := '';
    _subject1_code text := 'NULL';
    _all_code_list text[];
    _desc_code_list text[];
    _temp_code_list text[];
    _temp_code text := 0;
BEGIN
    SELECT
        code INTO _subject1_code
    FROM
        subjects
    WHERE
        id = $1;
        SELECT
            _prereq INTO _course_text
        FROM
            subjects
        WHERE
            id = $2
            AND char_length(_prereq) > 0;
            -- find all course codes
            SELECT
                ARRAY_AGG(code) INTO _all_code_list
            FROM
                subjects;
                -- find codes from description
                _desc_code_list := IsCodeContained(_all_code_list, _course_text);
                -- search
                LOOP
                    -- exit cond.
                    IF array_length(_desc_code_list, 1) IS NULL THEN
                        EXIT;
                    END IF;
                    -- deque element
                    _temp_code := _desc_code_list[1];
                    _desc_code_list := _desc_code_list[2:array_length(_desc_code_list, 1)];
                    -- get course description
                    SELECT
                        _prereq INTO _course_text
                    FROM
                        subjects
                    WHERE
                        code = _temp_code;
                        -- find codes from description
                        _temp_code_list := IsCodeContained(_all_code_list, _course_text);
                        -- if _subject1_code in description
                        IF ARRAY[_subject1_code] <@ _temp_code_list OR ARRAY[_subject1_code] <@ _desc_code_list THEN
                            _is_pre_course := TRUE;
                            EXIT;
                        END IF;
                        -- add course codes to desc_code_list
                        _desc_code_list := array_cat(_desc_code_list, _temp_code_list);
                END LOOP;
                IF _is_pre_course THEN
                    RETURN format('%s is a prerequisite of %s.', subject1::text, subject2::text);
                ELSE
                    RETURN format('%s is not a prerequisite of %s.', subject1::text, subject2::text);
                END IF;
END
$$
LANGUAGE plpgsql;

