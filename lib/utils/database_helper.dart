import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
static DatabaseHelper get instance => _instance;
  DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'usuarios.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        // Tabla de usuarios
        await db.execute('''
          CREATE TABLE usuarios (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            apellido TEXT NOT NULL,
            correo TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL
          )
        ''');

        // Tabla de marcadores
        await db.execute('''
          CREATE TABLE marcadores (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            titulo TEXT,
            descripcion TEXT,
            latitud REAL,
            longitud REAL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE marcadores (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              titulo TEXT,
              descripcion TEXT,
              latitud REAL,
              longitud REAL
            )
          ''');
        }
      },
    );
  }

  // === Usuarios ===

  Future<int> insertUser(String nombre, String apellido, String correo, String password) async {
    final db = await database;
    return await db.insert(
      'usuarios',
      {
        'nombre': nombre,
        'apellido': apellido,
        'correo': correo,
        'password': password,
      },
    );
  }

  Future<Map<String, dynamic>?> getUser(String correo, String password) async {
    final db = await database;
    final result = await db.query(
      'usuarios',
      where: 'correo = ? AND password = ?',
      whereArgs: [correo, password],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return await db.query('usuarios', columns: ['id', 'correo']);
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete('usuarios', where: 'id = ?', whereArgs: [id]);
  }

  // === Marcadores ===

  Future<int> insertMarker(String titulo, String descripcion, double latitud, double longitud) async {
    final db = await database;
    return await db.insert(
      'marcadores',
      {
        'titulo': titulo,
        'descripcion': descripcion,
        'latitud': latitud,
        'longitud': longitud,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getMarkers() async {
    final db = await database;
    return await db.query('marcadores');
  }

  Future<void> deleteMarker(int id) async {
    final db = await database;
    await db.delete('marcadores', where: 'id = ?', whereArgs: [id]);
  }
}
