import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqliteDatabase {
  final String _databaseName = 'pokedex_db';
  final int _version = 1;
  static SqliteDatabase? _instance;
  Database? _database;

  SqliteDatabase._();

  //* Regra para impedir mais de uma instância do database
  //* Único constructor público para gerar a instância
  factory SqliteDatabase.createInstance() {
    _instance ??= SqliteDatabase._();
    return _instance!;
  }

  Future<void> deleteDb() async {
    debugPrint('------------------------------- Deleting database');
    final String dbPath = await getDatabasesPath();
    final String path = join(dbPath, _databaseName);

    //* Perigo
    await deleteDatabase(path);
  }

  Future<Database> openConnection() async {
    final String dbPath = await getDatabasesPath();
    final String path = join(dbPath, _databaseName);

    //* Quando o _database for null uma conexão é aberta
    _database ??= await openDatabase(
      path,
      version: _version,
      onConfigure: _onConfiure,
      onCreate: _onCreate,
      onDowngrade: _onDowngrade,
      onUpgrade: _onUpgrade,
    );

    return _database!;
  }

  void closeConnection() {
    _database?.close();
    _database = null;
  }

  Future<void> _onConfiure(Database db) async {
    db.batch().rawQuery('PRAGMA foreing_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();

    batch.execute('''
      CREATE TABLE user (
        user_id INTEGER PRIMARY KEY NOT NULL,
        username VARCHAR(20) NOT NULL,
        region TEXT NOT NULL,
        avatar BLOB NOT NULL
      );
    ''');

    batch.execute('''
      CREATE TABLE favorite (
        favorite_id INTEGER PRIMARY KEY NOT NULL,
        pokedex_id INTEGER NOT NULL
      );
    ''');

    batch.execute('''
      CREATE TABLE pokemon_name (
        pokemon_id INTEGER PRIMARY KEY NOT NULL,
        name TEXT
      );
    ''');

    batch.execute('''
      CREATE TABLE region (
        region_id INTEGER PRIMARY KEY NOT NULL,
        name TEXT NOT NULL
      )
    ''');

    batch.commit();
  }

  Future<void> _onDowngrade(Database db, int oldVersion, int newVersion) async {}

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {}
}
