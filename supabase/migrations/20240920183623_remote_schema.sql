set check_function_bodies = off;

CREATE OR REPLACE FUNCTION auth.on_session_insert()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  -- Check if the session_id already exists
  IF NOT EXISTS (
    SELECT 1
    FROM private.session_custom_claim
    WHERE session_id = NEW.id
  ) THEN
    -- Insert a new record if session_id doesn't exist
    INSERT INTO private.session_custom_claim (session_id)
    VALUES (NEW.id);
  END IF;

  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION auth.on_user_delete()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  -- Delete the corresponding row in public.users
  DELETE FROM public.users
  WHERE id = OLD.id;

  RETURN OLD;
END;
$function$
;

CREATE OR REPLACE FUNCTION auth.on_user_insert()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  random_uuid uuid;
  profile_name text;
BEGIN
  -- Generate a random UUID
  random_uuid := gen_random_uuid();

  -- Check if the id already exists in public.users
  IF NOT EXISTS (
    SELECT 1
    FROM private.users
    WHERE id = NEW.id
  ) THEN
    -- Check if name exists, if not use 'user' as the prefix
    IF NEW.raw_user_meta_data->>'name' IS NOT NULL THEN
      profile_name := NEW.raw_user_meta_data->>'name' || '_' || random_uuid::text;
    ELSE
      profile_name := 'user_' || random_uuid::text;
    END IF;

    -- Insert a new user record if id doesn't exist
    INSERT INTO private.users (id, display_name, profile_name)
    VALUES (
      NEW.id,
      NEW.raw_user_meta_data->>'name',
      profile_name
    );
  END IF;

  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE TRIGGER on_session_insert_trigger AFTER INSERT ON auth.sessions FOR EACH ROW EXECUTE FUNCTION auth.on_session_insert();

CREATE OR REPLACE TRIGGER on_user_delete_trigger AFTER DELETE ON auth.users FOR EACH ROW EXECUTE FUNCTION auth.on_user_delete();

CREATE OR REPLACE TRIGGER on_user_insert_trigger AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION auth.on_user_insert();


grant delete on table "storage"."s3_multipart_uploads" to "postgres";

grant insert on table "storage"."s3_multipart_uploads" to "postgres";

grant references on table "storage"."s3_multipart_uploads" to "postgres";

grant select on table "storage"."s3_multipart_uploads" to "postgres";

grant trigger on table "storage"."s3_multipart_uploads" to "postgres";

grant truncate on table "storage"."s3_multipart_uploads" to "postgres";

grant update on table "storage"."s3_multipart_uploads" to "postgres";

grant delete on table "storage"."s3_multipart_uploads_parts" to "postgres";

grant insert on table "storage"."s3_multipart_uploads_parts" to "postgres";

grant references on table "storage"."s3_multipart_uploads_parts" to "postgres";

grant select on table "storage"."s3_multipart_uploads_parts" to "postgres";

grant trigger on table "storage"."s3_multipart_uploads_parts" to "postgres";

grant truncate on table "storage"."s3_multipart_uploads_parts" to "postgres";

grant update on table "storage"."s3_multipart_uploads_parts" to "postgres";


