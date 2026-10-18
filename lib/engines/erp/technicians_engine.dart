import 'package:stream_pay/core/database/app_database.dart';
import 'package:drift/drift.dart';

/// Handles Technician Ledger & Installation Jobs calculations.
class TechniciansEngine {
  final ErpDatabase _db;

  TechniciansEngine(this._db);

  /// Get the current balance of a technician.
  /// Positive balance means we owe them money.
  Future<double> getTechnicianBalance(int technicianId) async {
    final transactions = await (_db.select(_db.technicianLedger)
          ..where((l) => l.technicianId.equals(technicianId)))
        .get();

    double balance = 0.0;
    for (final t in transactions) {
      if (t.type == 'fee_earned') {
        balance += t.amount;
      } else if (t.type == 'payment_given') {
        balance -= t.amount;
      }
    }
    return balance;
  }

  /// Create a new Installation Job linked to a quote or invoice.
  Future<int> assignJob({
    required int technicianId,
    required String invoiceId,
    required double fee,
    DateTime? scheduledDate,
    String? address,
    String? notes,
  }) async {
    return _db.into(_db.installationJobs).insert(
      InstallationJobsCompanion.insert(
        technicianId: technicianId,
        invoiceId: Value(invoiceId),
        agreedFee: Value(fee),
        scheduledDate: Value(scheduledDate),
        address: Value(address),
        notes: Value(notes),
        status: const Value('pending'),
      ),
    );
  }

  /// Mark a job as completed and automatically credit the technician's ledger.
  Future<void> completeJob(int jobId) async {
    return _db.transaction(() async {
      final job = await (_db.select(_db.installationJobs)..where((j) => j.id.equals(jobId))).getSingle();
      
      if (job.status == 'completed') return;

      // Update job status
      await (_db.update(_db.installationJobs)..where((j) => j.id.equals(jobId))).write(
        InstallationJobsCompanion(
          status: const Value('completed'),
          updatedAt: Value(DateTime.now()),
        ),
      );

      // Credit the technician's ledger
      await _db.into(_db.technicianLedger).insert(
        TechnicianLedgerCompanion.insert(
          technicianId: job.technicianId,
          jobId: Value(jobId),
          type: 'fee_earned',
          amount: job.agreedFee,
          notes: Value('عمولة إتمام تركيب للفاتورة: ${job.invoiceId}'),
        ),
      );
    });
  }

  /// Pay the technician their balance.
  Future<void> payTechnician({
    required int technicianId,
    required double amount,
    String? notes,
  }) async {
    await _db.into(_db.technicianLedger).insert(
      TechnicianLedgerCompanion.insert(
        technicianId: technicianId,
        type: 'payment_given',
        amount: amount,
        notes: Value(notes),
      ),
    );
  }
}
