import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'quote_studio_screen.dart';

/// Legacy QuoteDetailScreen forwarded to the state-of-the-art SmartQuoteStudioScreen.
class QuoteDetailScreen extends ConsumerWidget {
  final String quoteId;

  const QuoteDetailScreen({super.key, required this.quoteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SmartQuoteStudioScreen(quoteId: quoteId);
  }
}
