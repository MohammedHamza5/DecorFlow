import 'package:supabase_flutter/supabase_flutter.dart';
import '../local_db/app_database.dart';
import '../monitoring/smart_logger.dart';

class IntegrityChecker {
  final AppDatabase _db;
  final SupabaseClient _supabase;
  final SmartLogger _logger;

  IntegrityChecker(this._db, this._supabase, this._logger);

  /// Run a series of intelligent checks on the local database versus rules and remote state.
  Future<void> runFullCheck() async {
    _logger.info('Starting full data integrity check');
    try {
      await _checkNegativeBalances();
      await _checkRemoteCountMismatches();
      // Add more domain-specific checks here
      _logger.info('Completed data integrity check');
    } catch (e, stack) {
      _logger.error('Error during data integrity check', error: e, stackTrace: stack);
    }
  }

  /// Example check: Ensure no quote has a negative final total
  Future<void> _checkNegativeBalances() async {
    final quotes = await _db.select(_db.localQuotes).get();
    for (final quote in quotes) {
      if (quote.totalAmount < 0) {
        _logger.dataConflict(
          'Quote ${quote.id} has a negative final total (${quote.totalAmount})',
          context: {'quote_id': quote.id, 'total': quote.totalAmount},
        );
      }
    }
  }

  /// Example check: Compare local product count with remote product count
  Future<void> _checkRemoteCountMismatches() async {
    try {
      final localProducts = await _db.select(_db.localProducts).get();
      final response = await _supabase.from('products').select('id').count(CountOption.exact);
      final remoteCount = response.count;

      if (localProducts.length != remoteCount) {
        _logger.dataConflict(
          'Product count mismatch: Local(${localProducts.length}) vs Remote($remoteCount)',
          context: {'local_count': localProducts.length, 'remote_count': remoteCount},
        );
      }
    } catch (e) {
      _logger.warning('Could not verify remote product count', error: e);
    }
  }
}
