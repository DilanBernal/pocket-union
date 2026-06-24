import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_union/Dao/drift/app_database.dart';
import 'package:pocket_union/Dao/drift/daos/category_dao_drift.dart';
import 'package:pocket_union/domain/enum/category_host.dart';
import 'package:pocket_union/domain/enum/sync_status.dart';
import 'package:pocket_union/domain/port/utils/logger_port.dart';
import 'package:pocket_union/dto/new_category_dto.dart';

class _SilentLogger extends LoggerPort {
  @override void info(String message) {}
  @override void debug(String message) {}
  @override void warning(String message) {}
  @override void error(String message, {Object? error, StackTrace? stackTrace}) {}
  @override void logObject(Object object, {String? label}) {}
}

void main() {
  late AppDatabase db;
  late CategoryDaoDrift dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = CategoryDaoDrift(
      appDatabase: db,
      logger: _SilentLogger(),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('CategoryDaoDrift', () {
    test('crear y leer categoría por ID', () async {
      final id = await dao.createCategory(
        NewCategoryDto(
          name: 'Comida',
          host: CategoryHost.expense,
          coupleId: 'couple-1',
        ),
      );

      expect(id, isNotEmpty);

      final category = await dao.getCategoryById(id);

      expect(category, isNotNull);
      expect(category!.name, 'Comida');
      expect(category.coupleId, 'couple-1');
      expect(category.categoryHost, CategoryHost.expense);
      expect(category.syncStatus, SyncStatus.pending);
    });

    test('getCategoryById retorna null para ID inexistente', () async {
      final category = await dao.getCategoryById('non-existent');

      expect(category, isNull);
    });

    test('getAllCategories retorna todas las categorías', () async {
      await dao.createCategory(
        NewCategoryDto(name: 'Comida', host: CategoryHost.expense, coupleId: 'couple-1'),
      );
      await dao.createCategory(
        NewCategoryDto(name: 'Salario', host: CategoryHost.income, coupleId: 'couple-1'),
      );

      final categories = await dao.getAllCategories();

      expect(categories, hasLength(2));
    });

    test('getCategoriesByHost filtra por tipo', () async {
      await dao.createCategory(
        NewCategoryDto(name: 'Comida', host: CategoryHost.expense, coupleId: 'couple-1'),
      );
      await dao.createCategory(
        NewCategoryDto(name: 'Transporte', host: CategoryHost.expense, coupleId: 'couple-1'),
      );
      await dao.createCategory(
        NewCategoryDto(name: 'Salario', host: CategoryHost.income, coupleId: 'couple-1'),
      );

      final expenses = await dao.getCategoriesByHost(CategoryHost.expense);
      final incomes = await dao.getCategoriesByHost(CategoryHost.income);

      expect(expenses, hasLength(2));
      expect(incomes, hasLength(1));
    });

    test('createDefaultCategories crea categorías predefinidas', () async {
      final categories = await dao.createDefaultCategories('couple-1');

      expect(categories, hasLength(4));
      expect(categories.every((c) => c.coupleId == 'couple-1'), isTrue);

      final all = await dao.getAllCategories();
      expect(all, hasLength(4));
    });
  });
}
