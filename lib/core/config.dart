class AppConfig {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://elvdhgrpwutyonbuzgvb.supabase.co',
  );

  /// Chave anon/publishable — pública de propósito. Nunca use service_role no app.
  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVsdmRoZ3Jwd3V0eW9uYnV6Z3ZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg5ODU4OTgsImV4cCI6MjEwNDU2MTg5OH0.O7E9V_c3eD4LzkP92xG8Ff2nnXHbXDfAwlojVZzOHkA',
  );

  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static String shareUri(String token) => 'spotfit://playlist/$token';
}
