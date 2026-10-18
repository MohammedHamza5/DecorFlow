import 'dart:math';
import 'package:stream_pay/features/premium/core/premium_dependencies.dart';
import '../../domain/models/web_quote.dart';

class WebQuoteRepository {
  final PremiumDependencies _deps;

  WebQuoteRepository(this._deps);

  /// Helper to generate a random cryptographically secure-like token
  String _generateToken() {
    final rand = Random.secure();
    final values = List<int>.generate(24, (i) => rand.nextInt(256));
    return values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Gets or creates interactive web quote configuration for a core quote.
  Future<WebQuote> getOrCreateWebQuote(String quoteId) async {
    try {
      // Try fetching first
      final existing = await _deps.supabaseClient
          .from('premium_web_quotes')
          .select()
          .eq('quote_id', quoteId)
          .maybeSingle();

      if (existing != null) {
        return WebQuote.fromJson(existing);
      }

      // If not exists, create new web quote config
      final token = _generateToken();
      final data = {
        'quote_id': quoteId,
        'share_token': token,
        'allow_customization': true,
        'show_alternatives': true,
      };

      final response = await _deps.supabaseClient
          .from('premium_web_quotes')
          .insert(data)
          .select()
          .single();

      return WebQuote.fromJson(response);
    } catch (e, st) {
      _deps.logSystem(
        level: 'error',
        message: 'Failed to get/create web quote configuration',
        error: e.toString(),
        stackTrace: st.toString(),
      );
      rethrow;
    }
  }

  /// Generates the interactive web link.
  String generateWebQuoteLink(WebQuote webQuote) {
    // We point this to a web-quote loader client.
    // In Supabase, we can host a simple static index.html in a public bucket or a Vercel URL:
    const baseUrl = 'https://stream-pay-quotes.vercel.app';
    return '$baseUrl/quote.html?token=${webQuote.shareToken}';
  }

  /// Saves the interactive options.
  Future<void> updateWebQuoteSettings({
    required String quoteId,
    required bool allowCustomization,
    required bool showAlternatives,
  }) async {
    try {
      await _deps.supabaseClient
          .from('premium_web_quotes')
          .update({
            'allow_customization': allowCustomization,
            'show_alternatives': showAlternatives,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('quote_id', quoteId);
    } catch (e, st) {
      _deps.logSystem(
        level: 'error',
        message: 'Failed to update web quote settings',
        error: e.toString(),
        stackTrace: st.toString(),
      );
      rethrow;
    }
  }
}
