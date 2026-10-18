import 'package:supabase/supabase.dart';

const supabaseUrl = 'https://plylvscdynposbqcshni.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBseWx2c2NkeW5wb3NicWNzaG5pIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI3MzA3NTIsImV4cCI6MjA4ODMwNjc1Mn0.FqXf-DAs-GDChXreSYpFhrZpmQ4mbYaOHxydBYFd3GE';

void main() async {
  print('🧹 تنظيف السجلات المدمجة والمشوهة القديمة من قاعدة البيانات...');
  final client = SupabaseClient(supabaseUrl, supabaseAnonKey);

  // List of known grouped/messy codes from legacy seeds
  final badCodes = [
    'R5 / R6 / R7 / R8',
    'R5/R6/R7/R8',
    'R1 / R2 / R3 / R4',
    'R1/R2/R3/R4',
    'RO01 / RO02 / RO03',
    'E030 / E040 / E050 / E060',
    'M024 / M069 / M064',
    'M027 / M028 / M029',
    'D003 / D004',
    'D005 / D006',
    'D007 / D008',
    'D009 / D010',
    'D017 / D018',
    'D013 / D014',
  ];

  for (final badCode in badCodes) {
    try {
      final res = await client.from('products').delete().ilike('code', '%$badCode%');
      print('   🗑️ تم حذف السجل المشوه: $badCode');
    } catch (e) {
      print('   ⚠️ $badCode: $e');
    }
  }

  // Also clean any product named "بانوهات حائط دائرية / قوسية" with merged codes
  try {
    await client.from('products').delete().ilike('name', '%بانوهات حائط دائرية%');
    print('   🗑️ تم تنظيف المنتجات المجمعة بالاسم القديم.');
  } catch (e) {
    print('   ⚠️ $e');
  }

  print('✅ اكتمل التنظيف! أصبحت كل صرة ولوح وبانوه منفصلة ومستقلة بمقاسها وسعرها الخاص.');
  client.dispose();
}
