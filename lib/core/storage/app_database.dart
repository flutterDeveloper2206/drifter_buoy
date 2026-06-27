import 'package:drifter_buoy/features/general_user/data/models/drifter_buoy_command_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('drifter_buoy.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE buoy_commands (
        id TEXT PRIMARY KEY,
        testName TEXT NOT NULL,
        requestCommand TEXT NOT NULL,
        waitingPeriodSecondsRaw TEXT NOT NULL,
        requestCommandDescription TEXT NOT NULL,
        response TEXT NOT NULL,
        responseDescription TEXT NOT NULL,
        note TEXT,
        isActive INTEGER NOT NULL,
        serialNumber INTEGER NOT NULL
      )
    ''');
  }

  Future<void> saveCommands(List<DrifterBuoyCommandModel> commands) async {
    final db = await instance.database;
    final batch = db.batch();

    // Clear existing commands
    batch.delete('buoy_commands');

    final seenIds = <String>{};
    for (final cmd in commands) {
      if (seenIds.add(cmd.id)) {
        batch.insert('buoy_commands', {
          'id': cmd.id,
          'testName': cmd.testName,
          'requestCommand': cmd.requestCommand,
          'waitingPeriodSecondsRaw': cmd.waitingPeriodSecondsRaw,
          'requestCommandDescription': cmd.requestCommandDescription,
          'response': cmd.response,
          'responseDescription': cmd.responseDescription,
          'note': cmd.note,
          'isActive': cmd.isActive ? 1 : 0,
          'serialNumber': cmd.serialNumber,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }

    await batch.commit(noResult: true);
  }

  Future<List<DrifterBuoyCommandModel>> getCommands() async {
    final db = await instance.database;
    final result = await db.query('buoy_commands');

    return result.map((json) {
      return DrifterBuoyCommandModel(
        id: json['id'] as String,
        testName: json['testName'] as String,
        requestCommand: json['requestCommand'] as String,
        waitingPeriodSecondsRaw: json['waitingPeriodSecondsRaw'] as String,
        requestCommandDescription: json['requestCommandDescription'] as String,
        response: json['response'] as String,
        responseDescription: json['responseDescription'] as String,
        note: json['note'] as String?,
        isActive: (json['isActive'] as int) == 1,
        serialNumber: json['serialNumber'] as int,
      );
    }).toList();
  }
}
