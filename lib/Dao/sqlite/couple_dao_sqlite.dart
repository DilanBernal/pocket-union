import 'package:pocket_union/Dao/sqlite/db_helper_sqlite.dart';
import 'package:pocket_union/domain/enum/couple_usable_state.dart';
import 'package:pocket_union/domain/models/couple.dart';
import 'package:pocket_union/domain/port/auth/couple_port.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class CoupleDaoSqlite implements CouplePort {
  final DbSqlite _dbHelper;
  final Uuid _uuid = const Uuid();

  CoupleDaoSqlite({required DbSqlite dbHelper}) : _dbHelper = dbHelper;

  @override
  Future<Couple> createCouple(String userId, String inviteCode) async {
    final db = await _dbHelper.database;
    final couple = Couple(
      id: _uuid.v4(),
      createdAt: DateTime.now(),
      user1Id: userId,
      inviteCode: inviteCode,
      isUsable: CoupleUsableState.waiting,
    );

    await db.insert('couple', couple.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);

    return couple;
  }

  @override
  Future<Couple> joinCoupleByCode(String inviteCode, String userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'couple',
      where: 'invite_code = ?',
      whereArgs: [inviteCode],
      limit: 1,
    );

    if (maps.isEmpty) {
      throw Exception('No se encontró una pareja con ese código de invitación');
    }

    final couple = Couple.fromMap(maps.first);

    if (couple.user2Id != null) {
      throw Exception('Esta invitación ya fue aceptada por otra persona');
    }

    final updatedCouple = Couple(
      id: couple.id,
      createdAt: couple.createdAt,
      user1Id: couple.user1Id,
      user2Id: userId,
      inviteCode: couple.inviteCode,
      isUsable: CoupleUsableState.ready,
    );

    await db.update(
      'couple',
      {
        'user2_id': userId,
        'is_usable': CoupleUsableState.ready.value,
      },
      where: 'id = ?',
      whereArgs: [couple.id],
    );

    return updatedCouple;
  }

  @override
  Future<Couple?> getCoupleByUserId(String userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'couple',
      where: 'user1_id = ? OR user2_id = ?',
      whereArgs: [userId, userId],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Couple.fromMap(maps.first);
  }

  @override
  Future<Couple?> getCoupleByInviteCode(String inviteCode) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'couple',
      where: 'invite_code = ?',
      whereArgs: [inviteCode],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Couple.fromMap(maps.first);
  }

  @override
  Future<bool> upsertCouple(Couple couple) async {
    final db = await _dbHelper.database;
    try {
      await db.insert('couple', couple.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> deleteCouple(String coupleId) async {
    final db = await _dbHelper.database;
    try {
      await db.delete('couple', where: 'id = ?', whereArgs: [coupleId]);
      return true;
    } catch (_) {
      return false;
    }
  }
}
