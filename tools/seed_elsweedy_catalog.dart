import 'dart:convert';
import 'dart:io';
import 'package:supabase/supabase.dart';

// Supabase Configuration
const supabaseUrl = 'https://plylvscdynposbqcshni.supabase.co';
const supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBseWx2c2NkeW5wb3NicWNzaG5pIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI3MzA3NTIsImV4cCI6MjA4ODMwNjc1Mn0.FqXf-DAs-GDChXreSYpFhrZpmQ4mbYaOHxydBYFd3GE';

// Image mapping dictionary from product code to available high-res image files
final Map<String, String> imageMapping = {
  'P010': 'COR-P010.jpg',
  'M-010/1': 'COR-P010.jpg',
  'P240': 'COR-P240.jpg',
  '-30/1': 'COR-P240.jpg',
  'CPR101': 'COR-010_CPR101.jpg',
  '030': 'COR-030.jpg',
  '0220': 'COR-0220.jpg',
  '0260': 'COR-0260.jpg',
  'R1': 'COR-R1___R2___R3___R4.jpg',
  'R2': 'COR-R1___R2___R3___R4.jpg',
  'R3': 'COR-R1___R2___R3___R4.jpg',
  'R4': 'COR-R1___R2___R3___R4.jpg',
  'R5': 'COR-R5___R6___R7___R8.jpg',
  'R6': 'COR-R5___R6___R7___R8.jpg',
  'R7': 'COR-R5___R6___R7___R8.jpg',
  'R8': 'COR-R5___R6___R7___R8.jpg',
  '011': 'COR-011.jpg',
  '014': 'COR-014.jpg',
  '015': 'COR-015.jpg',
  '016': 'COR-016.jpg',
  '018': 'COR-018.jpg',
  '019': 'COR-019.jpg',
  '020': 'COR-020.jpg',
  '021': 'COR-021.jpg',
  '022': 'COR-022.jpg',
  '051': 'COR-051.jpg',
  '035': 'COR-035.jpg',
  '057': 'COR-057.jpg',
  'L002': 'COR-L002.jpg',
  'L001': 'COR-L001.jpg',
  'L003': 'COR-L003.jpg',
  'L004': 'COR-L004.jpg',
  'L005': 'COR-L005.jpg',
  'SK.L2': 'COR-SK.L2.jpg',
  'ML-24015': 'COR-ML-24015.jpg',
  'SM-WHITE-JC10': 'COR-SM_WHITE_JC_10_CM.jpg',
  'PS10-STD': 'COR-ps_10_cm.jpg',
  'WR1': 'COR-wR1.jpg',
  'WR1-LED': 'COR-wR1.jpg',
  'WR2': 'COR-wR1.jpg',
  'WR2-LED': 'COR-wR1.jpg',
  'WR3': 'COR-wR1.jpg',
  'WR3-LED': 'COR-wR1.jpg',
  'WR4': 'COR-wR1.jpg',
  'WR4-LED': 'COR-wR1.jpg',
  'M033': 'COR-M033.jpg',
  'M034': 'COR-M033.jpg',
  'M035': 'COR-M033.jpg',
  'M036': 'COR-M033.jpg',
  'M037': 'COR-M033.jpg',
  'M017': 'COR-M033.jpg',
  'MOD3': 'COR-MOD3.jpg',
  'MOD4': 'COR-MOD3.jpg',
  'MOD7': 'COR-MOD3.jpg',
  'MOD11': 'COR-MOD3.jpg',
  'MOD5': 'COR-MOD3.jpg',
  'MOD9': 'COR-MOD3.jpg',
  'M025': 'COR-M025.jpg',
  'M022': 'COR-M025.jpg',
  'M030': 'COR-M025.jpg',
  'M031': 'COR-M025.jpg',
  'M045': 'COR-M025.jpg',
  'M008': 'COR-M025.jpg',
  'M015': 'COR-M015.jpg',
  'M013': 'COR-M015.jpg',
  'M006': 'COR-M015.jpg',
  'M016': 'COR-M015.jpg',
  'M014': 'COR-M015.jpg',
  'M002': 'COR-M015.jpg',
  'M024': 'COR-M024___M069___M064___M001___M070___M065.jpg',
  'M069': 'COR-M024___M069___M064___M001___M070___M065.jpg',
  'M064': 'COR-M024___M069___M064___M001___M070___M065.jpg',
  'M001': 'COR-M024___M069___M064___M001___M070___M065.jpg',
  'M070': 'COR-M024___M069___M064___M001___M070___M065.jpg',
  'M065': 'COR-M024___M069___M064___M001___M070___M065.jpg',
  'M027': 'COR-M027___M028___M029___M019___M067___M060.jpg',
  'M028': 'COR-M027___M028___M029___M019___M067___M060.jpg',
  'M029': 'COR-M027___M028___M029___M019___M067___M060.jpg',
  'M019': 'COR-M027___M028___M029___M019___M067___M060.jpg',
  'M067': 'COR-M027___M028___M029___M019___M067___M060.jpg',
  'M060': 'COR-M027___M028___M029___M019___M067___M060.jpg',
  'M018': 'COR-M018.jpg',
  'M010': 'COR-M018.jpg',
  'M012': 'COR-M018.jpg',
  'M063': 'COR-M018.jpg',
  'M061': 'COR-M018.jpg',
  'M062': 'COR-M018.jpg',
  'M020': 'COR-M020__M131__M021__M023__M066__M026.jpg',
  'M131': 'COR-M020__M131__M021__M023__M066__M026.jpg',
  'M021': 'COR-M020__M131__M021__M023__M066__M026.jpg',
  'M023': 'COR-M020__M131__M021__M023__M066__M026.jpg',
  'M066': 'COR-M020__M131__M021__M023__M066__M026.jpg',
  'M026': 'COR-M020__M131__M021__M023__M066__M026.jpg',
  'RO01': 'COR-R001___R002___R003___R004___R005___R006___R007.jpg',
  'RO02': 'COR-R001___R002___R003___R004___R005___R006___R007.jpg',
  'RO03': 'COR-R001___R002___R003___R004___R005___R006___R007.jpg',
  'RO04': 'COR-R001___R002___R003___R004___R005___R006___R007.jpg',
  'RO05': 'COR-R001___R002___R003___R004___R005___R006___R007.jpg',
  'RO06': 'COR-R001___R002___R003___R004___R005___R006___R007.jpg',
  'RO07': 'COR-R001___R002___R003___R004___R005___R006___R007.jpg',
  'E030': 'COR-E030___E040___E050___E060___W070___W080.jpg',
  'E040': 'COR-E030___E040___E050___E060___W070___W080.jpg',
  'E050': 'COR-E030___E040___E050___E060___W070___W080.jpg',
  'E060': 'COR-E030___E040___E050___E060___W070___W080.jpg',
  'W070': 'COR-E030___E040___E050___E060___W070___W080.jpg',
  'W080': 'COR-E030___E040___E050___E060___W070___W080.jpg',
  'D011': 'COR-D011.jpg',
  'D012': 'COR-D011.jpg',
  'D001': 'COR-D001.jpg',
  'D002': 'COR-D001.jpg',
  'D003': 'COR-D003___D004.jpg',
  'D004': 'COR-D003___D004.jpg',
  'D005': 'COR-D005___D006.jpg',
  'D006': 'COR-D005___D006.jpg',
  'D007': 'COR-D007___D008.jpg',
  'D008': 'COR-D007___D008.jpg',
  'D009': 'COR-D009___D010.jpg',
  'D010': 'COR-D009___D010.jpg',
  'D017': 'COR-D017___D018.jpg',
  'D018': 'COR-D017___D018.jpg',
  'D013': 'COR-D013__D014.jpg',
  'D014': 'COR-D013__D014.jpg',
  'D015': 'COR-D015.jpg',
  'D016': 'COR-D015.jpg',
  'D019': 'COR-D019.jpg',
  'D020': 'COR-D019.jpg',
  'D021': 'COR-D019.jpg',
};

