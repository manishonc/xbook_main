
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

CREATE EXTENSION IF NOT EXISTS "pgsodium" WITH SCHEMA "pgsodium";

CREATE SCHEMA IF NOT EXISTS "private";

ALTER SCHEMA "private" OWNER TO "postgres";

COMMENT ON SCHEMA "public" IS 'standard public schema';

CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";

CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";

CREATE OR REPLACE FUNCTION "public"."check_subject_access"("subject_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM private.app_exam_junctions aej
    JOIN private.exams e ON e.id = aej.exam_id
    JOIN public.exam_subjects_junction esj ON esj.exam_id = e.id
    WHERE aej.app_id = public.get_session_app_id()
    AND esj.subject_id = check_subject_access.subject_id
  );
END;
$$;

ALTER FUNCTION "public"."check_subject_access"("subject_id" "uuid") OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."count_correct_answers"("quiz" "json") RETURNS integer
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  question json;
  selected_answer_id integer;
  correct_count integer := 0;
BEGIN
  FOR question IN SELECT * FROM json_array_elements(quiz->'questions')
  LOOP
    selected_answer_id := (question->>'selectedAnswer')::integer;
    IF public.is_answer_correct(question, selected_answer_id) THEN
      correct_count := correct_count + 1;
    END IF;
  END LOOP;
  RETURN correct_count;
END;
$$;

ALTER FUNCTION "public"."count_correct_answers"("quiz" "json") OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."count_unattempted_answers"("quiz" "json") RETURNS integer
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  question json;
  unattempted_count integer := 0;
BEGIN
  FOR question IN SELECT * FROM json_array_elements(quiz->'questions')
  LOOP
    IF (question->>'selectedAnswer')::integer = 0 THEN
      unattempted_count := unattempted_count + 1;
    END IF;
  END LOOP;
  RETURN unattempted_count;
END;
$$;

ALTER FUNCTION "public"."count_unattempted_answers"("quiz" "json") OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."count_wrong_answers"("quiz" "json") RETURNS integer
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  question json;
  selected_answer_id integer;
  wrong_count integer := 0;
BEGIN
  FOR question IN SELECT * FROM json_array_elements(quiz->'questions')
  LOOP
    selected_answer_id := (question->>'selectedAnswer')::integer;
    IF NOT public.is_answer_correct(question, selected_answer_id) THEN
      wrong_count := wrong_count + 1;
    END IF;
  END LOOP;
  RETURN wrong_count;
END;
$$;

ALTER FUNCTION "public"."count_wrong_answers"("quiz" "json") OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";

CREATE TABLE IF NOT EXISTS "private"."apps" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "app_name" "text",
    "logo" "text",
    "app_domain" "text"
);

ALTER TABLE "private"."apps" OWNER TO "postgres";

CREATE OR REPLACE VIEW "private"."apps_view" AS
 SELECT "apps"."app_name",
    "apps"."logo",
    "apps"."app_domain"
   FROM "private"."apps";

ALTER TABLE "private"."apps_view" OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."get_apps_view"("p_app_domain" "text") RETURNS "private"."apps_view"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    result private.apps_view;
BEGIN
    SELECT *
    INTO result
    FROM private.apps_view
    WHERE app_domain = p_app_domain
    LIMIT 1;

    RETURN result;
END;
$$;

ALTER FUNCTION "public"."get_apps_view"("p_app_domain" "text") OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."get_exams_by_app"("p_app_id" "uuid") RETURNS TABLE("exam_id" "uuid", "created_at" timestamp with time zone, "title" "text", "exam_settings" "jsonb")
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN QUERY
    SELECT exams.id, exams.created_at, exams.title, exams.exam_settings
    FROM private.app_exam_junctions
    JOIN private.exams ON app_exam_junctions.exam_id = exams.id
    WHERE app_exam_junctions.app_id = p_app_id;
END;
$$;

ALTER FUNCTION "public"."get_exams_by_app"("p_app_id" "uuid") OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."get_quiz_results"("quiz" "json") RETURNS "json"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  correct_count integer;
  wrong_count integer;
  unattempted_count integer;
