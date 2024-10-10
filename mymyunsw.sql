--
-- PostgreSQL database dump
--

-- Dumped from database version 13.11 (Debian 13.11-0+deb11u1)
-- Dumped by pg_dump version 13.11 (Debian 13.11-0+deb11u1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: shortname; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.shortname AS character varying(16);


--
-- Name: acadobjectgroupdeftype; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.acadobjectgroupdeftype AS public.shortname
	CONSTRAINT acadobjectgroupdeftype_check CHECK (((VALUE)::text = ANY (ARRAY[('enumerated'::character varying)::text, ('pattern'::character varying)::text, ('query'::character varying)::text])));


--
-- Name: acadobjectgrouplogictype; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.acadobjectgrouplogictype AS public.shortname
	CONSTRAINT acadobjectgrouplogictype_check CHECK (((VALUE)::text = ANY (ARRAY[('and'::character varying)::text, ('or'::character varying)::text])));


--
-- Name: acadobjectgrouptype; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.acadobjectgrouptype AS public.shortname
	CONSTRAINT acadobjectgrouptype_check CHECK (((VALUE)::text = ANY (ARRAY[('subject'::character varying)::text, ('stream'::character varying)::text, ('program'::character varying)::text])));


--
-- Name: acobjrecord; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.acobjrecord AS (
	objtype text,
	object text
);


--
-- Name: campustype; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.campustype AS character(1)
	CONSTRAINT campustype_check CHECK ((VALUE = ANY (ARRAY['K'::bpchar, 'P'::bpchar, 'Z'::bpchar, 'C'::bpchar, 'X'::bpchar])));


--
-- Name: careertype; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.careertype AS character(2)
	CONSTRAINT careertype_check CHECK ((VALUE = ANY (ARRAY['UG'::bpchar, 'PG'::bpchar, 'HY'::bpchar, 'RS'::bpchar, 'NA'::bpchar])));


--
-- Name: courseyeartype; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.courseyeartype AS integer
	CONSTRAINT courseyeartype_check CHECK ((VALUE > 1945));


--
-- Name: emailstring; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.emailstring AS character varying(64)
	CONSTRAINT emailstring_check CHECK (((VALUE)::text ~~ '%@%'::text));


--
-- Name: gradetype; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.gradetype AS character(2)
	CONSTRAINT gradetype_check CHECK ((VALUE = ANY (ARRAY['AF'::bpchar, 'AS'::bpchar, 'CR'::bpchar, 'DF'::bpchar, 'DN'::bpchar, 'EC'::bpchar, 'FL'::bpchar, 'FN'::bpchar, 'GP'::bpchar, 'HD'::bpchar, 'LE'::bpchar, 'NA'::bpchar, 'NC'::bpchar, 'NF'::bpchar, 'PC'::bpchar, 'PE'::bpchar, 'PS'::bpchar, 'PT'::bpchar, 'RC'::bpchar, 'RD'::bpchar, 'RS'::bpchar, 'SS'::bpchar, 'SY'::bpchar, 'UF'::bpchar, 'WA'::bpchar, 'WC'::bpchar, 'WD'::bpchar, 'WJ'::bpchar, 'XE'::bpchar, 'A'::bpchar, 'B'::bpchar, 'C'::bpchar, 'D'::bpchar, 'E'::bpchar, 'T'::bpchar])));


--
-- Name: longname; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.longname AS character varying(128);


--
-- Name: longstring; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.longstring AS character varying(256);


--
-- Name: mediumname; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.mediumname AS character varying(64);


--
-- Name: mediumstring; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.mediumstring AS character varying(64);


--
-- Name: newtranscriptrecord; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.newtranscriptrecord AS (
	code character(8),
	term character(4),
	prog character(4),
	name text,
	mark integer,
	grade character(2),
	uoc integer
);


--
-- Name: phonenumber; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.phonenumber AS character varying(32);


--
-- Name: poprecord; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.poprecord AS (
	tab_name text,
	n_records integer
);


--
-- Name: shortstring; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.shortstring AS character varying(16);


--
-- Name: textstring; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.textstring AS character varying(4096);


--
-- Name: transcriptrecord; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.transcriptrecord AS (
	code character(8),
	term character(4),
	name text,
	mark integer,
	grade character(2),
	uoc integer
);


--
-- Name: urlstring; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.urlstring AS character varying(128)
	CONSTRAINT urlstring_check CHECK (((VALUE)::text ~~ 'http://%'::text));


--
-- Name: variationtype; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.variationtype AS public.shortname
	CONSTRAINT variationtype_check CHECK (((VALUE)::text = ANY (ARRAY[('advstanding'::character varying)::text, ('substitution'::character varying)::text, ('exemption'::character varying)::text])));


--
-- Name: dbpop(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.dbpop() RETURNS SETOF public.poprecord
    LANGUAGE plpgsql
    AS $$
declare
	r record;
	nr integer;
	res PopRecord;
begin
	for r in select tablename
		 from pg_tables
		 where schemaname = 'public'
		 order by tablename
	loop
		execute 'select count(*) from '||quote_ident(r.tablename) into nr;
		res.tab_name := r.tablename; res.n_records := nr;
		return next res;
	end loop;
	return;
end;
$$;


--
-- Name: facultyof(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.facultyof(_ouid integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare
	_count integer;
	_tname text;
	_parent integer;
begin
	if (_ouid is null) then
		return null;
	end if;

	select count(*) into _count
	from OrgUnits where id = _ouid;
	if (_count = 0) then
		raise exception 'No such unit: %',_ouid;
	end if;

	select t.name into _tname
	from OrgUnits u, OrgUnit_types t
	where u.id = _ouid and u.utype = t.id;

	if (_tname is null) then
		return null;
	elsif (_tname = 'University') then
		return null;
	elsif (_tname = 'Faculty') then
		return _ouid;
	else
		select owner into _parent
		from OrgUnit_groups where member = _ouid;
		return facultyOf(_parent);
	end if;
end;
$$;


--
-- Name: transcript(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.transcript(_sid integer) RETURNS SETOF public.transcriptrecord
    LANGUAGE plpgsql
    AS $$
declare
	rec TranscriptRecord;
	UOCtotal integer := 0;
	UOCpassed integer := 0;
	wsum integer := 0;
	wam integer := 0;
	x integer;
begin
	select s.id into x
	from   Students s join People p on (s.id = p.id)
	where  p.unswid = _sid;
	if (not found) then
		raise EXCEPTION 'Invalid student %',_sid;
	end if;
	for rec in
		select su.code,
		         substr(t.year::text,3,2)||lower(t.term),
		         substr(su.name,1,20),
		         e.mark, e.grade, su.uoc
		from   People p
		         join Students s on (p.id = s.id)
		         join Course_enrolments e on (e.student = s.id)
		         join Courses c on (c.id = e.course)
		         join Subjects su on (c.subject = su.id)
		         join Semesters t on (c.semester = t.id)
		where  p.unswid = _sid
		order  by t.starting, su.code
	loop
		if (rec.grade = 'SY') then
			UOCpassed := UOCpassed + rec.uoc;
		elsif (rec.mark is not null) then
			if (rec.grade in ('PT','PC','PS','CR','DN','HD','A','B','C')) then
				-- only counts towards creditted UOC
				-- if they passed the course
				UOCpassed := UOCpassed + rec.uoc;
			end if;
			-- we count fails towards the WAM calculation
			UOCtotal := UOCtotal + rec.uoc;
			-- weighted sum based on mark and uoc for course
			wsum := wsum + (rec.mark * rec.uoc);
			-- don't give UOC if they failed
			if (rec.grade not in ('PT','PC','PS','CR','DN','HD','A','B','C')) then
				rec.uoc := 0;
			end if;

		end if;
		return next rec;
	end loop;
	if (UOCtotal = 0) then
		rec := (null,null,'No WAM available',null,null,null);
	else
		wam := wsum / UOCtotal;
		rec := (null,null,'Overall WAM',wam,null,UOCpassed);
	end if;
	-- append the last record containing the WAM
	return next rec;
end;
$$;


--
-- Name: unitname(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.unitname(_ouid integer) RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
declare
	_name text;
	_type text;
begin
	if (_ouid is null) then
		return null;
	end if;
	select t.name,u.longname into _type,_name
	from OrgUnits u join OrgUnit_types t on (u.utype=t.id)
	where u.id = _ouid;
	if (_type is null) then
		raise exception 'Invalid OrgUnit id %',_ouid;
	end if;
	if (_type = 'School' and not (_name like '%School%')) then
		return 'School of '||_name;
	elseif (_type = 'Department') then
		return 'Dept of '||_name;
	elseif (_type = 'Centre' and not (_name like '%Centre%')) then
		return 'Centre for '||_name;
	elseif (_type = 'Institute' and not (_name like '%Institute%')) then
		return 'Institute of '||_name;
	else
		return _name;
	end if;
end;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: acad_object_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.acad_object_groups (
    id integer NOT NULL,
    name public.longname,
    gtype public.acadobjectgrouptype NOT NULL,
    glogic public.acadobjectgrouplogictype,
    gdefby public.acadobjectgroupdeftype NOT NULL,
    negated boolean DEFAULT false,
    parent integer,
    definition public.textstring
);


--
-- Name: academic_standing; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.academic_standing (
    id integer NOT NULL,
    standing public.shortname NOT NULL,
    notes public.textstring
);


--
-- Name: affiliations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.affiliations (
    staff integer NOT NULL,
    orgunit integer NOT NULL,
    role integer NOT NULL,
    isprimary boolean,
    starting date NOT NULL,
    ending date
);


--
-- Name: buildings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.buildings (
    id integer NOT NULL,
    unswid public.shortstring NOT NULL,
    name public.longname NOT NULL,
    campus public.campustype,
    gridref character(4)
);


--
-- Name: class_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.class_types (
    id integer NOT NULL,
    unswid public.shortstring NOT NULL,
    name public.mediumname NOT NULL,
    description public.mediumstring
);


--
-- Name: classes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.classes (
    id integer NOT NULL,
    course integer NOT NULL,
    room integer NOT NULL,
    ctype integer NOT NULL,
    dayofwk integer NOT NULL,
    starttime integer NOT NULL,
    endtime integer NOT NULL,
    startdate date NOT NULL,
    enddate date NOT NULL,
    repeats integer,
    CONSTRAINT classes_dayofwk_check CHECK (((dayofwk >= 0) AND (dayofwk <= 6))),
    CONSTRAINT classes_endtime_check CHECK (((endtime >= 9) AND (endtime <= 23))),
    CONSTRAINT classes_starttime_check CHECK (((starttime >= 8) AND (starttime <= 22)))
);


--
-- Name: countries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.countries (
    id integer NOT NULL,
    code character(3) NOT NULL,
    name public.longname NOT NULL
);


--
-- Name: course_enrolments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.course_enrolments (
    student integer NOT NULL,
    course integer NOT NULL,
    mark integer,
    grade public.gradetype,
    stueval integer,
    CONSTRAINT course_enrolments_mark_check CHECK (((mark >= 0) AND (mark <= 100))),
    CONSTRAINT course_enrolments_stueval_check CHECK (((stueval >= 1) AND (stueval <= 6)))
);


--
-- Name: course_staff; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.course_staff (
    course integer NOT NULL,
    staff integer NOT NULL,
    role integer NOT NULL
);


--
-- Name: courses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.courses (
    id integer NOT NULL,
    subject integer NOT NULL,
    semester integer NOT NULL,
    homepage public.urlstring
);


--
-- Name: degree_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.degree_types (
    id integer NOT NULL,
    unswid public.shortname NOT NULL,
    name public.mediumstring NOT NULL,
    prefix public.mediumstring,
    career public.careertype,
    aqf_level integer,
    CONSTRAINT degree_types_aqf_level_check CHECK ((aqf_level > 0))
);


--
-- Name: facilities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.facilities (
    id integer NOT NULL,
    description public.mediumstring NOT NULL
);


--
-- Name: orgunit_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.orgunit_groups (
    owner integer NOT NULL,
    member integer NOT NULL
);


--
-- Name: orgunit_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.orgunit_types (
    id integer NOT NULL,
    name public.shortname NOT NULL
);


--
-- Name: orgunits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.orgunits (
    id integer NOT NULL,
    utype integer NOT NULL,
    name public.mediumstring NOT NULL,
    longname public.longstring,
    unswid public.shortstring,
    phone public.phonenumber,
    email public.emailstring,
    website public.urlstring,
    starting date,
    ending date
);


--
-- Name: people; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.people (
    id integer NOT NULL,
    unswid integer,
    password public.shortstring NOT NULL,
    family public.longname,
    given public.longname NOT NULL,
    title public.shortname,
    sortname public.longname NOT NULL,
    name public.longname NOT NULL,
    street public.longstring,
    city public.mediumstring,
    state public.mediumstring,
    postcode public.shortstring,
    country integer,
    homephone public.phonenumber,
    mobphone public.phonenumber,
    email public.emailstring NOT NULL,
    homepage public.urlstring,
    gender character(1),
    birthday date,
    origin integer,
    CONSTRAINT people_gender_check CHECK ((gender = ANY (ARRAY['m'::bpchar, 'f'::bpchar])))
);


--
-- Name: program_degrees; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.program_degrees (
    id integer NOT NULL,
    program integer,
    dtype integer,
    name public.longstring NOT NULL,
    abbrev public.mediumstring
);


--
-- Name: program_enrolments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.program_enrolments (
    id integer NOT NULL,
    student integer NOT NULL,
    semester integer NOT NULL,
    program integer NOT NULL,
    wam real,
    standing integer,
    advisor integer,
    notes public.textstring
);


--
-- Name: program_group_members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.program_group_members (
    program integer NOT NULL,
    ao_group integer NOT NULL
);


--
-- Name: programs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.programs (
    id integer NOT NULL,
    code character(4) NOT NULL,
    name public.longname NOT NULL,
    uoc integer,
    offeredby integer,
    career public.careertype,
    duration integer,
    description public.textstring,
    firstoffer integer,
    lastoffer integer,
    CONSTRAINT programs_uoc_check CHECK ((uoc >= 0))
);


--
-- Name: room_facilities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.room_facilities (
    room integer NOT NULL,
    facility integer NOT NULL
);


--
-- Name: room_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.room_types (
    id integer NOT NULL,
    description public.mediumstring NOT NULL
);


--
-- Name: rooms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rooms (
    id integer NOT NULL,
    unswid public.shortstring NOT NULL,
    rtype integer,
    name public.shortname NOT NULL,
    longname public.longname,
    building integer,
    capacity integer,
    CONSTRAINT rooms_capacity_check CHECK ((capacity >= 0))
);


--
-- Name: semesters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.semesters (
    id integer NOT NULL,
    unswid integer NOT NULL,
    year public.courseyeartype,
    term character(2) NOT NULL,
    name public.shortname NOT NULL,
    longname public.longname NOT NULL,
    starting date NOT NULL,
    ending date NOT NULL,
    startbrk date,
    endbrk date,
    endwd date,
    endenrol date,
    census date,
    CONSTRAINT semesters_term_check CHECK ((term = ANY (ARRAY['S1'::bpchar, 'S2'::bpchar, 'X1'::bpchar, 'X2'::bpchar])))
);


--
-- Name: staff; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.staff (
    id integer NOT NULL,
    office integer,
    phone public.phonenumber,
    employed date NOT NULL,
    supervisor integer
);


--
-- Name: staff_role_classes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.staff_role_classes (
    id character(1) NOT NULL,
    description public.shortstring
);


--
-- Name: staff_role_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.staff_role_types (
    id character(1) NOT NULL,
    description public.shortstring
);


--
-- Name: staff_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.staff_roles (
    id integer NOT NULL,
    rtype character(1),
    rclass character(1),
    name public.longstring NOT NULL,
    description public.longstring
);


--
-- Name: stream_enrolments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stream_enrolments (
    partof integer NOT NULL,
    stream integer NOT NULL
);


--
-- Name: stream_group_members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stream_group_members (
    stream integer NOT NULL,
    ao_group integer NOT NULL
);


--
-- Name: stream_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stream_types (
    id integer NOT NULL,
    career public.careertype NOT NULL,
    code character(1) NOT NULL,
    description public.shortstring NOT NULL
);


--
-- Name: streams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.streams (
    id integer NOT NULL,
    code character(6) NOT NULL,
    name public.longname NOT NULL,
    offeredby integer,
    stype integer,
    description public.textstring,
    firstoffer integer,
    lastoffer integer
);


--
-- Name: students; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.students (
    id integer NOT NULL,
    stype character varying(5),
    CONSTRAINT students_stype_check CHECK (((stype)::text = ANY (ARRAY[('local'::character varying)::text, ('intl'::character varying)::text])))
);


--
-- Name: subject_group_members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subject_group_members (
    subject integer NOT NULL,
    ao_group integer NOT NULL
);


--
-- Name: subjects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subjects (
    id integer NOT NULL,
    code character(8) NOT NULL,
    name public.mediumname NOT NULL,
    longname public.longname,
    uoc integer,
    offeredby integer,
    eftsload double precision,
    career public.careertype,
    syllabus public.textstring,
    contacthpw double precision,
    _excluded text,
    excluded integer,
    _equivalent text,
    equivalent integer,
    _prereq text,
    prereq integer,
    replaces integer,
    firstoffer integer,
    lastoffer integer,
    CONSTRAINT subjects_uoc_check CHECK ((uoc >= 0))
);


--

--
-- Name: acad_object_groups acad_object_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acad_object_groups
    ADD CONSTRAINT acad_object_groups_pkey PRIMARY KEY (id);


--
-- Name: academic_standing academic_standing_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.academic_standing
    ADD CONSTRAINT academic_standing_pkey PRIMARY KEY (id);


--
-- Name: affiliations affiliations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.affiliations
    ADD CONSTRAINT affiliations_pkey PRIMARY KEY (staff, orgunit, role, starting);


--
-- Name: buildings buildings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.buildings
    ADD CONSTRAINT buildings_pkey PRIMARY KEY (id);


--
-- Name: buildings buildings_unswid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.buildings
    ADD CONSTRAINT buildings_unswid_key UNIQUE (unswid);


--
-- Name: class_types class_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.class_types
    ADD CONSTRAINT class_types_pkey PRIMARY KEY (id);


--
-- Name: class_types class_types_unswid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.class_types
    ADD CONSTRAINT class_types_unswid_key UNIQUE (unswid);


--
-- Name: classes classes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.classes
    ADD CONSTRAINT classes_pkey PRIMARY KEY (id);


--
-- Name: countries countries_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.countries
    ADD CONSTRAINT countries_code_key UNIQUE (code);


--
-- Name: countries countries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);


--
-- Name: course_enrolments course_enrolments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.course_enrolments
    ADD CONSTRAINT course_enrolments_pkey PRIMARY KEY (student, course);


--
-- Name: course_staff course_staff_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.course_staff
    ADD CONSTRAINT course_staff_pkey PRIMARY KEY (course, staff, role);


--
-- Name: courses courses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.courses
    ADD CONSTRAINT courses_pkey PRIMARY KEY (id);


--
-- Name: degree_types degree_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.degree_types
    ADD CONSTRAINT degree_types_pkey PRIMARY KEY (id);


--
-- Name: degree_types degree_types_unswid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.degree_types
    ADD CONSTRAINT degree_types_unswid_key UNIQUE (unswid);


--
-- Name: facilities facilities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.facilities
    ADD CONSTRAINT facilities_pkey PRIMARY KEY (id);


--
-- Name: orgunit_groups orgunit_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orgunit_groups
    ADD CONSTRAINT orgunit_groups_pkey PRIMARY KEY (owner, member);


--
-- Name: orgunit_types orgunit_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orgunit_types
    ADD CONSTRAINT orgunit_types_pkey PRIMARY KEY (id);


--
-- Name: orgunits orgunits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orgunits
    ADD CONSTRAINT orgunits_pkey PRIMARY KEY (id);


--
-- Name: people people_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people
    ADD CONSTRAINT people_pkey PRIMARY KEY (id);


--
-- Name: people people_unswid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people
    ADD CONSTRAINT people_unswid_key UNIQUE (unswid);


--
-- Name: program_degrees program_degrees_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.program_degrees
    ADD CONSTRAINT program_degrees_pkey PRIMARY KEY (id);


--
-- Name: program_enrolments program_enrolments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.program_enrolments
    ADD CONSTRAINT program_enrolments_pkey PRIMARY KEY (id);


--
-- Name: program_group_members program_group_members_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.program_group_members
    ADD CONSTRAINT program_group_members_pkey PRIMARY KEY (program, ao_group);


--
-- Name: programs programs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.programs
    ADD CONSTRAINT programs_pkey PRIMARY KEY (id);


--
-- Name: room_facilities room_facilities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_facilities
    ADD CONSTRAINT room_facilities_pkey PRIMARY KEY (room, facility);


--
-- Name: room_types room_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_types
    ADD CONSTRAINT room_types_pkey PRIMARY KEY (id);


--
-- Name: rooms rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_pkey PRIMARY KEY (id);


--
-- Name: rooms rooms_unswid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_unswid_key UNIQUE (unswid);


--
-- Name: semesters semesters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.semesters
    ADD CONSTRAINT semesters_pkey PRIMARY KEY (id);


--
-- Name: semesters semesters_unswid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.semesters
    ADD CONSTRAINT semesters_unswid_key UNIQUE (unswid);


--
-- Name: staff staff_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_pkey PRIMARY KEY (id);


--
-- Name: staff_role_classes staff_role_classes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff_role_classes
    ADD CONSTRAINT staff_role_classes_pkey PRIMARY KEY (id);


--
-- Name: staff_role_types staff_role_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff_role_types
    ADD CONSTRAINT staff_role_types_pkey PRIMARY KEY (id);


--
-- Name: staff_roles staff_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff_roles
    ADD CONSTRAINT staff_roles_pkey PRIMARY KEY (id);


--
-- Name: stream_enrolments stream_enrolments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stream_enrolments
    ADD CONSTRAINT stream_enrolments_pkey PRIMARY KEY (partof, stream);


--
-- Name: stream_group_members stream_group_members_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stream_group_members
    ADD CONSTRAINT stream_group_members_pkey PRIMARY KEY (stream, ao_group);


--
-- Name: stream_types stream_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stream_types
    ADD CONSTRAINT stream_types_pkey PRIMARY KEY (id);


--
-- Name: streams streams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.streams
    ADD CONSTRAINT streams_pkey PRIMARY KEY (id);


--
-- Name: students students_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_pkey PRIMARY KEY (id);


--
-- Name: subject_group_members subject_group_members_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subject_group_members
    ADD CONSTRAINT subject_group_members_pkey PRIMARY KEY (subject, ao_group);


--
-- Name: subjects subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_pkey PRIMARY KEY (id);


--
-- Name: acad_object_groups acad_object_groups_parent_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acad_object_groups
    ADD CONSTRAINT acad_object_groups_parent_fkey FOREIGN KEY (parent) REFERENCES public.acad_object_groups(id);


--
-- Name: affiliations affiliations_orgunit_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.affiliations
    ADD CONSTRAINT affiliations_orgunit_fkey FOREIGN KEY (orgunit) REFERENCES public.orgunits(id);


--
-- Name: affiliations affiliations_role_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.affiliations
    ADD CONSTRAINT affiliations_role_fkey FOREIGN KEY (role) REFERENCES public.staff_roles(id);


--
-- Name: affiliations affiliations_staff_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.affiliations
    ADD CONSTRAINT affiliations_staff_fkey FOREIGN KEY (staff) REFERENCES public.staff(id);


--
-- Name: classes classes_course_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.classes
    ADD CONSTRAINT classes_course_fkey FOREIGN KEY (course) REFERENCES public.courses(id);


--
-- Name: classes classes_ctype_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.classes
    ADD CONSTRAINT classes_ctype_fkey FOREIGN KEY (ctype) REFERENCES public.class_types(id);


--
-- Name: classes classes_room_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.classes
    ADD CONSTRAINT classes_room_fkey FOREIGN KEY (room) REFERENCES public.rooms(id);


--
-- Name: course_enrolments course_enrolments_course_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.course_enrolments
    ADD CONSTRAINT course_enrolments_course_fkey FOREIGN KEY (course) REFERENCES public.courses(id);


--
-- Name: course_enrolments course_enrolments_student_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.course_enrolments
    ADD CONSTRAINT course_enrolments_student_fkey FOREIGN KEY (student) REFERENCES public.students(id);


--
-- Name: course_staff course_staff_course_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.course_staff
    ADD CONSTRAINT course_staff_course_fkey FOREIGN KEY (course) REFERENCES public.courses(id);


--
-- Name: course_staff course_staff_role_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.course_staff
    ADD CONSTRAINT course_staff_role_fkey FOREIGN KEY (role) REFERENCES public.staff_roles(id);


--
-- Name: course_staff course_staff_staff_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.course_staff
    ADD CONSTRAINT course_staff_staff_fkey FOREIGN KEY (staff) REFERENCES public.staff(id);


--
-- Name: courses courses_semester_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.courses
    ADD CONSTRAINT courses_semester_fkey FOREIGN KEY (semester) REFERENCES public.semesters(id);


--
-- Name: courses courses_subject_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.courses
    ADD CONSTRAINT courses_subject_fkey FOREIGN KEY (subject) REFERENCES public.subjects(id);


--
-- Name: orgunit_groups orgunit_groups_member_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orgunit_groups
    ADD CONSTRAINT orgunit_groups_member_fkey FOREIGN KEY (member) REFERENCES public.orgunits(id);


--
-- Name: orgunit_groups orgunit_groups_owner_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orgunit_groups
    ADD CONSTRAINT orgunit_groups_owner_fkey FOREIGN KEY (owner) REFERENCES public.orgunits(id);


--
-- Name: orgunits orgunits_utype_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orgunits
    ADD CONSTRAINT orgunits_utype_fkey FOREIGN KEY (utype) REFERENCES public.orgunit_types(id);


--
-- Name: people people_country_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people
    ADD CONSTRAINT people_country_fkey FOREIGN KEY (country) REFERENCES public.countries(id);


--
-- Name: people people_origin_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people
    ADD CONSTRAINT people_origin_fkey FOREIGN KEY (origin) REFERENCES public.countries(id);


--
-- Name: program_degrees program_degrees_dtype_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.program_degrees
    ADD CONSTRAINT program_degrees_dtype_fkey FOREIGN KEY (dtype) REFERENCES public.degree_types(id);


--
-- Name: program_degrees program_degrees_program_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.program_degrees
    ADD CONSTRAINT program_degrees_program_fkey FOREIGN KEY (program) REFERENCES public.programs(id);


--
-- Name: program_enrolments program_enrolments_advisor_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.program_enrolments
    ADD CONSTRAINT program_enrolments_advisor_fkey FOREIGN KEY (advisor) REFERENCES public.staff(id);


--
-- Name: program_enrolments program_enrolments_program_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.program_enrolments
    ADD CONSTRAINT program_enrolments_program_fkey FOREIGN KEY (program) REFERENCES public.programs(id);


--
-- Name: program_enrolments program_enrolments_semester_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.program_enrolments
    ADD CONSTRAINT program_enrolments_semester_fkey FOREIGN KEY (semester) REFERENCES public.semesters(id);


--
-- Name: program_enrolments program_enrolments_standing_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.program_enrolments
    ADD CONSTRAINT program_enrolments_standing_fkey FOREIGN KEY (standing) REFERENCES public.academic_standing(id);


--
-- Name: program_enrolments program_enrolments_student_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.program_enrolments
    ADD CONSTRAINT program_enrolments_student_fkey FOREIGN KEY (student) REFERENCES public.students(id);


--
-- Name: program_group_members program_group_members_ao_group_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.program_group_members
    ADD CONSTRAINT program_group_members_ao_group_fkey FOREIGN KEY (ao_group) REFERENCES public.acad_object_groups(id);


--
-- Name: program_group_members program_group_members_program_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.program_group_members
    ADD CONSTRAINT program_group_members_program_fkey FOREIGN KEY (program) REFERENCES public.programs(id);


--
-- Name: programs programs_firstoffer_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.programs
    ADD CONSTRAINT programs_firstoffer_fkey FOREIGN KEY (firstoffer) REFERENCES public.semesters(id);


--
-- Name: programs programs_lastoffer_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.programs
    ADD CONSTRAINT programs_lastoffer_fkey FOREIGN KEY (lastoffer) REFERENCES public.semesters(id);


--
-- Name: programs programs_offeredby_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.programs
    ADD CONSTRAINT programs_offeredby_fkey FOREIGN KEY (offeredby) REFERENCES public.orgunits(id);


--
-- Name: room_facilities room_facilities_facility_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_facilities
    ADD CONSTRAINT room_facilities_facility_fkey FOREIGN KEY (facility) REFERENCES public.facilities(id);


--
-- Name: room_facilities room_facilities_room_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_facilities
    ADD CONSTRAINT room_facilities_room_fkey FOREIGN KEY (room) REFERENCES public.rooms(id);


--
-- Name: rooms rooms_building_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_building_fkey FOREIGN KEY (building) REFERENCES public.buildings(id);


--
-- Name: rooms rooms_rtype_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_rtype_fkey FOREIGN KEY (rtype) REFERENCES public.room_types(id);


--
-- Name: staff staff_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_id_fkey FOREIGN KEY (id) REFERENCES public.people(id);


--
-- Name: staff staff_office_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_office_fkey FOREIGN KEY (office) REFERENCES public.rooms(id);


--
-- Name: staff_roles staff_roles_rclass_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff_roles
    ADD CONSTRAINT staff_roles_rclass_fkey FOREIGN KEY (rclass) REFERENCES public.staff_role_classes(id);


--
-- Name: staff_roles staff_roles_rtype_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff_roles
    ADD CONSTRAINT staff_roles_rtype_fkey FOREIGN KEY (rtype) REFERENCES public.staff_role_types(id);


--
-- Name: staff staff_supervisor_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_supervisor_fkey FOREIGN KEY (supervisor) REFERENCES public.staff(id);


--
-- Name: stream_enrolments stream_enrolments_partof_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stream_enrolments
    ADD CONSTRAINT stream_enrolments_partof_fkey FOREIGN KEY (partof) REFERENCES public.program_enrolments(id);


--
-- Name: stream_enrolments stream_enrolments_stream_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stream_enrolments
    ADD CONSTRAINT stream_enrolments_stream_fkey FOREIGN KEY (stream) REFERENCES public.streams(id);


--
-- Name: stream_group_members stream_group_members_ao_group_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stream_group_members
    ADD CONSTRAINT stream_group_members_ao_group_fkey FOREIGN KEY (ao_group) REFERENCES public.acad_object_groups(id);


--
-- Name: stream_group_members stream_group_members_stream_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stream_group_members
    ADD CONSTRAINT stream_group_members_stream_fkey FOREIGN KEY (stream) REFERENCES public.streams(id);


--
-- Name: streams streams_firstoffer_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.streams
    ADD CONSTRAINT streams_firstoffer_fkey FOREIGN KEY (firstoffer) REFERENCES public.semesters(id);


--
-- Name: streams streams_lastoffer_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.streams
    ADD CONSTRAINT streams_lastoffer_fkey FOREIGN KEY (lastoffer) REFERENCES public.semesters(id);


--
-- Name: streams streams_offeredby_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.streams
    ADD CONSTRAINT streams_offeredby_fkey FOREIGN KEY (offeredby) REFERENCES public.orgunits(id);


--
-- Name: streams streams_stype_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.streams
    ADD CONSTRAINT streams_stype_fkey FOREIGN KEY (stype) REFERENCES public.stream_types(id);


--
-- Name: students students_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_id_fkey FOREIGN KEY (id) REFERENCES public.people(id);


--
-- Name: subject_group_members subject_group_members_ao_group_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subject_group_members
    ADD CONSTRAINT subject_group_members_ao_group_fkey FOREIGN KEY (ao_group) REFERENCES public.acad_object_groups(id);


--
-- Name: subject_group_members subject_group_members_subject_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subject_group_members
    ADD CONSTRAINT subject_group_members_subject_fkey FOREIGN KEY (subject) REFERENCES public.subjects(id);


--
-- Name: subjects subjects_equivalent_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_equivalent_fkey FOREIGN KEY (equivalent) REFERENCES public.acad_object_groups(id);


--
-- Name: subjects subjects_excluded_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_excluded_fkey FOREIGN KEY (excluded) REFERENCES public.acad_object_groups(id);


--
-- Name: subjects subjects_firstoffer_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_firstoffer_fkey FOREIGN KEY (firstoffer) REFERENCES public.semesters(id);


--
-- Name: subjects subjects_lastoffer_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_lastoffer_fkey FOREIGN KEY (lastoffer) REFERENCES public.semesters(id);


--
-- Name: subjects subjects_offeredby_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_offeredby_fkey FOREIGN KEY (offeredby) REFERENCES public.orgunits(id);


--
-- Name: subjects subjects_replaces_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_replaces_fkey FOREIGN KEY (replaces) REFERENCES public.subjects(id);


--
-- PostgreSQL database dump complete
--