void main() async {
  print('🚀 بدء عملية الرفع الذكي لكتالوج السويدي (52 صفحة) بجودة عالية...');

  final client = SupabaseClient(supabaseUrl, supabaseAnonKey);

  // 1. Read JSON
  final jsonFile = File('catalog_data/elsweedy_full_catalog.json');
  if (!await jsonFile.exists()) {
    print('❌ ملف elsweedy_full_catalog.json غير موجود!');
    return;
  }

  final jsonString = await jsonFile.readAsString();
  final Map<String, dynamic> data = jsonDecode(jsonString);
  final List<dynamic> products = data['products'];

  print('📦 تم تحميل ${products.length} منتج بدقة عالية.');

  // Cache uploaded images to avoid re-uploading the same file multiple times
  final Map<String, String> uploadedUrls = {};

  int successCount = 0;

  for (int i = 0; i < products.length; i++) {
    final prod = products[i];
    final code = prod['code'];
    final name = prod['name'];
    final category = prod['category'];
    final brand = prod['brand'];
    final unitType = prod['unit_type'];

    print('⏳ معالجة [$code - $name] (${i + 1}/${products.length})...');

    String? publicImageUrl;
    final imgFileName = imageMapping[code];

    if (imgFileName != null) {
      if (uploadedUrls.containsKey(imgFileName)) {
        publicImageUrl = uploadedUrls[imgFileName];
      } else {
        final localFile = File('catalog_data/images/pages/$imgFileName');
        if (await localFile.exists()) {
          final storagePath = 'elsweedy_$imgFileName';
          try {
            await client.storage
                .from('catalog_images')
                .upload(
                  storagePath,
                  localFile,
                  fileOptions: const FileOptions(upsert: true),
                );
            publicImageUrl = client.storage
                .from('catalog_images')
                .getPublicUrl(storagePath);
            uploadedUrls[imgFileName] = publicImageUrl;
            print('   🖼️ تم رفع الصورة بجودة فائقة: $imgFileName');
          } catch (e) {
            print('   ⚠️ خطأ أثناء رفع الصورة: $e');
            // Try fallback url
            publicImageUrl = client.storage
                .from('catalog_images')
                .getPublicUrl(storagePath);
            uploadedUrls[imgFileName] = publicImageUrl;
          }
        }
      }
    }

    // 2. Prepare DB record
    final dbProduct = {
      'name': name,
      'code': code,
      'category': category,
      'brand': brand,
      'unit_type': unitType,
      'image_url': publicImageUrl,
      'is_active': true,
      'material': 'بولي يوريثان / فيوتك عالي الكثافة',
      'moisture_resistance': 'high',
      'installation_method': 'معجون فيوتك / سيليكون عظم',
    };

    try {
      final existing = await client
          .from('products')
          .select('id')
          .eq('code', code)
          .maybeSingle();
      if (existing != null) {
        await client
            .from('products')
            .update(dbProduct)
            .eq('id', existing['id']);
        print('   ✅ تم تحديث المنتج في قاعدة البيانات.');
      } else {
        await client.from('products').insert(dbProduct);
        print('   ✅ تم إدخال المنتج في قاعدة البيانات.');
      }
      successCount++;
    } catch (e) {
      print('   ❌ تعذر إدخال $code: $e');
    }
  }

  print(
    '\n🎉 مبروك! تم إدخال وتحديث $successCount من إجمالي ${products.length} منتج بجودة عالية وربط الصور بنجاح.',
  );
  client.dispose();
}
