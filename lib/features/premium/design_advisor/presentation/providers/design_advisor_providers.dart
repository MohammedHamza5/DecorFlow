import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_pay/features/premium/core/premium_dependencies.dart';
import '../../data/repositories/design_advisor_repository.dart';
import '../../domain/models/design_template.dart';
import '../../domain/models/template_material.dart';

/// Provider for DesignAdvisorRepository.
final designAdvisorRepositoryProvider = Provider<DesignAdvisorRepository>((ref) {
  final deps = ref.watch(premiumDependenciesProvider);
  return DesignAdvisorRepository(deps);
});

/// FutureProvider that fetches all design templates.
final designTemplatesProvider = FutureProvider<List<DesignTemplate>>((ref) async {
  final repository = ref.watch(designAdvisorRepositoryProvider);
  return repository.getTemplates();
});

/// FutureProvider that fetches all materials for a design template.
final templateMaterialsProvider = FutureProvider.family<List<TemplateMaterial>, String>((ref, templateId) async {
  final repository = ref.watch(designAdvisorRepositoryProvider);
  return repository.getTemplateMaterials(templateId);
});
