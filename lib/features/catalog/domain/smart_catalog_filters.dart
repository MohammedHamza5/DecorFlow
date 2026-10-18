import 'package:flutter/material.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/features/catalog/data/catalog_hub_state.dart';

/// Top-level showroom category
class SmartCategory {
  final String id;
  final String label;
  final IconData icon;
  final Color color;

  const SmartCategory(this.id, this.label, this.icon, [this.color = AppColors.primary]);
}

/// Standard showroom top categories
const kDefaultSmartCategories = [
  SmartCategory('all', 'الكل', Icons.grid_view_rounded, AppColors.primary),
  SmartCategory('cladding', 'بدائل التشطيبات', Icons.dashboard_outlined, Color(0xFF059669)),
  SmartCategory(
    'ceilings_walls',
    'ديكورات الأسقف والحوائط',
    Icons.home_outlined,
    Color(0xFF6366F1),
  ),
  SmartCategory(
    'skirting_accessories',
    'وزرات وإكسسوارات',
    Icons.extension_outlined,
    Color(0xFFD97706),
  ),
  SmartCategory('materials', 'خامات مساعدة', Icons.build_outlined, Color(0xFFDC2626)),
];

/// Smart Sub-Category for fine-grained 2-tier filtering (Wood, Marble, Chipboard, Mouldings...)
class SmartSubCategory {
  final String id;
  final String label;
  final String emoji;
  final String parentGroupId;
  final List<String> patterns;
  final List<String> negativePatterns;

  const SmartSubCategory({
    required this.id,
    required this.label,
    required this.emoji,
    required this.parentGroupId,
    required this.patterns,
    this.negativePatterns = const [],
  });

  bool matches(EnrichedProduct p) {
    final cat = p.category.toLowerCase();
    final sub = (p.subcategory ?? '').toLowerCase();
    final name = p.name.toLowerCase();
    final mat = (p.material ?? '').toLowerCase();
    final code = p.code.toLowerCase();
    final notes = (p.notes ?? '').toLowerCase();

    // Check negative patterns first
    for (final neg in negativePatterns) {
      final n = neg.toLowerCase();
      if (cat.contains(n) || name.contains(n) || sub.contains(n)) {
        return false;
      }
    }

    // Check positive patterns
    for (final pat in patterns) {
      final patL = pat.toLowerCase();
      if (cat.contains(patL) ||
          sub.contains(patL) ||
          name.contains(patL) ||
          mat.contains(patL) ||
          code.contains(patL) ||
          notes.contains(patL)) {
        return true;
      }
      if (p.variants.any((v) =>
          v.variantName.toLowerCase().contains(patL) ||
          (v.color?.toLowerCase().contains(patL) ?? false))) {
        return true;
      }
    }

    return false;
  }
}