BEGIN
  -- Call the function to count correct answers
  correct_count := public.count_correct_answers(quiz);

  -- Call the function to count wrong answers
  wrong_count := public.count_wrong_answers(quiz);

  -- Call the function to count unattempted answers
  unattempted_count := public.count_unattempted_answers(quiz);

  -- Return the results as a JSON object
  RETURN json_build_object(
    'correct', correct_count,
    'wrong', wrong_count,
    'unattempted', unattempted_count
  );
END;
$$;

ALTER FUNCTION "public"."get_quiz_results"("quiz" "json") OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."get_session_app_id"() RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$DECLARE
    _session_id TEXT;
    _app_id uuid;
BEGIN
    -- Extract session_id from the JWT token
    SELECT (current_setting('request.jwt.claims')::json->>'session_id')INTO _session_id;

    -- Retrieve customer_id using the extracted session_id
    SELECT app_id INTO _app_id
    FROM private.session_custom_claim
    WHERE session_id = _session_id::uuid;

    RETURN _app_id;
END;$$;

ALTER FUNCTION "public"."get_session_app_id"() OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."get_subjects"("exam_id" "uuid") RETURNS TABLE("subject_id" "uuid", "subject_name" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    app_id uuid;
BEGIN
    -- Get the app_id associated with the current session
    app_id := get_session_app_id();

    -- Check if the app_id is found
    IF app_id IS NULL THEN
        RAISE EXCEPTION 'No app associated with the current session';
    END IF;

    -- If exam_id is not provided or is an empty string, get the first exam's supported subjects
    IF exam_id IS NULL OR exam_id::text = '' THEN
        RETURN QUERY
        SELECT s.id, s.subject_name
        FROM public.exam_subjects_junction esj
        JOIN private.quiz_app_junction qaj ON esj.exam_id = qaj.quiz_id
        JOIN public.subject s ON esj.subject_id = s.id
        WHERE qaj.app_id = app_id
        LIMIT 1;  -- Limit to the first exam's subjects
    END IF;

    -- Return subjects if the exam is supported by the app
    RETURN QUERY
    SELECT s.id, s.subject_name
    FROM public.exam_subjects_junction esj
    JOIN private.quiz_app_junction qaj ON esj.exam_id = qaj.quiz_id
    JOIN public.subject s ON esj.subject_id = s.id
    WHERE qaj.app_id = app_id AND esj.exam_id = exam_id;
END;
$$;

ALTER FUNCTION "public"."get_subjects"("exam_id" "uuid") OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."insert_user_app_relation"("p_app_id" "uuid", "p_user_id" "uuid") RETURNS "json"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    result json;
BEGIN
    -- Check if the record already exists
    IF NOT EXISTS (
        SELECT 1
        FROM private.user_and_app_junction
        WHERE app_id = p_app_id AND user_id = p_user_id
    ) THEN
        -- Insert the record if it doesn't exist
        INSERT INTO private.user_and_app_junction (app_id, user_id, created_at)
        VALUES (p_app_id, p_user_id, NOW());
        result := json_build_object('status', 'success','code', 200, 'message', 'User app relation created successfully.');
    ELSE
        result := json_build_object('status', 'info','code', 409, 'message', 'User app relation exists.');
    END IF;

    RETURN result;
END;
$$;

ALTER FUNCTION "public"."insert_user_app_relation"("p_app_id" "uuid", "p_user_id" "uuid") OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."is_answer_correct"("question" "json", "selected_answer_id" integer) RETURNS boolean
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  answer json;
BEGIN
  FOR answer IN SELECT * FROM json_array_elements(question->'answers')
  LOOP
    IF (answer->>'id')::integer = selected_answer_id THEN
      RETURN (answer->>'is_correct')::boolean;
    END IF;
  END LOOP;
  RETURN false; -- Return false if no matching answer ID is found
END;
$$;

ALTER FUNCTION "public"."is_answer_correct"("question" "json", "selected_answer_id" integer) OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."update_session_custom_claim"("p_app_domain" "text") RETURNS "json"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$DECLARE
    app_id_local uuid;
    session_id_local text;
    user_id_local uuid;
    app_id_exist uuid;

BEGIN
    -- Fetch customerId from the customers table
    SELECT id INTO app_id_local FROM private.apps WHERE app_domain = p_app_domain;

    -- If no customer is found, exit the function
     IF app_id_local IS NULL THEN
        RETURN json_build_object('data',json_build_object('status', 'error', 'code', 404, 'message', 'App for the domain does not exist'));       
    END IF;

    -- Extract sessionId and user ID from the JWT claims
    SELECT (current_setting('request.jwt.claims')::jsonb ->> 'session_id') INTO session_id_local;
    SELECT (current_setting('request.jwt.claims')::jsonb ->> 'sub') INTO user_id_local;

  -- Check if a session row exists and its customer_id status
    SELECT app_id INTO app_id_exist FROM private.session_custom_claim
    WHERE session_id = session_id_local::uuid;

    -- If no row is found, indicate no session found
    IF NOT FOUND THEN
        RETURN json_build_object('data',json_build_object('status', 'error', 'code', 404, 'message', 'Session does not exist'));
    -- If a row is found but customer_id is NULL, proceed to update
    ELSIF app_id_exist IS NULL THEN
        UPDATE private.session_custom_claim
        SET app_id = app_id_local
        WHERE session_id = session_id_local::uuid;

        -- Add relation between user and customer
        PERFORM insert_user_app_relation(app_id_local::uuid, user_id_local::uuid);

        RETURN json_build_object('data',json_build_object('status', 'success','code', 200, 'message', 'User session updated successfully'));

    ELSEIF app_id_exist = app_id_local THEN
        RETURN json_build_object('data',json_build_object('status', 'success', 'code', 204, 'message', 'App already associated with the session'));
    ELSE
        RETURN json_build_object('data',json_build_object('status', 'error', 'code', 409, 'message', 'App associated with the session cannot be changed'));
    END IF;
END;
$$;

ALTER FUNCTION "public"."update_session_custom_claim"("p_app_domain" "text") OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "private"."app_exam_junctions" (
    "exam_id" "uuid" NOT NULL,
    "app_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);

ALTER TABLE "private"."app_exam_junctions" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "private"."app_menu_junction" (
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "app_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "menu_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL
);

ALTER TABLE "private"."app_menu_junction" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "private"."exams" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "title" "text",
    "exam_settings" "jsonb"
);

ALTER TABLE "private"."exams" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "private"."quiz_app_junction" (
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "quiz_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "app_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL
);

ALTER TABLE "private"."quiz_app_junction" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "private"."session_custom_claim" (
    "session_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "app_id" "uuid"
);

ALTER TABLE "private"."session_custom_claim" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "private"."user_and_app_junction" (
    "user_id" "uuid" NOT NULL,
    "app_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);

ALTER TABLE "private"."user_and_app_junction" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "private"."users" (
    "id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "display_name" "text",
    "year_of_birth" "text",
    "gender" "text",
    "onboarding_status" boolean DEFAULT false,
    "display_picture" "text" DEFAULT 'https://cdn-icons-png.flaticon.com/512/9094/9094152.png'::"text",
    "profile_name" "text",
    "onboarding_done" boolean DEFAULT false NOT NULL,
    CONSTRAINT "profile_name_length_check" CHECK (("char_length"("profile_name") <= 250))
);

ALTER TABLE "private"."users" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."answers" (
    "id" bigint NOT NULL,
    "question_id" bigint,
    "text" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "is_correct" boolean DEFAULT false
);

ALTER TABLE "public"."answers" OWNER TO "postgres";

ALTER TABLE "public"."answers" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."answers_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE IF NOT EXISTS "public"."app_banners_junction" (
    "app_id" "uuid" NOT NULL,
    "banner_id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);

ALTER TABLE "public"."app_banners_junction" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."app_material_junction" (
    "app_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "material_id" "uuid" NOT NULL
);

ALTER TABLE "public"."app_material_junction" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."app_menu" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "menu_name" "text",
    "cover" "text",
    "cover_blurhash" "text" DEFAULT 'L6PZfSi_.AyE_3t7t7R**0o#DgR4'::"text",
    "settings" "jsonb" DEFAULT '{}'::"jsonb"
);

ALTER TABLE "public"."app_menu" OWNER TO "postgres";

CREATE OR REPLACE VIEW "public"."app_menu_view" WITH ("security_invoker"='on') AS
 SELECT "app_menu"."menu_name",
    "app_menu"."cover",
    "app_menu"."cover_blurhash",
    "app_menu"."settings"
   FROM "public"."app_menu";

ALTER TABLE "public"."app_menu_view" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."banners" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "banner_image_url" "text",
    "display_start" timestamp with time zone,
    "display_end" timestamp with time zone,
    "status" "text",
    "updated_at" timestamp with time zone,
    CONSTRAINT "banners_status_check" CHECK (("status" = ANY (ARRAY['active'::"text", 'inactive'::"text"])))
);

