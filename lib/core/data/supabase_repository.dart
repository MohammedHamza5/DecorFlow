import 'package:supabase_flutter/supabase_flutter.dart';

/// Base repository for Supabase CRUD operations.
///
/// Provides generic methods for common database operations.
/// Each feature repository extends or uses this directly.
class SupabaseRepository {
  final SupabaseClient client;

  SupabaseRepository(this.client);

  /// Shorthand for accessing a table.
  SupabaseQueryBuilder from(String table) => client.from(table);

  /// Get the current user's ID.
  String get userId => client.auth.currentUser!.id;

  // ─── Generic CRUD ───────────────────────────────────────────

  /// Fetch all rows from a table (owner-scoped via RLS).
  Future<List<Map<String, dynamic>>> fetchAll(
    String table, {
    String orderBy = 'created_at',
    bool ascending = false,
    int? limit,
  }) async {
    var query = client.from(table).select();
    
    // Note: ordering by a column that doesn't exist will error,
    // so callers should ensure the column exists.
    final response = await query
        .order(orderBy, ascending: ascending)
        .limit(limit ?? 100);
    
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch a single row by ID.
  Future<Map<String, dynamic>?> fetchById(
    String table,
    String id,
  ) async {
    final response = await client
        .from(table)
        .select()
        .eq('id', id)
        .maybeSingle();
    return response;
  }

  /// Insert a row and return the inserted data.
  Future<Map<String, dynamic>> insert(
    String table,
    Map<String, dynamic> data, {
    bool injectOwner = true,
  }) async {
    // Auto-set owner_id if not provided
    if (injectOwner && !data.containsKey('owner_id')) {
      // Don't inject for tables known not to have owner_id
      if (table != 'product_variants' && table != 'supplier_product_pricings') {
        data['owner_id'] = userId;
      }
    }
    
    final response = await client
        .from(table)
        .insert(data)
        .select()
        .single();
    return response;
  }

  /// Update a row by ID.
  Future<Map<String, dynamic>> update(
    String table,
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await client
        .from(table)
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  /// Delete a row by ID.
  Future<void> delete(String table, String id) async {
    await client.from(table).delete().eq('id', id);
  }

  /// Upsert (insert or update) a row.
  Future<Map<String, dynamic>> upsert(
    String table,
    Map<String, dynamic> data, {
    bool injectOwner = true,
  }) async {
    if (injectOwner && !data.containsKey('owner_id')) {
      if (table != 'product_variants' && table != 'supplier_product_pricings') {
        data['owner_id'] = userId;
      }
    }
    
    final response = await client
        .from(table)
        .upsert(data)
        .select()
        .single();
    return response;
  }

  /// Search with trigram similarity (Arabic fuzzy search).
  Future<List<Map<String, dynamic>>> search(
    String table,
    String column,
    String query, {
    int limit = 20,
  }) async {
    final response = await client
        .from(table)
        .select()
        .ilike(column, '%$query%')
        .limit(limit);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Batch insert multiple rows.
  Future<List<Map<String, dynamic>>> batchInsert(
    String table,
    List<Map<String, dynamic>> rows, {
    bool injectOwner = true,
  }) async {
    for (final row in rows) {
      if (injectOwner && !row.containsKey('owner_id')) {
        if (table != 'product_variants' && table != 'supplier_product_pricings') {
          row['owner_id'] = userId;
        }
      }
    }
    
    final response = await client
        .from(table)
        .insert(rows)
        .select();
    return List<Map<String, dynamic>>.from(response);
  }
}
