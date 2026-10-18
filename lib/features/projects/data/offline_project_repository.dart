import 'package:stream_pay/core/local_db/app_database.dart';
import 'package:stream_pay/core/sync/sync_engine.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';

/// Offline-first repository for Projects and Measurements.
/// All writes go to the local SQLite database and are synced via SyncEngine.
class OfflineProjectRepository {
  final AppDatabase _db;
  final SyncEngine _syncEngine;

  OfflineProjectRepository(this._db, this._syncEngine);

  // ─── Projects ─────────────────────────────────────────────

  Future<Map<String, dynamic>> createProject(
    Map<String, dynamic> project,
  ) async {
    final id = const Uuid().v4();
    final title = project['name'] ?? project['title'] ?? 'مشروع جديد';
    await _db
        .into(_db.localProjects)
        .insert(
          LocalProjectsCompanion.insert(
            id: Value(id),
            title: title,
            description: Value(
              project['description'] ?? project['project_type'],
            ),
            customerId: Value(project['customer_id']),
            status: Value(project['status'] ?? 'draft'),
            notes: Value(project['notes']),
            address: Value(project['address']),
          ),
        );
    _triggerSync();
    return {
      'id': id,
      'title': title,
      'name': title,
      'description': project['description'] ?? project['project_type'],
      'customer_id': project['customer_id'],
      'status': project['status'] ?? 'draft',
      'notes': project['notes'],
      'address': project['address'],
    };
  }

  Future<List<Map<String, dynamic>>> getProjects({
    String? status,
    int limit = 50,
  }) async {
    final query =
        _db.select(_db.localProjects).join([
          leftOuterJoin(
            _db.localCustomers,
            _db.localCustomers.id.equalsExp(_db.localProjects.customerId),
          ),
        ])..where(
          _db.localProjects.isDeleted.equals(false) &
              _db.localProjects.syncStatus.isNotValue('pending_delete'),
        );

    if (status != null) {
      query.where(_db.localProjects.status.equals(status));
    }

    query.orderBy([OrderingTerm.desc(_db.localProjects.createdAt)]);
    query.limit(limit);

    final rows = await query.get();
    return rows.map((row) {
      final project = row.readTable(_db.localProjects);
      final customer = row.readTableOrNull(_db.localCustomers);

      return {
        'id': project.id,
        'title': project.title,
        'name': project.title, // Map to name for UI compatibility
        'description': project.description,
        'customer_id': project.customerId,
        'status': project.status,
        'net_value': project.netValue,
        'tax_percent': project.taxPercent,
        'total_value': project.totalValue,
        'notes': project.notes,
        'address': project.address,
        'created_at': project.createdAt.toIso8601String(),
        'updated_at': project.updatedAt.toIso8601String(),
        'customer': customer == null
            ? null
            : {
                'id': customer.id,
                'name': customer.name,
                'phone': customer.phone,
                'address': customer.address,
                'location': customer.address,
              },
      };
    }).toList();
  }

