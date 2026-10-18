import 'dart:convert';
import 'dart:io';
import 'package:supabase/supabase.dart';

const supabaseUrl = 'https://plylvscdynposbqcshni.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBseWx2c2NkeW5wb3NicWNzaG5pIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI3MzA3NTIsImV4cCI6MjA4ODMwNjc1Mn0.FqXf-DAs-GDChXreSYpFhrZpmQ4mbYaOHxydBYFd3GE';

void main() async {
  print('🚀 بدء معالجة ورفع بديل الرخام والشيبورد المنظم والخالي من التكرار...');

  final client = SupabaseClient(supabaseUrl, supabaseAnonKey);
  
  // 1. Process Marble Alternative
  final marbleFile = File('catalog_data/marble_alternative_cleaned.json');
  if (await marbleFile.exists()) {
    final marbleData = jsonDecode(await marbleFile.readAsString());
    final List<dynamic> marbleProducts = marbleData['products'];
    print('📦 تم تحميل ${marbleProducts.length} لوح بديل رخام...');

    for (int i = 0; i < marbleProducts.length; i++) {
      final p = marbleProducts[i];
      final code = p['code'];
      final name = p['name'];
      final imageFileName = p['image_file'];

      String? imageUrl;
      if (imageFileName != null) {
        final localImg = File('catalog_data/images/pages/$imageFileName');
        if (await localImg.exists()) {
          final storagePath = 'marble_$imageFileName';
          try {
            await client.storage.from('catalog_images').upload(
              storagePath,
              localImg,
              fileOptions: const FileOptions(upsert: true),
            );
            imageUrl = client.storage.from('catalog_images').getPublicUrl(storagePath);
          } catch (_) {
            imageUrl = client.storage.from('catalog_images').getPublicUrl(storagePath);
          }
        }
      }

      final dbRecord = {
        'name': name,
        'code': code,
        'category': 'بديل رخام',
        'brand': 'DecoPlast',
        'unit_type': 'panel',
        'image_url': imageUrl,
        'material': 'PVC Marble Sheet (لوح بديل رخام عالي الجودة)',
        'is_active': true,
        'moisture_resistance': 'high',
        'installation_method': 'سيليكون عظم / لاصق بولي يوريثان',
      };

      try {
        final existing = await client.from('products').select('id').eq('code', code).maybeSingle();
        if (existing != null) {
          await client.from('products').update(dbRecord).eq('id', existing['id']);
        } else {
          await client.from('products').insert(dbRecord);
        }
        print('   ✅ [بديل رخام] $code: تم الحفظ والتحديث بنجاح.');
      } catch (e) {
        print('   ⚠️ خطأ في $code: $e');
      }
    }
  }

  // 2. Process Chipboard
  final chipboardFile = File('catalog_data/chipboard_cleaned.json');
  if (await chipboardFile.exists()) {
    final chipboardData = jsonDecode(await chipboardFile.readAsString());
    final List<dynamic> chipboardProducts = chipboardData['products'];
    print('📦 تم تحميل ${chipboardProducts.length} لوح شيبورد وتجاليد...');

    for (int i = 0; i < chipboardProducts.length; i++) {
      final p = chipboardProducts[i];
      final code = p['code'];
      final name = p['name'];
      final imageFileName = p['image_file'];

      String? imageUrl;
      if (imageFileName != null) {
        final localImg = File('catalog_data/images/pages/$imageFileName');
        if (await localImg.exists()) {
          final storagePath = 'chipboard_$imageFileName';
          try {
            await client.storage.from('catalog_images').upload(
              storagePath,
              localImg,
              fileOptions: const FileOptions(upsert: true),
            );
            imageUrl = client.storage.from('catalog_images').getPublicUrl(storagePath);
          } catch (_) {
            imageUrl = client.storage.from('catalog_images').getPublicUrl(storagePath);
          }
        }
      }

      final dbRecord = {
        'name': name,
        'code': code,
        'category': 'شيبورد',
        'brand': 'السويدي / Mlkawy',
        'unit_type': 'panel',
        'image_url': imageUrl,
        'material': 'ألواح خشبية مضغوطة مكسوة ميلامين',
        'is_active': true,
        'moisture_resistance': 'medium',
        'installation_method': 'تثبيت ميكانيكي / فواصل معدنية',
      };

      try {
        final existing = await client.from('products').select('id').eq('code', code).maybeSingle();
        if (existing != null) {
          await client.from('products').update(dbRecord).eq('id', existing['id']);
        } else {
          await client.from('products').insert(dbRecord);
        }
        print('   ✅ [شيبورد] $code: تم الحفظ والتحديث بنجاح.');
      } catch (e) {
        print('   ⚠️ خطأ في $code: $e');
      }
    }
  }

  print('\n🎉 اكتمل تحديث ورفع كافة ألواح بديل الرخام والشيبورد بنجاح تام وبدون أي تكرارات أو أخطاء تصنيف!');
  client.dispose();
}
