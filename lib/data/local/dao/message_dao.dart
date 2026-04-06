import 'package:sqflite/sqflite.dart';
import '../../models/message_model.dart';
import '../database/database_helper.dart';
import '../../../core/constants/app_constants.dart';

class MessageDao {
  final DatabaseHelper _dbHelper;

  MessageDao(this._dbHelper);

  Future<int> insertMessage(MessageModel message) async {
    final db = await _dbHelper.database;
    return await db.insert(
      AppConstants.messagesTable,
      message.toMap(),
    );
  }

  Future<List<MessageModel>> getMessagesBySession(String sessionId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.messagesTable,
      where: 'sessionId = ?',
      whereArgs: [sessionId],
      orderBy: 'sentAt ASC',
    );
    return maps.map(MessageModel.fromMap).toList();
  }

  Future<List<MessageModel>> getAllMessages() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.messagesTable,
      orderBy: 'sentAt ASC',
    );
    return maps.map(MessageModel.fromMap).toList();
  }

  Future<void> deleteMessage(int id) async {
    final db = await _dbHelper.database;
    await db.delete(
      AppConstants.messagesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearSession(String sessionId) async {
    final db = await _dbHelper.database;
    await db.delete(
      AppConstants.messagesTable,
      where: 'sessionId = ?',
      whereArgs: [sessionId],
    );
  }

  Future<void> clearAll() async {
    final db = await _dbHelper.database;
    await db.delete(AppConstants.messagesTable);
  }

  Future<int> getMessageCount(String sessionId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM ${AppConstants.messagesTable} WHERE sessionId = ?',
      [sessionId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