  Future<Map<String, dynamic>?> getProjectWithMeasurements(
    String projectId,
  ) async {
    final projectQuery = _db.select(_db.localProjects).join([
      leftOuterJoin(
        _db.localCustomers,
        _db.localCustomers.id.equalsExp(_db.localProjects.customerId),
      ),
    ])..where(_db.localProjects.id.equals(projectId));

    final projectRow = await projectQuery.getSingleOrNull();
    if (projectRow == null) return null;

    final project = projectRow.readTable(_db.localProjects);
    final customer = projectRow.readTableOrNull(_db.localCustomers);

    // Fetch sessions
    final sessionsQuery = _db.select(_db.localMeasurementSessions)
      ..where((t) => t.projectId.equals(projectId) & t.isDeleted.equals(false));
    final sessions = await sessionsQuery.get();

    final List<Map<String, dynamic>> sessionsData = [];

    for (final session in sessions) {
      final technicianProfile =
          await (_db.select(_db.localProfiles)
                ..where((t) => t.id.equals(session.technicianId ?? '')))
              .getSingleOrNull();

      // Fetch rooms
      final roomsQuery = _db.select(_db.localRooms)
        ..where(
          (t) => t.sessionId.equals(session.id) & t.isDeleted.equals(false),
        );
      final rooms = await roomsQuery.get();

      final List<Map<String, dynamic>> roomsData = [];

      for (final room in rooms) {
        final wallsQuery = _db.select(_db.localWalls)
          ..where((t) => t.roomId.equals(room.id) & t.isDeleted.equals(false));
        final walls = await wallsQuery.get();

        final List<Map<String, dynamic>> wallsData = [];

        for (final wall in walls) {
          final openingsQuery = _db.select(
            _db.localWallOpenings,
          )..where((t) => t.wallId.equals(wall.id) & t.isDeleted.equals(false));
          final openings = await openingsQuery.get();

          wallsData.add({
            'id': wall.id,
            'room_id': wall.roomId,
            'name': wall.name,
            'label': wall.name,
            'length': wall.length,
            'height': wall.height,
            'gross_area': wall.grossArea,
            'net_area': wall.netArea,
            'material_type': wall.materialType,
            'wall_openings': openings
                .map(
                  (o) => {
                    'id': o.id,
                    'wall_id': o.wallId,
                    'type': o.type,
                    'width': o.width,
                    'height': o.height,
                    'area': o.area,
                    'deduct': o.deductFromWall,
                    'deduct_from_wall': o.deductFromWall,
                  },
                )
                .toList(),
          });
        }

        roomsData.add({
          'id': room.id,
          'session_id': room.sessionId,
          'name': room.name,
          'shape_type': room.type,
          'type': room.type,
          'length': room.length,
          'width': room.width,
          'height': room.height,
          'ceiling_height': room.height,
          'floor_area': room.floorArea,
          'perimeter': room.perimeter,
          'walls': wallsData,
        });
      }

      sessionsData.add({
        'id': session.id,
        'project_id': session.projectId,
        'status': session.status,
        'notes': session.notes,
        'created_at': session.createdAt.toIso8601String(),
        'technician': technicianProfile == null
            ? null
            : {'full_name': technicianProfile.fullName},
        'rooms': roomsData,
      });
    }

    // Fetch quotes

    return {
      'id': project.id,
      'title': project.title,
      'name': project.title, // Map to name for UI
      'description': project.description,
      'customer_id': project.customerId,
      'status': project.status,
      'net_value': project.netValue,
      'tax_percent': project.taxPercent,
      'total_value': project.totalValue,
      'notes': project.notes,
      'address': project.address,
      'created_at': project.createdAt.toIso8601String(),
      'updated_at': project.updatedAt.toIso8601String(),
      'customer': customer == null
          ? null
          : {
              'id': customer.id,
              'name': customer.name,
              'phone': customer.phone,
              'address': customer.address,
              'location': customer.address,
            },
      'measurement_sessions': sessionsData,
      'quotes': <Map<String, dynamic>>[],
    };
  }

  Future<void> deleteProject(String projectId) async {
    await (_db.update(
      _db.localProjects,
    )..where((t) => t.id.equals(projectId))).write(
      const LocalProjectsCompanion(
        isDeleted: Value(true),
        syncStatus: Value('pending_delete'),
      ),
    );
    _triggerSync();
  }

  Future<Map<String, dynamic>> updateProjectStatus(
    String projectId,
    String status,
  ) async {
    await (_db.update(
      _db.localProjects,
    )..where((t) => t.id.equals(projectId))).write(
      LocalProjectsCompanion(
        status: Value(status),
        syncStatus: const Value('pending_update'),
      ),
    );
    _triggerSync();

    final updated = await (_db.select(
      _db.localProjects,
    )..where((t) => t.id.equals(projectId))).getSingle();
    return {'id': updated.id, 'status': updated.status};
  }

  // ─── Measurement Sessions ──────────────────────────────────

  Future<Map<String, dynamic>> createSession(
    String projectId, {
    String? technicianId,
    String? notes,
  }) async {
    final id = const Uuid().v4();
    await _db
        .into(_db.localMeasurementSessions)
        .insert(
          LocalMeasurementSessionsCompanion.insert(
            id: Value(id),
            projectId: projectId,
            technicianId: Value(technicianId),
            notes: Value(notes),
            status: const Value('in_progress'),
          ),
        );
    _triggerSync();
    return {
      'id': id,
      'project_id': projectId,
      'technician_id': technicianId,
      'notes': notes,
      'status': 'in_progress',
    };
  }

  // ─── Rooms ───────────────────────────────────────────────

  Future<String> addRoom(String sessionId, String name, {String? type}) async {
    final id = const Uuid().v4();
    await _db
        .into(_db.localRooms)
        .insert(
          LocalRoomsCompanion.insert(
            id: Value(id),
            sessionId: sessionId,
            name: name,
            type: Value(type),
          ),
        );
    _triggerSync();
    return id;
  }

  // ─── Walls ───────────────────────────────────────────────

