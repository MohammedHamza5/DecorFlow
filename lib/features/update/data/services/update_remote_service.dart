import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_version_model.dart';

class UpdateRemoteService {
  final SupabaseClient supabase;

  UpdateRemoteService(this.supabase);

  /// Fetches the latest version available on the server for the specified platform.
  Future<AppVersionModel?> getLatestVersion(String platform) async {
    try {
      final response = await supabase
          .from('app_versions')
          .select()
          .eq('platform', platform)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle()
          .timeout(const Duration(seconds: 30));

      if (response == null) {
        return null;
      }

      return AppVersionModel.fromJson(response);
    } catch (e) {
      // Return null if table doesn't exist yet or connection error
      return null;
    }
  }
}
