import 'package:flutter/material.dart' show CircularProgressIndicator, IconData, StatefulWidget, State, BuildContext, Widget, Column;
import 'package:flutter/services.dart';
import 'package:pocket_union/Dao/sqlite/category_dao_sqlite.dart';
import 'package:pocket_union/Dao/sqlite/revenue_dao_sqlite.dart';
import 'package:pocket_union/domain/models/category.dart';
import 'package:pocket_union/domain/models/revenue.dart';
import 'package:pocket_union/ui/Widgets/form_title.dart';
import 'package:pocket_union/ui/Widgets/input_with_button.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewEntryScreen extends StatefulWidget {
  const NewEntryScreen({super.key});

  @override
  _NewEntryScreenState createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  List<String> _categoryNames = [];
  Map<String, IconData> _categoryIcons = {};
  Map<String, String> _categoriesId = {};
  bool _loadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categoryRepo = context.read<CategoryDaoSqlite>();
    try {
      final categories = await _getAllCategories(categoryRepo);
      final names = await _getAllCategoriesNames(categories);
      final icons = await _getAllCategoriesIcons(categories);
      final ids = await _getAllCategoriesId(categories);
      setState(() {
        _categoryNames = names;
        _categoryIcons = icons;
        _categoriesId = ids;
        _loadingCategories = false;
      });
    } catch (e) {
      _loadingCategories = false;
      throw Exception(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final revenueRepo = context.read<RevenueDaoSqlite>();

    return Column(children: [
      FormTitle(title: "Agregar entrada de dinero"),
      _loadingCategories
          ? const CircularProgressIndicator()
          : InputWithButton(
              onSend: (values) {
                _createEntry(values, revenueRepo);
              },
              fieldNames: [
                "nombre",
                "fecha",
                "precio",
                "categoria",
                "descripcion"
              ],
              keyboardTypes: [
                TextInputType.text,
                TextInputType.datetime,
                TextInputType.number,
                TextInputType.multiline
              ],
              inputFormatters: [
                [],
                [],
                [FilteringTextInputFormatter.digitsOnly],
                []
              ],
              dropdownIcons: {'categoria': _categoryIcons},
              buttonName: "Agregar gasto",
              dropdownOptions: {'categoria': _categoryNames},
              dropdownElementString: {'categoria': _categoriesId},
            )
    ]);
  }

  Future<void> _createEntry(
      Map<String, String> values, RevenueDaoSqlite revRepo) async {
    final prefs = await SharedPreferences.getInstance();
    final idUser = prefs.getString('userId');
    print(values);
    try {
      final name = values['nombre']!;
      final DateTime date =
          DateTime.tryParse(values['fecha']!) ?? DateTime.now();
      final price = double.tryParse(values['precio']!);
      final description = values['descripcion'];
      if (name.trim() != '' && price! > 50) {
        final revenue = Revenue(
            id: '',
            idUser: idUser!,
            name: name,
            date: date,
            price: price,
            description: description,
            category: 2,
            inCloud: false);
        int idGenerated = await revRepo.insertRevenue(revenue);
        print(idGenerated);
      }
    } catch (e) {
      return;
    }
  }

  Future<List<Category>> _getAllCategories(CategoryDaoSqlite catRepo) async {
    try {
      List<Category> categoryList = await catRepo.getAllCategories();
      return categoryList;
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> _getAllCategoriesNames(
      List<Category> categoryList) async {
    return categoryList.map((category) => category.name).toList();
  }

  Future<Map<String, IconData>> _getAllCategoriesIcons(
      List<Category> categoryList) async {
    Map<String, IconData> categories = {};
    for (var value in categoryList) {
      final result = <String, IconData>{value.name: value.iconData};
      categories.addEntries(result.entries);
    }
    return categories;
  }

  Future<Map<String, String>> _getAllCategoriesId(
      List<Category> categoryList) async {
    Map<String, String> categories = {};

    for (var value in categoryList) {
      final result = <String, String>{value.name: value.id};
      categories.addEntries(result.entries);
    }
    return categories;
  }
}
