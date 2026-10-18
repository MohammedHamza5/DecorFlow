import 'dart:convert';
import 'dart:io';
import 'package:supabase/supabase.dart';
import 'package:path/path.dart' as p;

// Supabase Configuration
const supabaseUrl = 'https://plylvscdynposbqcshni.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBseWx2c2NkeW5wb3NicWNzaG5pIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI3MzA3NTIsImV4cCI6MjA4ODMwNjc1Mn0.FqXf-DAs-GDChXreSYpFhrZpmQ4mbYaOHxydBYFd3GE';

void main() async {
  print('🚀 بدء عملية إدخال الكتالوج (Catalog Ingestion)...');

  final client = SupabaseClient(supabaseUrl, supabaseAnonKey);
  
  // 1. Read JSON
  final jsonFile = File('catalog_data/products.json');
  if (!await jsonFile.exists()) {
    print('❌ ملف products.json غير موجود!');
    return;
  }
  
  final jsonString = await jsonFile.readAsString();
  final Map<String, dynamic> data = jsonDecode(jsonString);
  final List<dynamic> products = data['products'];
  
  print('📦 تم العثور على ${products.length} منتج في الملف.');
  
  int successCount = 0;
  
  for (int i = 0; i < products.length; i++) {
    final prod = products[i];
    final sku = prod['sku'];
    
    print('⏳ معالجة المنتج [$sku] (${i + 1}/${products.length})...');
    
    // 2. Upload Images
    String? publicImageUrl;
    final imagePagePath = prod['image_page']; // e.g., images/pages/CHI-911.jpg
    
    if (imagePagePath != null) {
      final localImageFile = File('catalog_data/$imagePagePath');
      if (await localImageFile.exists()) {
        final fileName = p.basename(imagePagePath);
        final storagePath = '$sku-$fileName'; // Ensure unique name
        
        try {
          // Upload to Supabase Storage
          await client.storage.from('catalog_images').upload(
                storagePath,
                localImageFile,
                fileOptions: const FileOptions(upsert: true),
              );
          
          publicImageUrl = client.storage.from('catalog_images').getPublicUrl(storagePath);
          print('   ✅ تم رفع الصورة: $publicImageUrl');
        } catch (e) {
          print('   ⚠️ فشل رفع الصورة لـ $sku: $e');
        }
      } else {
        print('   ⚠️ الصورة غير موجودة محلياً: ${localImageFile.path}');
      }
    }
    
    // 3. Upsert to Database
    final dbProduct = {
      'name': prod['name_ar'] ?? sku,
      'code': prod['code'] ?? sku,
      'category': prod['category_name_ar'] ?? prod['category'],
      'color': prod['color_name_ar'],
      'material': prod['material'],
      'image_url': publicImageUrl,
      'metadata': prod, // Store raw original JSON for maximum flexibility
    };
    
    try {
      // Upsert based on the 'code' column if it's unique, but since we don't know constraints for sure, we just insert.
      // Or we can check if it exists by code.
      final existing = await client.from('products').select('id').eq('code', dbProduct['code'] as String).maybeSingle();
      
      if (existing != null) {
        await client.from('products').update(dbProduct).eq('id', existing['id']);
        print('   ✅ تم التحديث في قاعدة البيانات.');
      } else {
        await client.from('products').insert(dbProduct);
        print('   ✅ تم الإدخال في قاعدة البيانات.');
      }
      successCount++;
    } catch (e) {
      print('   ❌ فشل إدخال المنتج $sku: $e');
    }
  }
  
  print('🎉 اكتملت العملية! تم إدخال/تحديث $successCount من ${products.length} منتج.');
  
  // Clean up
  client.dispose();
}
