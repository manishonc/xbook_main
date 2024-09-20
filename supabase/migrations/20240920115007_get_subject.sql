-- Get exams by app_id
CREATE OR REPLACE FUNCTION public.get_exams_by_app (p_app_id UUID) RETURNS TABLE (
  exam_id UUID,
  created_at TIMESTAMP WITH TIME ZONE,
  title TEXT,
  exam_settings jsonb
) SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT exams.id, exams.created_at, exams.title, exams.exam_settings
    FROM private.app_exam_junctions
    JOIN private.exams ON app_exam_junctions.exam_id = exams.id
    WHERE app_exam_junctions.app_id = p_app_id;
END;
$$ LANGUAGE plpgsql;


-- Create a secure function to check subject access
CREATE OR REPLACE FUNCTION public.check_subject_access(subject_id uuid)
RETURNS boolean
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
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

-- Grant execute permission on the function to authenticated users
GRANT EXECUTE ON FUNCTION public.check_subject_access(uuid) TO authenticated;

-- Enable RLS on the subject table
ALTER TABLE public.subject ENABLE ROW LEVEL SECURITY;

-- Create the RLS policy for authenticated users
CREATE POLICY "Authenticated users can view subjects for their app" 
ON public.subject
FOR SELECT
TO authenticated
USING (
  public.check_subject_access(id)
);