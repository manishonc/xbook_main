const bool useLocalEnvironment = false;

const String localSupabaseUrl = 'http://127.0.0.1:54321';
const String localSupabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';

const String productionSupabaseUrl = 'https://gmddhurvpyoqfcjkwhcr.supabase.co';
const String productionSupabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdtZGRodXJ2cHlvcWZjamt3aGNyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTA5NTQ2NjYsImV4cCI6MjAyNjUzMDY2Nn0.DVTwKxIK-nOjF-REeFFPDdenabXeHX8uBm-XQ8Z4OoQ';

const String supabaseUrl =
    useLocalEnvironment ? localSupabaseUrl : productionSupabaseUrl;
const String supabaseAnonKey =
    useLocalEnvironment ? localSupabaseAnonKey : productionSupabaseAnonKey;

// ignore: constant_identifier_names
const AppName = 'XBook';
// ignore: constant_identifier_names
const AppDomain = 'xbook.app';
