import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Conversation {
  String name;
  String uuid;

  Conversation({required this.name, required this.uuid});

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'name': name,
    };
  }
}

class Message {
  int? id;
  String conversationId;
  Role role;
  String text;
  Message(
      {this.id,
      required this.conversationId,
      required this.text,
      required this.role});
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': conversationId,
      'role': role.index,
      'text': text,
    };
  }
}

enum Role {
  system,
  user,
  assistant,
}

class ConversationRepository {
  static const String _tableConversationName = 'conversations';
  static const String _tableMessageName = 'messages';
  static const String _columnUuid = 'uuid';
  static const String _columnName = 'name';
  static const String _columnId = 'id';
  static const String _columnRole = 'role';
  static const String _columnText = 'text';
  static Database? _database;
  static ConversationRepository? _instance;

  ConversationRepository._internal();

  factory ConversationRepository() {
    _instance ??= ConversationRepository._internal();
    return _instance!;
  }

  Future<Database> _getDb() async {
    if (_database == null) {
      final String path = join(await getDatabasesPath(), 'chatgpt.db');
      _database = await openDatabase(path, version: 1,
          onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $_tableConversationName (
            $_columnUuid TEXT PRIMARY KEY,
            $_columnName TEXT,
          )
        ''');
        await db.execute('''
          CREATE TABLE message (
            $_columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $_columnUuid TEXT,
            $_columnRole INTEGER,
            $_columnText TEXT,
            FOREIGN KEY ($_columnUuid) REFERENCES conversations($_columnUuid)
          )
        ''');
      });
    }
    return _database!;
  }

  Future<List<Conversation>> getConversations() async {
    final db = await _getDb();
    final List<Map<String, dynamic>> maps =
        await db.query(_tableConversationName);
    return List.generate(maps.length, (i) {
      final uuid = maps[i][_columnUuid];
      final name = maps[i][_columnName];
      return Conversation(
        uuid: uuid,
        name: name,
      );
    });
  }

  Future<void> addConversation(Conversation conversation) async {
    final db = await _getDb();
    await db.insert(
      _tableConversationName,
      conversation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    final randomMessage = Message(
      text: '随机消息',
      role: Role.system,
      conversationId: conversation.uuid,
    );
    await db.insert(
      _tableMessageName,
      randomMessage.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateConversation(Conversation conversation) async {
    final db = await _getDb();
    await db.update(
      _tableConversationName,
      conversation.toMap(),
      where: '$_columnUuid = ?',
      whereArgs: [conversation.uuid],
    );
  }

  Future<void> deleteConversation(String uuid) async {
    final db = await _getDb();
    await db.transaction((txn) async {
      await txn.delete(
        _tableConversationName,
        where: '$_columnUuid = ?',
        whereArgs: [uuid],
      );
      await txn.delete(
        _tableMessageName,
        where: '$_columnUuid = ?',
        whereArgs: [uuid],
      );
    });
  }

  Future<List<Message>> getMessagesByConversationUUid(String uuid) async {
    final db = await _getDb();
    final List<Map<String, dynamic>> maps = await db
        .query(_tableMessageName, where: '$_columnUuid = ?', whereArgs: [uuid]);
    return List.generate(maps.length, (i) {
      final role = Role.values[maps[i][_columnRole]];
      final text = maps[i][_columnText];
      final uuid = maps[i][_columnUuid];
      final id = maps[i][_columnId];
      return Message(
        id: id,
        role: role,
        text: text,
        conversationId: uuid,
      );
    });
  }

  Future<void> addMessage(Message message) async {
    final db = await _getDb();
    await db.insert(
      _tableMessageName,
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteMessage(int id) async {
    final db = await _getDb();
    await db.delete(
      _tableMessageName,
      where: '$_columnId = ?',
      whereArgs: [id],
    );
  }
}
