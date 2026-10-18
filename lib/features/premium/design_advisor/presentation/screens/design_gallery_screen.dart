import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/design_advisor_providers.dart';
import 'package:stream_pay/core/responsive/app_responsive.dart';
import 'package:stream_pay/core/responsive/constrained_body.dart';

class DesignGalleryScreen extends ConsumerWidget {
  const DesignGalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(designTemplatesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('مستشار التصميم الذكي'),
        centerTitle: true,
      ),
      body: templatesAsync.when(
        data: (templates) {
          if (templates.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد تصميمات متاحة حالياً',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          return ResponsiveBuilder(
            builder: (context, info) {
              final crossAxisCount = info.isDesktop ? 3 : 2;
              return ConstrainedBody(
                maxWidth: 900,
                child: GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                  ),
                  itemCount: templates.length,
                  itemBuilder: (context, index) {
                    final template = templates[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          context.pushNamed('premiumDesignCalculator', extra: template);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: template.imageUrl != null && template.imageUrl!.isNotEmpty
                                  ? Image.network(
                                      template.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => _buildPlaceholderIcon(),
                                    )
                                  : _buildPlaceholderIcon(),
                            ),
                            Container(
                              padding: const EdgeInsets.all(12.0),
                              color: Colors.white,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    template.titleAr,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (template.descriptionAr != null)
                                    Text(
                                      template.descriptionAr!,
                                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('حدث خطأ: $error', style: const TextStyle(color: Colors.red))),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
    );
  }
}
