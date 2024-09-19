import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  late final SupabaseClient _client;

  Future<void> initialize(
      {required String url, required String anonKey}) async {
    await Supabase.initialize(url: url, anonKey: anonKey);
    _client = Supabase.instance.client;
  }

  SupabaseClient get client => _client;

  Future<void> signInAnonymously() async {
    await _client.auth.signInAnonymously();
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  Future<Session?> getSession() async {
    return _client.auth.currentSession;
  }

  Future<void> updateSessionCustomClaim(String appDomain) async {
    try {
      await _client.rpc('update_session_custom_claim', params: {
        'p_app_domain': appDomain,
      });
    } catch (e) {
      print('Error updating session custom claim: $e');
      rethrow;
    }
  }
}

final supabaseService = SupabaseService();
