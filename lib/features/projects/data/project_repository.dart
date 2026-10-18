import 'package:stream_pay/core/data/supabase_repository.dart';

/// Repository for Project & Measurement operations.
class ProjectRepository extends SupabaseRepository {
  ProjectRepository(super.client);

  // ─── Projects ─────────────────────────────────────────────

  /// Get all projects with customer info.
  Future<List<Map<String, dynamic>>> getProjects({
    String? status,
    int limit = 50,
  }) async {
    var query = client.from('projects').select('''
      *,
      customer:customer_id (id, name, phone)
    ''');

    if (status != null) {
      query = query.eq('status', status);
    }

    final response = await query
        .order('created_at', ascending: false)
        .limit(limit);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Get a project with full measurement tree.
  Future<Map<String, dynamic>?> getProjectWithMeasurements(
    String projectId,
  ) async {
    return await client
        .from('projects')
        .select('''
      *,
      customer:customer_id (id, name, phone, location),
      measurement_sessions (
        *,
        technician:technician_id (full_name),
        rooms (
          *,
          walls (
            *,
            wall_openings (*)
          )
        )
      ),
      quotes (id, quote_number, status, final_total, created_at)
    ''')
        .eq('id', projectId)
        .maybeSingle();
  }

  /// Create a project.
  Future<Map<String, dynamic>> createProject(
    Map<String, dynamic> project,
  ) async {
    return await insert('projects', project);
  }

  /// Update project status.
  Future<Map<String, dynamic>> updateProjectStatus(
    String projectId,
    String status,
  ) async {
    return await update('projects', projectId, {'status': status});
  }

  // ─── Measurement Sessions ──────────────────────────────────

  /// Create a measurement session for a project.
  Future<Map<String, dynamic>> createSession(
    String projectId, {
    String? technicianId,
    String? notes,
  }) async {
    return await client
        .from('measurement_sessions')
        .insert({
          'project_id': projectId,
          'technician_id': technicianId,
          'notes': notes,
        })
        .select()
        .single();
  }

  /// Update session status.
  Future<void> updateSessionStatus(String sessionId, String status) async {
    await client
        .from('measurement_sessions')
        .update({'status': status})
        .eq('id', sessionId);
  }

  /// Complete a session.
  Future<void> completeSession(String sessionId) async {
    await updateSessionStatus(sessionId, 'completed');
  }

  /// Delete a session.
  Future<void> deleteSession(String sessionId) async {
    await client.from('measurement_sessions').delete().eq('id', sessionId);
  }

  // ─── Rooms ──────────────────────────────────────────────────

  /// Add a room to a session.
  Future<Map<String, dynamic>> addRoom(
    String sessionId,
    Map<String, dynamic> room,
  ) async {
    room['session_id'] = sessionId;
    return await client.from('rooms').insert(room).select().single();
  }

  /// Update a room.
  Future<Map<String, dynamic>> updateRoom(
    String roomId,
    Map<String, dynamic> data,
  ) async {
    return await update('rooms', roomId, data);
  }

  /// Delete a room.
  Future<void> deleteRoom(String roomId) async {
    await delete('rooms', roomId);
  }

  // ─── Walls ──────────────────────────────────────────────────

  /// Add a wall to a room.
  Future<Map<String, dynamic>> addWall(
    String roomId,
    Map<String, dynamic> wall,
  ) async {
    wall['room_id'] = roomId;
    return await client.from('walls').insert(wall).select().single();
  }

  /// Update a wall.
  Future<Map<String, dynamic>> updateWall(
    String wallId,
    Map<String, dynamic> data,
  ) async {
    return await update('walls', wallId, data);
  }

  /// Delete a wall.
  Future<void> deleteWall(String wallId) async {
    await delete('walls', wallId);
  }

  // ─── Wall Openings ──────────────────────────────────────────

  /// Add an opening to a wall.
  Future<Map<String, dynamic>> addOpening(
    String wallId,
    Map<String, dynamic> opening,
  ) async {
    opening['wall_id'] = wallId;
    return await client.from('wall_openings').insert(opening).select().single();
  }

  /// Update an opening.
  Future<Map<String, dynamic>> updateOpening(
    String openingId,
    Map<String, dynamic> data,
  ) async {
    return await update('wall_openings', openingId, data);
  }

  /// Delete an opening.
  Future<void> deleteOpening(String openingId) async {
    await delete('wall_openings', openingId);
  }

  // ─── Computed Helpers ───────────────────────────────────────

  /// Get the full measurement tree for a specific session.
  Future<Map<String, dynamic>?> getSessionWithTree(String sessionId) async {
    return await client
        .from('measurement_sessions')
        .select('''
      *,
      technician:technician_id (full_name),
      rooms (
        *,
        walls (
          *,
          wall_openings (*)
        )
      )
    ''')
        .eq('id', sessionId)
        .maybeSingle();
  }
}