ALTER TABLE "public"."banners" OWNER TO "postgres";

ALTER TABLE "public"."banners" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."banners_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE IF NOT EXISTS "public"."content_reports" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "question_id" bigint,
    "user_id" "uuid",
    "report_reason" "text",
    "status" "text" DEFAULT 'pending'::"text"
);

ALTER TABLE "public"."content_reports" OWNER TO "postgres";

ALTER TABLE "public"."content_reports" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."content_reports_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE IF NOT EXISTS "public"."exam_materials_junction" (
    "exam_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "material_id" "uuid" NOT NULL
);

ALTER TABLE "public"."exam_materials_junction" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."exam_subjects_junction" (
    "exam_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "subject_id" "uuid" NOT NULL
);

ALTER TABLE "public"."exam_subjects_junction" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."material" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "title" "text",
    "content" "text",
    "subject" "uuid",
    "material_type" bigint
);

ALTER TABLE "public"."material" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."material_type" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "type_name" "text"
);

ALTER TABLE "public"."material_type" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."subject" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "subject_name" "text"
);

ALTER TABLE "public"."subject" OWNER TO "postgres";

CREATE OR REPLACE VIEW "public"."material_list" WITH ("security_invoker"='on') AS
 SELECT "material"."id",
    "material"."title",
    "subject"."subject_name",
    "material"."material_type",
    "material_type"."type_name",
    "material"."content"
   FROM (("public"."material"
     LEFT JOIN "public"."subject" ON (("material"."subject" = "subject"."id")))
     LEFT JOIN "public"."material_type" ON (("material"."material_type" = "material_type"."id")));

