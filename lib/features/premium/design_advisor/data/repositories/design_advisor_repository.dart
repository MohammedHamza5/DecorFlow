import 'dart:math';
import 'package:stream_pay/features/premium/core/premium_dependencies.dart';
import '../../domain/models/design_template.dart';
import '../../domain/models/template_material.dart';

class DesignAdvisorRepository {
  final PremiumDependencies _deps;

  DesignAdvisorRepository(this._deps);

  /// Fetches all active design templates (both system global templates and shop custom ones).
  Future<List<DesignTemplate>> getTemplates() async {
    final shopId = _deps.currentShopId;

    try {
      var query = _deps.supabaseClient
          .from('premium_design_templates')
          .select()
          .eq('is_active', true);

      // Fetch templates that belong to the shop OR are system-wide (shop_id is null)
      if (shopId != null) {
        // Since supabase filter for OR can be constructed or we fetch all and filter locally:
        final response = await query;
        return (response as List)
            .map((json) => DesignTemplate.fromJson(json as Map<String, dynamic>))
            .where((t) => t.shopId == null || t.shopId == shopId)
            .toList();
      } else {
        final response = await query.isFilter('shop_id', null);
        return (response as List)
            .map((json) => DesignTemplate.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e, st) {
      _deps.logSystem(
        level: 'error',
        message: 'Failed to fetch design templates',
        error: e.toString(),
        stackTrace: st.toString(),
      );
      rethrow;
    }
  }

  /// Fetches all material specifications for a design template.
  Future<List<TemplateMaterial>> getTemplateMaterials(String templateId) async {
    try {
      final response = await _deps.supabaseClient
          .from('premium_template_materials')
          .select()
          .eq('template_id', templateId);

      return (response as List)
          .map((json) => TemplateMaterial.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      _deps.logSystem(
        level: 'error',
        message: 'Failed to fetch materials for template $templateId',
        error: e.toString(),
        stackTrace: st.toString(),
      );
      rethrow;
    }
  }

  /// Calculates the recommended quantities of materials in the template based on wall dimensions.
  /// [wallWidth] and [wallHeight] are in centimeters.
  /// Returns a Map of productCategory to double quantity.
  Map<String, double> calculateRecommendedQuantities({
    required List<TemplateMaterial> materials,
    required double wallWidth, // in cm
    required double wallHeight, // in cm
    double panelWidth = 122.0, // default panel width in cm (e.g. marble sheet)
    double panelLength = 280.0, // default panel length in cm
    double louverWidth = 17.0, // default wood louver width in cm
    double louverLength = 280.0, // default wood louver length in cm
  }) {
    final Map<String, double> results = {};

    for (final mat in materials) {
      double quantity = 0.0;

      switch (mat.calculationRule) {
        case 'panel_center_one_third':
          // Covers central third of the wall width
          final targetWidth = wallWidth * (1 / 3);
          // Number of panels required vertically (height) and horizontally (width)
          final panelsNeededWidth = (targetWidth / panelWidth).ceilToDouble();
          final panelsNeededHeight = (wallHeight / panelLength).ceilToDouble();
          quantity = panelsNeededWidth * panelsNeededHeight * mat.unitMultiplier;
          break;

        case 'louver_edges_two_thirds':
          // Covers remaining two thirds of the wall width (edges)
          final targetWidth = wallWidth * (2 / 3);
          final louversNeededWidth = (targetWidth / louverWidth).ceilToDouble();
          final louversNeededHeight = (wallHeight / louverLength).ceilToDouble();
          quantity = louversNeededWidth * louversNeededHeight * mat.unitMultiplier;
          break;

        case 'border_strips':
          // Stainless steel strips around the center panel (2 vertical lines)
          final linesCount = 2.0;
          quantity = (linesCount * (wallHeight / 100)) * mat.unitMultiplier; // vertical meters
          break;

        case 'fixed_count':
          // A fixed count of items (like a single center medallion)
          quantity = 1.0 * mat.unitMultiplier;
          break;

        case 'adhesive_silicone':
          // 1 silicone bottle per 3 square meters of total wall area
          final totalAreaM2 = (wallWidth / 100) * (wallHeight / 100);
          quantity = (totalAreaM2 / 3.0).ceilToDouble() * mat.unitMultiplier;
          break;

        default:
          // Fallback simple area calculation: total wall area / standard piece area
          final totalArea = wallWidth * wallHeight;
          final pieceArea = panelWidth * panelLength;
          quantity = (totalArea / pieceArea).ceilToDouble() * mat.unitMultiplier;
          break;
      }

      // Safeguard minimum quantity
      results[mat.productCategory] = max(1.0, quantity);
    }

    return results;
  }
}
