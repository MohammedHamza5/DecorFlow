/// Application-wide constants for the Decor Calculator app.
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'السويدي للديكور';
  static const String appNameEn = 'ElSweedy for Decoration';
  static const String appVersion = '1.0.2';

  // Supabase
  static const String supabaseUrl = 'https://plylvscdynposbqcshni.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBseWx2c2NkeW5wb3NicWNzaG5pIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI3MzA3NTIsImV4cCI6MjA4ODMwNjc1Mn0.FqXf-DAs-GDChXreSYpFhrZpmQ4mbYaOHxydBYFd3GE';

  // Database
  static const String databaseName = 'decor_pro.db';
  static const int databaseVersion = 1;

  // Calculator Defaults
  static const double defaultWastePercent = 0.10; // 10%
  static const double minWastePercent = 0.0;
  static const double maxWastePercent = 0.30; // 30%
  static const int recentProductsLimit = 10;
  static const int recentMeasurementsLimit = 10;

  // Quote
  static const int quoteValidityDays = 14;

  // Search
  static const int searchDebounceMs = 300;
  static const int minSearchLength = 2;

  // Pagination
  static const int pageSize = 20;
}