ALTER TABLE "public"."material_list" OWNER TO "postgres";

ALTER TABLE "public"."material_type" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."material_type_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE IF NOT EXISTS "public"."questions" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "text" "text",
    "quiz_id" "uuid" NOT NULL
);

ALTER TABLE "public"."questions" OWNER TO "postgres";

ALTER TABLE "public"."questions" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."questions_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE OR REPLACE VIEW "public"."quiz_view" AS
SELECT
    NULL::"uuid" AS "id",
    NULL::"text" AS "title",
    NULL::"text" AS "description",
    NULL::boolean AS "is_published",
    NULL::"json" AS "questions";

ALTER TABLE "public"."quiz_view" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."quizzes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "title" "text",
    "description" "text",
    "is_published" boolean
);

ALTER TABLE "public"."quizzes" OWNER TO "postgres";

CREATE OR REPLACE VIEW "public"."quizzes_view" WITH ("security_invoker"='on') AS
 SELECT "quizzes"."id",
    "quizzes"."created_at",
    "quizzes"."title",
    "quizzes"."description",
    "quizzes"."is_published"
   FROM "public"."quizzes";

ALTER TABLE "public"."quizzes_view" OWNER TO "postgres";

CREATE OR REPLACE VIEW "public"."users_view" AS
 SELECT "users"."id",
    "users"."created_at",
    "users"."display_name",
    "users"."year_of_birth",
    "users"."gender",
    "users"."onboarding_status",
    "users"."display_picture",
    "users"."profile_name",
    "users"."onboarding_done"
   FROM "private"."users";

ALTER TABLE "public"."users_view" OWNER TO "postgres";

ALTER TABLE ONLY "private"."app_exam_junctions"
    ADD CONSTRAINT "app_exam_junctions_pkey" PRIMARY KEY ("exam_id", "app_id");

ALTER TABLE ONLY "private"."app_menu_junction"
    ADD CONSTRAINT "app_menu_junction_pkey" PRIMARY KEY ("app_id", "menu_id");

ALTER TABLE ONLY "private"."apps"
    ADD CONSTRAINT "apps_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "private"."exams"
    ADD CONSTRAINT "exams_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "private"."users"
    ADD CONSTRAINT "profile_name_unique" UNIQUE ("profile_name");

ALTER TABLE ONLY "private"."quiz_app_junction"
    ADD CONSTRAINT "quiz_app_junction_pkey" PRIMARY KEY ("quiz_id", "app_id");

