import 'package:pocket_union/Dao/sqlite/db_helper_sqlite.dart';
import 'package:pocket_union/domain/enum/couple_usable_state.dart';
import 'package:pocket_union/domain/models/couple.dart';
import 'package:pocket_union/domain/port/local/couple_local_port.dart';
import 'package:pocket_union/domain/port/utils/logger_port.dart';
import 'package:pocket_union/dto/filter/couple_filter_dto.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class CoupleDaoSqlite implements CoupleLocalPort {
  final DbSqlite _dbHelper;
  final LoggerPort _logger;
  final Uuid _uuid = const Uuid();

  CoupleDaoSqlite({required DbSqlite dbHelper, required LoggerPort logger})
    : _dbHelper = dbHelper,
      _logger = logger;

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

    await db.insert(
      'couple',
      couple.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

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
      {'user2_id': userId, 'is_usable': CoupleUsableState.ready.value},
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
      await db.insert(
        'couple',
        couple.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    } catch (e) {
      _logger.error('CoupleDaoSqlite: Error al guardar couple', error: e);
      return false;
    }
  }

  @override
  Future<bool> deleteCouple(String coupleId) async {
    final db = await _dbHelper.database;
    try {
      await db.delete('couple', where: 'id = ?', whereArgs: [coupleId]);
      return true;
    } catch (e) {
      _logger.error('CoupleDaoSqlite: Error al eliminar couple', error: e);
      return false;
    }
  }

  @override
  Future<Couple?> getCoupleById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'couple',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Couple.fromMap(maps.first);
  }

  @override
  Future<List<Couple>> getByFilter(CoupleFilterDto filter) async {
    final db = await _dbHelper.database;
    final where = <String>[];
    final whereArgs = <dynamic>[];

    if (filter.id != null) {
      where.add('id = ?');
      whereArgs.add(filter.id);
    }
    if (filter.userId != null) {
      where.add('(user1_id = ? OR user2_id = ?)');
      whereArgs.addAll([filter.userId, filter.userId]);
    }
    if (filter.inviteCode != null) {
      where.add('invite_code = ?');
      whereArgs.add(filter.inviteCode);
    }
    if (filter.isUsable != null) {
      where.add('is_usable = ?');
      whereArgs.add(filter.isUsable!.value);
    }

    final maps = await db.query(
      'couple',
      where: where.isNotEmpty ? where.join(' AND ') : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
    );
    return maps.map((m) => Couple.fromMap(m)).toList();
  }
}