const kDefaultSmartSubCategories = [
  // ─── بدائل التشطيبات (cladding) ─────────────────────────
  SmartSubCategory(
    id: 'wood',
    label: 'بديل خشب',
    emoji: '🪵',
    parentGroupId: 'cladding',
    patterns: [
      'بديل خشب',
      'بديل الخشب',
      'تجليد خشب',
      'خشب كوري',
      'خشب تركي',
      'سداسي خشب',
      'لوفر خشب',
      'شرايح خشب',
      'ألواح خشب',
      'wpc',
      'خشب',
    ],
    negativePatterns: ['شيبورد', 'chipboard'],
  ),
  SmartSubCategory(
    id: 'marble',
    label: 'بديل رخام',
    emoji: '🏛️',
    parentGroupId: 'cladding',
    patterns: [
      'بديل رخام',
      'بديل الرخام',
      'رخام uv',
      'رخام ريزن',
      'رخام pvc',
      'ماربل',
      'marble',
      'رخام',
    ],
  ),
  SmartSubCategory(
    id: 'chipboard',
    label: 'شيبورد',
    emoji: '🟫',
    parentGroupId: 'cladding',
    patterns: [
      'شيبورد',
      'chipboard',
      'chi-',
    ],
  ),
  SmartSubCategory(
    id: 'stone',
    label: 'بديل حجر',
    emoji: '🪨',
    parentGroupId: 'cladding',
    patterns: [
      'بديل حجر',
      'بديل الحجر',
      'حجر فيوتك',
      'pu stone',
      'حجر صخري',
      'حجر صناعي',
      'حجر',
    ],
  ),

  // ─── ديكورات الأسقف والحوائط (ceilings_walls) ─────────────
  SmartSubCategory(
    id: 'mouldings',
    label: 'بانوهات',
    emoji: '🖼️',
    parentGroupId: 'ceilings_walls',
    patterns: [
      'بانوه',
      'بانوهات',
      'برواز',
      'براويز',
      'زوايا بانوه',
      'ركن بانوه',
    ],
  ),
  SmartSubCategory(
    id: 'cornices',
    label: 'كرانيش وبيت نور',
    emoji: '🏛️',
    parentGroupId: 'ceilings_walls',
    patterns: [
      'كرانيش',
      'كورنيش',
      'بيت نور',
      'شادو',
      'كوف',
      'مجرى إضاءة',
      'كرنيشة',
    ],
  ),
  SmartSubCategory(
    id: 'wall_3d',
    label: 'ألواح 3D',
    emoji: '🧱',
    parentGroupId: 'ceilings_walls',
    patterns: [
      '3d',
      'ثلاثية الأبعاد',
      'بلاطات 3d',
      'ألواح 3d',
      'ألواح جدارية',
    ],
  ),
  SmartSubCategory(
    id: 'medallions',
    label: 'صرر وإطارات',
    emoji: '⭕',
    parentGroupId: 'ceilings_walls',
    patterns: [
      'صرة',
      'صرر',
      'روزيت',
      'حلقة',
      'إطار دائم',
      'زخارف',
      'دائرية زخرفية',
    ],
  ),

  // ─── الوزرات والإكسسوارات (skirting_accessories) ─────────
  SmartSubCategory(
    id: 'skirting',
    label: 'وزرات',
    emoji: '📏',
    parentGroupId: 'skirting_accessories',
    patterns: [
      'وزر',
      'وزرات',
      'وزرة',
      'بالتو',
    ],
  ),
  SmartSubCategory(
    id: 'stainless',
    label: 'زوايا استانلس',
    emoji: '✨',
    parentGroupId: 'skirting_accessories',
    patterns: [
      'استانلس',
      'ستانلس',
      'زاوية استانلس',
      'زوايا استانلس',
      'stainless',
      'زاوية pvc',
    ],
  ),
  SmartSubCategory(
    id: 'profiles',
    label: 'بروفايلات وفواصل',
    emoji: '📐',
    parentGroupId: 'skirting_accessories',
    patterns: [
      'بروفايل',
      'بروفايلات',
      'فاصل',
      'فواصل',
      'نهاية',
      'نهايات',
      'تي بار',
      't-bar',
    ],
  ),

  // ─── الخامات المساعدة (materials) ───────────────────────
  SmartSubCategory(
    id: 'silicone',
    label: 'سيليكون وعظم',
    emoji: '🧴',
    parentGroupId: 'materials',
    patterns: [
      'سيليكون',
      'سليكون',
      'عظم',
      'لاصق عظم',
      'silicone',
      'مسدس',
    ],
  ),
  SmartSubCategory(
    id: 'adhesives',
    label: 'معجون ولواصق',
    emoji: '🧪',
    parentGroupId: 'materials',
    patterns: [
      'معجون',
      'غراء',
      'لاصق فيوتك',
      'paste',
      'مادة لاصقة',
    ],
  ),
  SmartSubCategory(
    id: 'fasteners',
    label: 'مسامير وتثبيت',
    emoji: '🔩',
    parentGroupId: 'materials',
    patterns: [
      'مسمار',
      'مسامير',
      'فيشر',
      'تثبيت',
      'كلبسات',
      'سوستة',
    ],
  ),
];
