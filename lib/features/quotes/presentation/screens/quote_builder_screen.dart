import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'quote_studio_screen.dart';

/// Legacy QuoteBuilderScreen forwarded to the state-of-the-art SmartQuoteStudioScreen.
class QuoteBuilderScreen extends ConsumerWidget {
  final String? quoteId;
  final Map<String, dynamic>? initialItem;

  const QuoteBuilderScreen({super.key, this.quoteId, this.initialItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SmartQuoteStudioScreen(
      quoteId: quoteId,
      initialItem: initialItem,
    );
  }
}
