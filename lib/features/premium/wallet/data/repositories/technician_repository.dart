import 'package:stream_pay/features/premium/core/premium_dependencies.dart';
import '../../domain/models/technician.dart';
import '../../domain/models/technician_transaction.dart';

class TechnicianRepository {
  final PremiumDependencies _deps;

  TechnicianRepository(this._deps);

  /// Gets all active technicians for the current shop.
  Future<List<Technician>> getTechnicians() async {
    final shopId = _deps.currentShopId;
    if (shopId == null) return [];

    try {
      final response = await _deps.supabaseClient
          .from('premium_technicians')
          .select()
          .eq('shop_id', shopId)
          .order('name', ascending: true);

      return (response as List)
          .map((json) => Technician.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      _deps.logSystem(
        level: 'error',
        message: 'Failed to fetch technicians from Supabase',
        error: e.toString(),
        stackTrace: st.toString(),
      );
      rethrow;
    }
  }

  /// Creates a new technician.
  Future<Technician> createTechnician({
    required String name,
    required String phone,
    required String title,
    required double commissionRate,
    String? notes,
  }) async {
    final shopId = _deps.currentShopId;
    if (shopId == null) throw Exception('No active shop session');

    try {
      final data = {
        'shop_id': shopId,
        'name': name,
        'phone': phone,
        'title': title,
        'commission_rate': commissionRate,
        'notes': notes,
        'is_active': true,
      };

      final response = await _deps.supabaseClient
          .from('premium_technicians')
          .insert(data)
          .select()
          .single();

      return Technician.fromJson(response);
    } catch (e, st) {
      _deps.logSystem(
        level: 'error',
        message: 'Failed to create technician',
        error: e.toString(),
        stackTrace: st.toString(),
      );
      rethrow;
    }
  }

  /// Updates an existing technician's settings.
  Future<void> updateTechnician(Technician technician) async {
    try {
      await _deps.supabaseClient
          .from('premium_technicians')
          .update(technician.toJson())
          .eq('id', technician.id);
    } catch (e, st) {
      _deps.logSystem(
        level: 'error',
        message: 'Failed to update technician',
        error: e.toString(),
        stackTrace: st.toString(),
      );
      rethrow;
    }
  }

  /// Gets all transactions for a specific technician.
  Future<List<TechnicianTransaction>> getTransactions(String technicianId) async {
    try {
      final response = await _deps.supabaseClient
          .from('premium_technician_transactions')
          .select()
          .eq('technician_id', technicianId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => TechnicianTransaction.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      _deps.logSystem(
        level: 'error',
        message: 'Failed to fetch transactions for technician $technicianId',
        error: e.toString(),
        stackTrace: st.toString(),
      );
      rethrow;
    }
  }

  /// Records a cash withdrawal (debit transaction) for a technician.
  Future<TechnicianTransaction> createWithdrawal({
    required String technicianId,
    required double amount,
    String? notes,
  }) async {
    final shopId = _deps.currentShopId;
    if (shopId == null) throw Exception('No active shop session');

    try {
      final data = {
        'shop_id': shopId,
        'technician_id': technicianId,
        'amount': -amount, // Negative value represents debit/withdrawal
        'transaction_type': 'withdrawal',
        'status': 'completed',
        'notes': notes,
      };

      final response = await _deps.supabaseClient
          .from('premium_technician_transactions')
          .insert(data)
          .select()
          .single();

      return TechnicianTransaction.fromJson(response);
    } catch (e, st) {
      _deps.logSystem(
        level: 'error',
        message: 'Failed to record withdrawal for technician $technicianId',
        error: e.toString(),
        stackTrace: st.toString(),
      );
      rethrow;
    }
  }
}
