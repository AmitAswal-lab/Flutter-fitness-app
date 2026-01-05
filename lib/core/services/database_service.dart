import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Database service for local SQLite storage
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;
  static const String _dbName = 'fitness_app.db';
  static const int _dbVersion = 1;

  /// Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create tables on first database creation
  Future<void> _onCreate(Database db, int version) async {
    // Custom workouts table
    await db.execute('''
      CREATE TABLE custom_workouts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        category TEXT NOT NULL,
        difficulty TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Custom workout exercises table (one-to-many relationship)
    await db.execute('''
      CREATE TABLE custom_workout_exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_id TEXT NOT NULL,
        exercise_id TEXT NOT NULL,
        exercise_name TEXT NOT NULL,
        category TEXT NOT NULL,
        is_time_based INTEGER NOT NULL,
        reps INTEGER NOT NULL,
        duration_seconds INTEGER NOT NULL,
        rest_seconds INTEGER NOT NULL,
        order_index INTEGER NOT NULL,
        FOREIGN KEY (workout_id) REFERENCES custom_workouts (id) ON DELETE CASCADE
      )
    ''');

    // Workout history table (for future use)
    await db.execute('''
      CREATE TABLE workout_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_id TEXT,
        workout_name TEXT NOT NULL,
        started_at TEXT NOT NULL,
        completed_at TEXT,
        duration_seconds INTEGER,
        exercises_completed INTEGER,
        total_exercises INTEGER,
        calories_burned INTEGER
      )
    ''');

    // Create index for faster queries
    await db.execute(
      'CREATE INDEX idx_workout_exercises ON custom_workout_exercises (workout_id)',
    );
    await db.execute(
      'CREATE INDEX idx_workout_history_date ON workout_history (started_at)',
    );
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Add migration logic here when schema changes
    // Example:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE custom_workouts ADD COLUMN is_favorite INTEGER DEFAULT 0');
    // }
  }

  /// Close database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
