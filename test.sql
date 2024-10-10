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
    -- 找出所有code 来
    SELECT
        ARRAY_AGG(code) INTO _all_code_list
    FROM
        subjects;
    _desc_code_list := IsCodeContained(_all_code_list, _course_text);
    -- 查看subject2 的prereq 中涉及到的code
    LOOP
        -- 空退出
        IF array_length(_desc_code_list, 1) IS NULL THEN
            EXIT;
        END IF;
        -- 取出元素
        _temp_code := _desc_code_list[1];
        _desc_code_list := _desc_code_list[2:array_length(_desc_code_list, 1)];
        -- 找content
        SELECT
            _prereq INTO _course_text
        FROM
            subjects
        WHERE
            code = _temp_code;
        -- 这个元素的content 有啥
        _temp_code_list := IsCodeContained(_all_code_list, _course_text);
        -- 两个数组取交集
        IF ARRAY[_subject1_code] <@ _temp_code_list OR ARRAY[_subject1_code] <@ _desc_code_list THEN
            _is_pre_course := TRUE;
            EXIT;
        END IF;
        -- 加入到desc_code_list
        _desc_code_list := array_cat(_desc_code_list, _temp_code_list);
        --RAISE INFO '!!! _desc_code_list %. %', _desc_code_list, array_length(_desc_code_list, 1);
    END LOOP;
    IF _is_pre_course THEN
        RETURN format('%s is a prerequisite of %s.', subject1::text, subject2::text);
    ELSE
        RETURN format('%s is not a prerequisite of %s.', subject1::text, subject2::text);
    END IF;
END
$$
LANGUAGE plpgsql;

-- SELECT q10(1863,1915);
-- SELECT q10(1867,1915);
-- SELECT q10(4897,1915);
-- SELECT q10(1254,1339);
-- SELECT q10(1339,1339);
-- SELECT q10(1862,1339);
-- SELECT
--     check_q10a();

-- SELECT
--     check_q10b();

-- SELECT
--     check_q10c();

-- SELECT
--     check_q10d();

-- SELECT
--     check_q10e();

-- Q9
DROP FUNCTION IF EXISTS Q9 CASCADE;

CREATE OR REPLACE FUNCTION Q9(subject1 integer, subject2 integer)
    RETURNS text
    AS $$
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
        id = $ 1;
    SELECT
        _prereq INTO _course_text
    FROM
        subjects
    WHERE
        id = $ 2
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

--Q8

DROP VIEW IF EXISTS Q8 CASCADE;

create or replace
view Q8(course_id,
unswid) as
-- SQL query
with course_hold_in_2012 as (
select
	distinct c.id
from
	subjects s
join orgunits o on
	s.offeredby = o.id
join courses c on
	c.subject = s.id
join semesters sem on
	c.semester = sem.id
where
	o.longname = 'School of Computer Science and Engineering'
	and sem.year = 2012
),
cse_affiliation_id as (
select
	distinct affiliations.orgunit
from
	affiliations,
	orgunits
where
	affiliations.orgunit = orgunits.id
	and orgunits.longname = 'School of Computer Science and Engineering'
),
cse_courses_lecturers as (
select
	course_staff.staff,
	course_staff.course,
	people.unswid,
	affiliations.orgunit
from
	course_hold_in_2012
join course_staff on
	course_hold_in_2012.id = course_staff.course
join staff_roles on
	course_staff.role = staff_roles.id
join people on
	people.id = course_staff.staff
join affiliations on
	affiliations.staff = course_staff.staff
where
	staff_roles.name = 'Course Lecturer'
),
cse_courses_only_from_cse_lecturers as (
select
	unswid,
	course,
	orgunit
from
	cse_courses_lecturers c
where
	c.orgunit in (
	select
		orgunit
	from
		cse_affiliation_id)
)
select
	course,
	unswid
from
	cse_courses_only_from_cse_lecturers;



-- Q7
-- Define a view Q7(course_id, unswid) to find the courses (courses.id)
-- and the Course Lectuers (people.unswid) of that course such that the course is offered by CSE in the year of 2012
-- and the Course Lectuers are also
-- from CSE.
DROP VIEW IF EXISTS Q7 CASCADE;

CREATE OR REPLACE VIEW Q7(course_id, unswid) AS
-- SQL query
WITH course_hold_in_2012 AS (
    SELECT
        distinct c.id
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


-- Q6
DROP VIEW IF EXISTS Q6 CASCADE;

CREATE OR REPLACE VIEW Q6(count) AS -- SQL query
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

-- Q5
-- Define a view Q5(count) to count the number of subjects offered by CSE (
--     orgunits.longname = 'School
-- of Computer Science and Engineering'
-- ) in the year of 2012 (Semesters.year).Please note that it is not guaranteed that this subject is offered in the years between the year of subjects.firstoffer
-- and subjects.lastoffer.
-- DROP VIEW IF EXISTS Q5 CASCADE;
-- CREATE
-- or REPLACE VIEW Q5(count) AS
-- -- SQL query
CREATE OR REPLACE VIEW Q5(count) AS
with cse_courses_in_2012 AS (
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

-- Q4
-- Define a view Q4(unswid,name) to find the unswid (people.unswid) and name (people.name) of
-- students whose WAM of all COMP courses the student has taken is greater than 85. Only consider
-- those students who have taken at least 6 COMP courses of different subjects and non-NULL marks. If
-- the student has taken multiple courses with the same subject in different terms/semesters, only
-- consider the one with the highest mark. WAM refers to the weighted average mark, it is computed
-- as sum(mark * uoc)/sum(uoc) where uoc refers to subjects.uoc.
DROP VIEW IF EXISTS Q4 CASCADE;

CREATE OR REPLACE VIEW Q4(unswid, name) AS -- SQL query
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

SELECT
    check_q4();

-- Q1
-- Define a view Q1(count) to count the number of students who have ever got a mark
-- (course_enrolments.mark) greater than 85 in COMP courses. COMP course refers to subjects.code
-- that starts with 'COMP'.
-- subjects.code
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
-- Define a view Q2(count) to count the number of students whose average mark of all COMP courses
-- the student has taken is greater than 85. Only consider the non-NULL marks.
DROP VIEW IF EXISTS Q2 CASCADE;

CREATE OR REPLACE VIEW Q2(count) AS
-- SQL query
-- Use CTE(with-clause) for clearer logic: https://www.postgresql.org/docs/13/queries-with.html
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
        INNER JOIN course_subjects cs ON ce.course = cs.id WHETE ce.mark IS NOT NULL
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

-- select check_q1();
-- select check_q2();
-- Q3
-- Define a view Q3(unswid,name) to find the unswid (people.unswid) and name (people.name) of
-- students whose average mark of all COMP courses the student has taken is greater than 85. Only
-- consider the students who have taken at least 6 COMP courses and non-NULL marks. If the student
-- has taken multiple courses of the same subject in different terms/semesters, consider them as two
-- different courses.
DROP VIEW IF EXISTS Q3 CASCADE;

CREATE OR REPLACE VIEW Q3(unswid, name) AS
-- SQL query
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
