import 'package:drift/drift.dart';
import 'package:pocket_union/Dao/drift/app_database.dart';
import 'package:pocket_union/Dao/drift/mappers/user_mapper.dart';
import 'package:pocket_union/domain/models/auth/user.dart';
import 'package:pocket_union/domain/port/local/user_port_local.dart';
import 'package:pocket_union/domain/port/utils/logger_port.dart';
import 'package:pocket_union/dto/filter/user_filter_dto.dart';

class UserDaoDrift extends UserLocalPort {
  final AppDatabase _db;
  final LoggerPort _logger;
  final UserMapper _mapper;

  UserDaoDrift({
    required AppDatabase appDatabase,
    required LoggerPort logger,
    UserMapper? mapper,
  })  : _db = appDatabase,
        _logger = logger,
        _mapper = mapper ?? UserMapper();

  @override
  Future<bool> upsertUser(DomainUser user) async {
    try {
      final companion = _mapper.toCompanion(user);
      await _db.into(_db.profiles).insertOnConflictUpdate(companion);
      return true;
    } catch (e, st) {
      _logger.error('UserDaoDrift: upsertUser falló', error: e, stackTrace: st);
      return false;
    }
  }

  @override
  Future<DomainUser?> getUserById(String id) async {
    try {
      final result = await (_db.select(_db.profiles)
            ..where((tbl) => tbl.id.equals(id))
            ..limit(1))
          .getSingleOrNull();
      return result != null ? _mapper.toDomain(result) : null;
    } catch (e, st) {
      _logger.error('UserDaoDrift: getUserById falló', error: e, stackTrace: st);
      return null;
    }
  }

  @override
  Future<DomainUser?> getCurrentUser() async {
    try {
      final result = await (_db.select(_db.profiles)..limit(1)).getSingleOrNull();
      return result != null ? _mapper.toDomain(result) : null;
    } catch (e, st) {
      _logger.error('UserDaoDrift: getCurrentUser falló', error: e, stackTrace: st);
      return null;
    }
  }

  @override
  Future<List<DomainUser>> getByFilter(UserFilterDto filter) async {
    try {
      final query = _db.select(_db.profiles);
      query.where((tbl) {
        final predicates = <Expression<bool>>[];
        if (filter.id != null && filter.id!.trim().isNotEmpty) {
          predicates.add(tbl.id.equals(filter.id!.trim()));
        }
        if (filter.fullName != null && filter.fullName!.trim().isNotEmpty) {
          predicates.add(tbl.fullName.like('%${filter.fullName!.trim()}%'));
        }
        if (predicates.isEmpty) return const Constant(true);
        return predicates.reduce((a, b) => a & b);
      });
      final rows = await query.get();
      return rows.map(_mapper.toDomain).toList();
    } catch (e, st) {
      _logger.error('UserDaoDrift: getByFilter falló', error: e, stackTrace: st);
      return [];
    }
  }

  @override
  Future<bool> deleteAllUsers() async {
    try {
      await _db.delete(_db.profiles).go();
      return true;
    } catch (e, st) {
      _logger.error('UserDaoDrift: deleteAllUsers falló', error: e, stackTrace: st);
      return false;
    }
  }
}
