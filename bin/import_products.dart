import 'dart:io';
import 'package:supabase/supabase.dart';

// Copy these from lib/core/constants/app_constants.dart
const String supabaseUrl = 'https://plylvscdynposbqcshni.supabase.co';
const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBseWx2c2NkeW5wb3NicWNzaG5pIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI3MzA3NTIsImV4cCI6MjA4ODMwNjc1Mn0.FqXf-DAs-GDChXreSYpFhrZpmQ4mbYaOHxydBYFd3GE';

void main() async {
  final supabase = SupabaseClient(supabaseUrl, supabaseAnonKey);

  print('=== تنظيف وإعادة ضبط كتالوج المنتجات ===');
  stdout.write('البريد الإلكتروني: ');
  final email = stdin.readLineSync()?.trim();
  stdout.write('كلمة المرور: ');
  final password = stdin.readLineSync()?.trim();

  if (email == null || email.isEmpty || password == null || password.isEmpty) {
    print('يجب إدخال البريد وكلمة المرور!');
    return;
  }

  print('\nجاري تسجيل الدخول...');
  try {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    print('تم تسجيل الدخول بنجاح! المستخدم: \${response.user?.id}');
  } catch (e) {
    print('فشل تسجيل الدخول: \$e');
    return;
  }

  print('\n[1/3] جاري مسح المنتجات القديمة من السيرفر...');
  try {
    // Delete all products (assuming cascading deletes variants)
    final res = await supabase.from('products').delete().neq('id', '00000000-0000-0000-0000-000000000000');
    print('تم مسح المنتجات بنجاح.');
  } catch (e) {
    print('حدث خطأ أثناء مسح المنتجات: \$e');
  }

  print('\n[2/3] جاري قراءة الأكواد من الملفات...');
  // Read marble replacement
  final marbleFile = File(r'C:\Users\KimoStore\Downloads\المنتجات النهائية\بديل_الرخام.md');
  final chipboardFile = File(r'C:\Users\KimoStore\Downloads\المنتجات النهائية\شيبورد.md');

  List<String> marbleCodes = [];
  List<String> chipboardCodes = [];

  if (marbleFile.existsSync()) {
    final lines = marbleFile.readAsLinesSync();
    marbleCodes = lines.where((l) => l.startsWith('- DP-') || l.startsWith('- DP')).map((l) => l.replaceAll('- ', '').trim()).toList();
  }

  if (chipboardFile.existsSync()) {
    final lines = chipboardFile.readAsLinesSync();
    chipboardCodes = lines.where((l) => l.startsWith('- ') && !l.contains('المقاس') && !l.contains('الوحدة') && !l.contains('الخامة')).map((l) => l.replaceAll('- ', '').trim()).toList();
    // Filter strictly the codes
    chipboardCodes = chipboardCodes.where((c) => RegExp(r'^[0-9A-Z]+$').hasMatch(c)).toList();
  }

  print('تم العثور على \${marbleCodes.length} كود لبديل الرخام.');
  print('تم العثور على \${chipboardCodes.length} كود للشيبورد.');

  print('\n[3/3] جاري رفع المنتجات الجديدة...');
  
  // Insert Marble Family
  try {
    final marbleProduct = await supabase.from('products').insert({
      'name': 'بديل الرخام',
      'code': 'MARBLE-PVC',
      'category': 'بديل الرخام',
      'subcategory': 'PVC marble wall panel',
      'unit_type': 'لوح',
      'material': 'PVC',
      'is_active': true,
    }).select().single();
    
    final marbleId = marbleProduct['id'];

    // Insert variants
    for (var code in marbleCodes) {
      await supabase.from('product_variants').insert({
        'product_id': marbleId,
        'variant_name': code,
        'piece_length': 280.0,
        'piece_width': 122.0,
        'min_selling_price': 0.0,
      });
      print('تم رفع الصنف \$code (بديل رخام)');
    }
  } catch (e) {
    print('خطأ في إدراج بديل الرخام: \$e');
  }

  // Insert Chipboard Family
  try {
    final chipboardProduct = await supabase.from('products').insert({
      'name': 'شيبورد',
      'code': 'CHIPBOARD',
      'category': 'شيبورد',
      'subcategory': 'Decorative board / wood texture panel',
      'unit_type': 'لوح',
      'material': 'Decorative board',
      'is_active': true,
    }).select().single();
    
    final chipboardId = chipboardProduct['id'];

    // Insert variants
    for (var code in chipboardCodes) {
      await supabase.from('product_variants').insert({
        'product_id': chipboardId,
        'variant_name': code,
        'piece_length': 280.0,
        'piece_width': 122.0,
        'min_selling_price': 0.0,
      });
      print('تم رفع الصنف \$code (شيبورد)');
    }
  } catch (e) {
    print('خطأ في إدراج الشيبورد: \$e');
  }

  print('\n=== اكتملت العملية بنجاح! ===');
  print('يرجى إعادة تشغيل التطبيق (أو حذفه وتثبيته من جديد) لسحب البيانات النظيفة.');
}
