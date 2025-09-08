class AppConfig {
  // Supply your Google Places API key at runtime:
  // flutter run --dart-define=GOOGLE_PLACES_API_KEY=YOUR_KEY
  static const googlePlacesApiKey = String.fromEnvironment(
    'GOOGLE_PLACES_API_KEY',
    defaultValue: '',
  );
}