ALTER TABLE ONLY "private"."session_custom_claim"
    ADD CONSTRAINT "session_custom_claim_pkey" PRIMARY KEY ("session_id");

ALTER TABLE ONLY "private"."user_and_app_junction"
    ADD CONSTRAINT "user_and_app_junction_pkey" PRIMARY KEY ("user_id", "app_id");

ALTER TABLE ONLY "private"."users"
    ADD CONSTRAINT "users_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."answers"
    ADD CONSTRAINT "answers_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."app_banners_junction"
    ADD CONSTRAINT "app_banners_junction_pkey" PRIMARY KEY ("app_id", "banner_id");

ALTER TABLE ONLY "public"."app_material_junction"
    ADD CONSTRAINT "app_material_junction_pkey" PRIMARY KEY ("app_id", "material_id");

ALTER TABLE ONLY "public"."app_menu"
    ADD CONSTRAINT "app_menu_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."banners"
    ADD CONSTRAINT "banners_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."content_reports"
    ADD CONSTRAINT "content_reports_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."exam_materials_junction"
    ADD CONSTRAINT "exam_materials_junction_pkey" PRIMARY KEY ("exam_id", "material_id");

ALTER TABLE ONLY "public"."exam_subjects_junction"
    ADD CONSTRAINT "exam_subjects_junction_pkey" PRIMARY KEY ("exam_id", "subject_id");

ALTER TABLE ONLY "public"."material_type"
    ADD CONSTRAINT "material_type_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."material"
    ADD CONSTRAINT "notes_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."questions"
    ADD CONSTRAINT "questions_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."quizzes"
    ADD CONSTRAINT "quizzes_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."subject"
    ADD CONSTRAINT "subject_pkey" PRIMARY KEY ("id");

CREATE OR REPLACE VIEW "public"."quiz_view" WITH ("security_invoker"='on') AS
 SELECT "quizzes"."id",
    "quizzes"."title",
    "quizzes"."description",
    "quizzes"."is_published",
    "json_agg"("json_build_object"('id', "questions"."id", 'text', "questions"."text", 'answers', ( SELECT "json_agg"("json_build_object"('id', "answers"."id", 'text', "answers"."text", 'is_correct', "answers"."is_correct")) AS "answers"
           FROM "public"."answers"
          WHERE ("answers"."question_id" = "questions"."id")))) AS "questions"
   FROM ("public"."quizzes"
     LEFT JOIN "public"."questions" ON (("quizzes"."id" = "questions"."quiz_id")))
  GROUP BY "quizzes"."id";

ALTER TABLE ONLY "private"."app_exam_junctions"
    ADD CONSTRAINT "exam_app_junctions_app_id_fkey" FOREIGN KEY ("app_id") REFERENCES "private"."apps"("id") ON DELETE RESTRICT;

ALTER TABLE ONLY "private"."app_exam_junctions"
    ADD CONSTRAINT "exam_app_junctions_exam_id_fkey" FOREIGN KEY ("exam_id") REFERENCES "private"."exams"("id") ON DELETE RESTRICT;

ALTER TABLE ONLY "private"."session_custom_claim"
    ADD CONSTRAINT "fk_session_id" FOREIGN KEY ("session_id") REFERENCES "auth"."sessions"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "private"."session_custom_claim"
    ADD CONSTRAINT "private_session_custom_claim_app_id_fkey" FOREIGN KEY ("app_id") REFERENCES "private"."apps"("id");

ALTER TABLE ONLY "private"."app_menu_junction"
    ADD CONSTRAINT "public_app_menu_junction_app_id_fkey" FOREIGN KEY ("app_id") REFERENCES "private"."apps"("id") ON DELETE RESTRICT;

ALTER TABLE ONLY "private"."app_menu_junction"
    ADD CONSTRAINT "public_app_menu_junction_menu_id_fkey" FOREIGN KEY ("menu_id") REFERENCES "public"."app_menu"("id");

