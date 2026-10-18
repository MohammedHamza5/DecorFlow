/// All supported selling/measurement unit types used in the decor market.
///
/// These are the real-world units that products are sold by in
/// interior decoration shops.
enum UnitType {
  linearMeter('متر طولي', 'م.ط'),
  squareMeter('متر مربع', 'م²'),
  rod('عود', 'عود'),
  panel('لوح', 'لوح'),
  piece('قطعة', 'قطعة'),
  roll('رول', 'رول'),
  box('كرتونة', 'كرتونة'),
  tube('أنبوبة', 'أنبوبة'),
  container('عبوة', 'عبوة');

  final String arabicName;
  final String abbreviation;

  const UnitType(this.arabicName, this.abbreviation);
}

/// Calculation modes supported by the calculation engine.
enum CalcMode {
  rod('حاسبة الأعواد', 'أعواد'),
  panel('حاسبة الألواح', 'ألواح'),
  linearMeter('حاسبة المتر الطولي', 'متر طولي'),
  squareMeter('حاسبة المتر المربع', 'متر مربع'),
  mixed('حاسبة مختلطة', 'مختلطة'),
  rolls('حاسبة الرولات', 'رولات'),
  coverage('حاسبة التغطية', 'تغطية'),
  frames('حاسبة البراويز', 'براويز'),
  pieces('حاسبة القطع', 'قطع');

  final String arabicName;
  final String shortName;

  const CalcMode(this.arabicName, this.shortName);
}

/// Installation orientation for rod/panel products.
enum InstallationOrientation {
  vertical('رأسي'),
  horizontal('أفقي');

  final String arabicName;
  const InstallationOrientation(this.arabicName);
}

/// Moisture resistance levels for product suitability.
enum MoistureResistance {
  none('لا يتحمل'),
  low('مقاومة منخفضة'),
  medium('مقاومة متوسطة'),
  high('مقاومة عالية'),
  waterproof('مقاوم للماء');

  final String arabicName;
  const MoistureResistance(this.arabicName);
}

/// Quote statuses matching the PRD lifecycle.
enum QuoteStatus {
  draft('مسودة'),
  sent('مُرسل'),
  approved('مقبول'),
  rejected('مرفوض'),
  expired('منتهي'),
  revised('مُعدّل');

  final String arabicName;
  const QuoteStatus(this.arabicName);
}

/// Project statuses.
enum ProjectStatus {
  inquiry('استفسار'),
  measurement('معاينة'),
  quoted('تم التسعير'),
  approved('تمت الموافقة'),
  inProgress('جاري التنفيذ'),
  completed('مكتمل'),
  cancelled('ملغي');

  final String arabicName;
  const ProjectStatus(this.arabicName);
}

/// User roles for permission management.
enum UserRole {
  owner('صاحب المحل'),
  seller('بائع'),
  technician('فني');

  final String arabicName;
  const UserRole(this.arabicName);
}

/// Opening types in walls for measurement.
enum OpeningType {
  door('باب'),
  window('شباك'),
  column('عمود'),
  recess('تجويف');

  final String arabicName;
  const OpeningType(this.arabicName);
}

/// Discount types.
enum DiscountType {
  percentage('نسبة مئوية'),
  fixed('مبلغ ثابت');

  final String arabicName;
  const DiscountType(this.arabicName);
}

/// Quantity rule types for product assemblies (accessories).
enum QuantityRuleType {
  perUnit('لكل وحدة'),
  perMeter('لكل متر'),
  perSquareMeter('لكل متر مربع'),
  perWall('لكل حائط'),
  perCorner('لكل زاوية'),
  fixed('كمية ثابتة');

  final String arabicName;
  const QuantityRuleType(this.arabicName);
}
