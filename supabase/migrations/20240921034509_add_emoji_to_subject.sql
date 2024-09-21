-- Add emoji column to existing subject table
ALTER TABLE public.subject
ADD COLUMN emoji text NOT NULL DEFAULT '📚';