ALTER TABLE ONLY "private"."quiz_app_junction"
    ADD CONSTRAINT "public_quiz_app_junction_app_id_fkey" FOREIGN KEY ("app_id") REFERENCES "private"."apps"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "private"."quiz_app_junction"
    ADD CONSTRAINT "public_quiz_app_junction_quiz_id_fkey" FOREIGN KEY ("quiz_id") REFERENCES "public"."quizzes"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "private"."session_custom_claim"
    ADD CONSTRAINT "session_custom_claim_session_id_fkey" FOREIGN KEY ("session_id") REFERENCES "auth"."sessions"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "private"."user_and_app_junction"
    ADD CONSTRAINT "user_app_junction_app_id_fkey" FOREIGN KEY ("app_id") REFERENCES "private"."apps"("id");

ALTER TABLE ONLY "private"."user_and_app_junction"
    ADD CONSTRAINT "user_app_junction_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "private"."users"("id");

ALTER TABLE ONLY "private"."users"
    ADD CONSTRAINT "users_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."content_reports"
    ADD CONSTRAINT "content_reports_question_id_fkey" FOREIGN KEY ("question_id") REFERENCES "public"."questions"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."content_reports"
    ADD CONSTRAINT "content_reports_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "private"."users"("id") ON DELETE RESTRICT;

ALTER TABLE ONLY "public"."answers"
    ADD CONSTRAINT "public_answers_question_id_fkey" FOREIGN KEY ("question_id") REFERENCES "public"."questions"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."app_banners_junction"
    ADD CONSTRAINT "public_app_banners_junction_app_id_fkey" FOREIGN KEY ("app_id") REFERENCES "private"."apps"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."app_banners_junction"
    ADD CONSTRAINT "public_app_banners_junction_banner_id_fkey" FOREIGN KEY ("banner_id") REFERENCES "public"."banners"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."app_material_junction"
    ADD CONSTRAINT "public_app_material_junction_app_id_fkey" FOREIGN KEY ("app_id") REFERENCES "private"."apps"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."app_material_junction"
    ADD CONSTRAINT "public_app_material_junction_material_id_fkey" FOREIGN KEY ("material_id") REFERENCES "public"."material"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."exam_materials_junction"
    ADD CONSTRAINT "public_exam_materials_junction_exam_id_fkey" FOREIGN KEY ("exam_id") REFERENCES "private"."exams"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."exam_materials_junction"
    ADD CONSTRAINT "public_exam_materials_junction_material_id_fkey" FOREIGN KEY ("material_id") REFERENCES "public"."material"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."exam_subjects_junction"
    ADD CONSTRAINT "public_exam_subjects_junction_exam_id_fkey" FOREIGN KEY ("exam_id") REFERENCES "private"."exams"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."exam_subjects_junction"
    ADD CONSTRAINT "public_exam_subjects_junction_subject_id_fkey" FOREIGN KEY ("subject_id") REFERENCES "public"."subject"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."material"
    ADD CONSTRAINT "public_material_material_type_fkey" FOREIGN KEY ("material_type") REFERENCES "public"."material_type"("id");

ALTER TABLE ONLY "public"."material"
    ADD CONSTRAINT "public_notes_subject_fkey" FOREIGN KEY ("subject") REFERENCES "public"."subject"("id") ON DELETE RESTRICT;

ALTER TABLE ONLY "public"."questions"
    ADD CONSTRAINT "public_questions_quiz_id_fkey" FOREIGN KEY ("quiz_id") REFERENCES "public"."quizzes"("id") ON DELETE CASCADE;

ALTER TABLE "private"."app_exam_junctions" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "private"."apps" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "private"."exams" ENABLE ROW LEVEL SECURITY;

CREATE POLICY "App Based Access" ON "public"."quizzes" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "private"."quiz_app_junction"
  WHERE (("quiz_app_junction"."quiz_id" = "quizzes"."id") AND ("quiz_app_junction"."app_id" = "public"."get_session_app_id"())))));

CREATE POLICY "App_Based_Access" ON "public"."app_menu" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "private"."app_menu_junction"
  WHERE (("app_menu_junction"."menu_id" = "app_menu"."id") AND ("app_menu_junction"."app_id" = "public"."get_session_app_id"())))));

CREATE POLICY "Authenticated users can view subjects for their app" ON "public"."subject" FOR SELECT TO "authenticated" USING ("public"."check_subject_access"("id"));

CREATE POLICY "Enable read access for all users" ON "public"."answers" FOR SELECT TO "authenticated" USING (true);

CREATE POLICY "Enable read access for all users" ON "public"."material_type" FOR SELECT TO "authenticated" USING (true);

