class AppConfig {
  // Supply your Google Places API key at runtime:
  // flutter run --dart-define=GOOGLE_PLACES_API_KEY=YOUR_KEY
  static const googlePlacesApiKey = String.fromEnvironment(
    'GOOGLE_PLACES_API_KEY',
    defaultValue: '',
  );

  // Supabase config (prefer dart-define)
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://nxvuivnpeuvcnimimnii.supabase.co',
  );
  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im54dnVpdm5wZXV2Y25pbWltbmlpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTczNTQ4MTUsImV4cCI6MjA3MjkzMDgxNX0.Tf7o4b5AKj2Kgpa0pF2ifuEFz-AHMqvylndO8CrMsew',
  );

  // MasjidNear API base (search endpoint). Changeable via dart-define.
  // Example: flutter run --dart-define=MASJIDNEAR_API_BASE=https://api.masjidnear.me/v1/masjids/search
  static const masjidNearApiBase = String.fromEnvironment(
    'MASJIDNEAR_API_BASE',
    defaultValue: 'https://api.masjidnear.me/v1/masjids/search',
  );
}