  Future<String> addWall(
    String roomId,
    String name,
    double length,
    double height,
  ) async {
    final id = const Uuid().v4();
    await _db
        .into(_db.localWalls)
        .insert(
          LocalWallsCompanion.insert(
            id: Value(id),
            roomId: roomId,
            name: name,
            length: Value(length),
            height: Value(height),
            grossArea: Value(length * height),
          ),
        );
    _triggerSync();
    return id;
  }

  // ─── Openings ────────────────────────────────────────────

  Future<String> addOpening(
    String wallId,
    String type,
    double width,
    double height,
    bool deduct,
  ) async {
    final id = const Uuid().v4();
    await _db
        .into(_db.localWallOpenings)
        .insert(
          LocalWallOpeningsCompanion.insert(
            id: Value(id),
            wallId: wallId,
            type: type,
            width: Value(width),
            height: Value(height),
            area: Value(width * height),
            deductFromWall: Value(deduct),
          ),
        );
    _triggerSync();
    return id;
  }

  void _triggerSync() {
    _syncEngine.sync();
  }

  // ─── Fetch Data ──────────────────────────────────────────

  Future<Map<String, dynamic>?> getSessionWithTree(String sessionId) async {
    final sessionQuery = _db.select(_db.localMeasurementSessions)
      ..where((t) => t.id.equals(sessionId));
    final session = await sessionQuery.getSingleOrNull();
    if (session == null) return null;

    final roomsQuery = _db.select(_db.localRooms)
      ..where((t) => t.sessionId.equals(sessionId) & t.isDeleted.equals(false));
    final rooms = await roomsQuery.get();

    final List<Map<String, dynamic>> roomsData = [];

    for (final room in rooms) {
      final wallsQuery = _db.select(_db.localWalls)
        ..where((t) => t.roomId.equals(room.id) & t.isDeleted.equals(false));
      final walls = await wallsQuery.get();

      final List<Map<String, dynamic>> wallsData = [];

      for (final wall in walls) {
        final openingsQuery = _db.select(_db.localWallOpenings)
          ..where((t) => t.wallId.equals(wall.id) & t.isDeleted.equals(false));
        final openings = await openingsQuery.get();

        wallsData.add({
          'id': wall.id,
          'room_id': wall.roomId,
          'name': wall.name,
          'length': wall.length,
          'height': wall.height,
          'gross_area': wall.grossArea,
          'net_area': wall.netArea,
          'material_type': wall.materialType,
          'wall_openings': openings
              .map(
                (o) => {
                  'id': o.id,
                  'wall_id': o.wallId,
                  'type': o.type,
                  'width': o.width,
                  'height': o.height,
                  'area': o.area,
                  'deduct': o.deductFromWall,
                },
              )
              .toList(),
        });
      }

      roomsData.add({
        'id': room.id,
        'session_id': room.sessionId,
        'name': room.name,
        'ceiling_height': room
            .height, // Assuming room height is mapped to ceiling_height in UI
        'walls': wallsData,
      });
    }

    return {
      'id': session.id,
      'project_id': session.projectId,
      'status': session.status,
      'notes': session.notes,
      'rooms': roomsData,
    };
  }

  // ─── Deletions ──────────────────────────────────────────

  Future<void> deleteRoom(String roomId) async {
    await (_db.update(_db.localRooms)..where((t) => t.id.equals(roomId))).write(
      const LocalRoomsCompanion(
        isDeleted: Value(true),
        syncStatus: Value('pending_update'),
      ),
    );
    _triggerSync();
  }

  Future<void> deleteWall(String wallId) async {
    await (_db.update(_db.localWalls)..where((t) => t.id.equals(wallId))).write(
      const LocalWallsCompanion(
        isDeleted: Value(true),
        syncStatus: Value('pending_update'),
      ),
    );
    _triggerSync();
  }

  Future<void> deleteOpening(String openingId) async {
    await (_db.update(
      _db.localWallOpenings,
    )..where((t) => t.id.equals(openingId))).write(
      const LocalWallOpeningsCompanion(
        isDeleted: Value(true),
        syncStatus: Value('pending_update'),
      ),
    );
    _triggerSync();
  }

  Future<void> completeSession(String sessionId) async {
    await (_db.update(
      _db.localMeasurementSessions,
    )..where((t) => t.id.equals(sessionId))).write(
      const LocalMeasurementSessionsCompanion(
        status: Value('completed'),
        syncStatus: Value('pending_update'),
      ),
    );
    _triggerSync();
  }
}