CREATE POLICY "Enable read access for all users" ON "public"."questions" FOR SELECT TO "authenticated" USING (true);

CREATE POLICY "Select material if app and material are in junction" ON "public"."material" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."app_material_junction"
  WHERE (("app_material_junction"."material_id" = "material"."id") AND ("app_material_junction"."app_id" = "public"."get_session_app_id"())))));

ALTER TABLE "public"."answers" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."app_banners_junction" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."app_menu" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."banners" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."content_reports" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."exam_materials_junction" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."exam_subjects_junction" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."material" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."material_type" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."questions" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."quizzes" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."subject" ENABLE ROW LEVEL SECURITY;

ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";

GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";

GRANT ALL ON FUNCTION "public"."check_subject_access"("subject_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."check_subject_access"("subject_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_subject_access"("subject_id" "uuid") TO "service_role";

GRANT ALL ON FUNCTION "public"."count_correct_answers"("quiz" "json") TO "anon";
GRANT ALL ON FUNCTION "public"."count_correct_answers"("quiz" "json") TO "authenticated";
GRANT ALL ON FUNCTION "public"."count_correct_answers"("quiz" "json") TO "service_role";

GRANT ALL ON FUNCTION "public"."count_unattempted_answers"("quiz" "json") TO "anon";
GRANT ALL ON FUNCTION "public"."count_unattempted_answers"("quiz" "json") TO "authenticated";
GRANT ALL ON FUNCTION "public"."count_unattempted_answers"("quiz" "json") TO "service_role";

GRANT ALL ON FUNCTION "public"."count_wrong_answers"("quiz" "json") TO "anon";
GRANT ALL ON FUNCTION "public"."count_wrong_answers"("quiz" "json") TO "authenticated";
GRANT ALL ON FUNCTION "public"."count_wrong_answers"("quiz" "json") TO "service_role";

GRANT ALL ON TABLE "private"."apps" TO "anon";
GRANT ALL ON TABLE "private"."apps" TO "authenticated";
GRANT ALL ON TABLE "private"."apps" TO "service_role";

GRANT ALL ON FUNCTION "public"."get_apps_view"("p_app_domain" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_apps_view"("p_app_domain" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_apps_view"("p_app_domain" "text") TO "service_role";

GRANT ALL ON FUNCTION "public"."get_exams_by_app"("p_app_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_exams_by_app"("p_app_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_exams_by_app"("p_app_id" "uuid") TO "service_role";

GRANT ALL ON FUNCTION "public"."get_quiz_results"("quiz" "json") TO "anon";
GRANT ALL ON FUNCTION "public"."get_quiz_results"("quiz" "json") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_quiz_results"("quiz" "json") TO "service_role";

GRANT ALL ON FUNCTION "public"."get_session_app_id"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_session_app_id"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_session_app_id"() TO "service_role";

GRANT ALL ON FUNCTION "public"."get_subjects"("exam_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_subjects"("exam_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_subjects"("exam_id" "uuid") TO "service_role";

GRANT ALL ON FUNCTION "public"."insert_user_app_relation"("p_app_id" "uuid", "p_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."insert_user_app_relation"("p_app_id" "uuid", "p_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."insert_user_app_relation"("p_app_id" "uuid", "p_user_id" "uuid") TO "service_role";

GRANT ALL ON FUNCTION "public"."is_answer_correct"("question" "json", "selected_answer_id" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."is_answer_correct"("question" "json", "selected_answer_id" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_answer_correct"("question" "json", "selected_answer_id" integer) TO "service_role";

GRANT ALL ON FUNCTION "public"."update_session_custom_claim"("p_app_domain" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."update_session_custom_claim"("p_app_domain" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_session_custom_claim"("p_app_domain" "text") TO "service_role";

GRANT ALL ON TABLE "private"."app_menu_junction" TO "anon";
GRANT ALL ON TABLE "private"."app_menu_junction" TO "authenticated";
GRANT ALL ON TABLE "private"."app_menu_junction" TO "service_role";

GRANT ALL ON TABLE "private"."quiz_app_junction" TO "anon";
GRANT ALL ON TABLE "private"."quiz_app_junction" TO "authenticated";
GRANT ALL ON TABLE "private"."quiz_app_junction" TO "service_role";

GRANT ALL ON TABLE "public"."answers" TO "anon";
GRANT ALL ON TABLE "public"."answers" TO "authenticated";
GRANT ALL ON TABLE "public"."answers" TO "service_role";

GRANT ALL ON SEQUENCE "public"."answers_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."answers_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."answers_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."app_banners_junction" TO "anon";
GRANT ALL ON TABLE "public"."app_banners_junction" TO "authenticated";
GRANT ALL ON TABLE "public"."app_banners_junction" TO "service_role";

GRANT ALL ON TABLE "public"."app_material_junction" TO "anon";
GRANT ALL ON TABLE "public"."app_material_junction" TO "authenticated";
GRANT ALL ON TABLE "public"."app_material_junction" TO "service_role";

GRANT ALL ON TABLE "public"."app_menu" TO "anon";
GRANT ALL ON TABLE "public"."app_menu" TO "authenticated";
GRANT ALL ON TABLE "public"."app_menu" TO "service_role";

GRANT ALL ON TABLE "public"."app_menu_view" TO "anon";
GRANT ALL ON TABLE "public"."app_menu_view" TO "authenticated";
GRANT ALL ON TABLE "public"."app_menu_view" TO "service_role";

GRANT ALL ON TABLE "public"."banners" TO "anon";
GRANT ALL ON TABLE "public"."banners" TO "authenticated";
GRANT ALL ON TABLE "public"."banners" TO "service_role";

GRANT ALL ON SEQUENCE "public"."banners_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."banners_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."banners_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."content_reports" TO "anon";
GRANT ALL ON TABLE "public"."content_reports" TO "authenticated";
GRANT ALL ON TABLE "public"."content_reports" TO "service_role";

GRANT ALL ON SEQUENCE "public"."content_reports_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."content_reports_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."content_reports_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."exam_materials_junction" TO "anon";
GRANT ALL ON TABLE "public"."exam_materials_junction" TO "authenticated";
GRANT ALL ON TABLE "public"."exam_materials_junction" TO "service_role";

GRANT ALL ON TABLE "public"."exam_subjects_junction" TO "anon";
GRANT ALL ON TABLE "public"."exam_subjects_junction" TO "authenticated";
GRANT ALL ON TABLE "public"."exam_subjects_junction" TO "service_role";

GRANT ALL ON TABLE "public"."material" TO "anon";
GRANT ALL ON TABLE "public"."material" TO "authenticated";
GRANT ALL ON TABLE "public"."material" TO "service_role";

GRANT ALL ON TABLE "public"."material_type" TO "anon";
GRANT ALL ON TABLE "public"."material_type" TO "authenticated";
GRANT ALL ON TABLE "public"."material_type" TO "service_role";

GRANT ALL ON TABLE "public"."subject" TO "anon";
GRANT ALL ON TABLE "public"."subject" TO "authenticated";
GRANT ALL ON TABLE "public"."subject" TO "service_role";

GRANT ALL ON TABLE "public"."material_list" TO "anon";
GRANT ALL ON TABLE "public"."material_list" TO "authenticated";
GRANT ALL ON TABLE "public"."material_list" TO "service_role";

GRANT ALL ON SEQUENCE "public"."material_type_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."material_type_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."material_type_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."questions" TO "anon";
GRANT ALL ON TABLE "public"."questions" TO "authenticated";
GRANT ALL ON TABLE "public"."questions" TO "service_role";

GRANT ALL ON SEQUENCE "public"."questions_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."questions_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."questions_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."quiz_view" TO "anon";
GRANT ALL ON TABLE "public"."quiz_view" TO "authenticated";
GRANT ALL ON TABLE "public"."quiz_view" TO "service_role";

GRANT ALL ON TABLE "public"."quizzes" TO "anon";
GRANT ALL ON TABLE "public"."quizzes" TO "authenticated";
GRANT ALL ON TABLE "public"."quizzes" TO "service_role";

GRANT ALL ON TABLE "public"."quizzes_view" TO "anon";
GRANT ALL ON TABLE "public"."quizzes_view" TO "authenticated";
GRANT ALL ON TABLE "public"."quizzes_view" TO "service_role";

GRANT ALL ON TABLE "public"."users_view" TO "anon";
GRANT ALL ON TABLE "public"."users_view" TO "authenticated";
GRANT ALL ON TABLE "public"."users_view" TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";

RESET ALL;
