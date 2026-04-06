import 'package:sqflite/sqflite.dart';
import '../../models/user_model.dart';
import '../database/database_helper.dart';
import '../../../core/constants/app_constants.dart';

class UserDao {
  final DatabaseHelper _dbHelper;

  UserDao(this._dbHelper);

  Future<void> insertOrUpdate(UserModel user) async {
    final db = await _dbHelper.database;
    await db.insert(
      AppConstants.usersTable,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserModel?> getUserById(String uid) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.usersTable,
      where: 'uid = ?',
      whereArgs: [uid],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<UserModel?> getLastUser() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.usersTable,
      orderBy: 'createdAt DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<void> deleteUser(String uid) async {
    final db = await _dbHelper.database;
    await db.delete(
      AppConstants.usersTable,
      where: 'uid = ?',
      whereArgs: [uid],
    );
  }

  Future<void> clearAll() async {
    final db = await _dbHelper.database;
    await db.delete(AppConstants.usersTable);
  }
}
