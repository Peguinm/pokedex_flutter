import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:pokedex_app/app/core/database/sqlite_database.dart';
import 'package:pokedex_app/app/core/exceptions/message_exception.dart';
import 'package:pokedex_app/app/core/pokemon_data/pokemon_regions.dart';
import 'package:pokedex_app/app/models/user_model.dart';

class ProfileRepository {
  final SqliteDatabase _sqliteDatabase;

  ProfileRepository({required SqliteDatabase sqliteDatabase}) : _sqliteDatabase = sqliteDatabase;

  Future<List<String>> getRegions() async {
    try {
      final conn = await _sqliteDatabase.openConnection();

      final res = await conn.rawQuery('SELECT * FROM region');
      // debugPrint(res.toString());
      final list = res.map((e) => e['name']).toList().cast<String>();

      return list;
    } on Exception catch (e, s) {
      const String message = 'Erro ao buscar regiões';
      log(message, error: e, stackTrace: s);
    }
    return [];
  }

  Future<void> fillDefaultData() async {
    try {
      final conn = await _sqliteDatabase.openConnection();

      final batch = conn.batch();

      final resUser = await conn.rawQuery('SELECT COUNT(user_id) FROM user');

      if (resUser[0]['COUNT(user_id)'] == 0) {
        final response = await Dio().get(
          'https://i1.sndcdn.com/artworks-000193803962-tla7ov-t500x500.jpg',
          options: Options(
            responseType: ResponseType.bytes,
          ),
        );
        final base64 = base64Encode(response.data);

        batch.execute('''
          INSERT INTO user VALUES (null, 'red', 'kanto', '$base64');
        ''');
      }

      final resRegion = await conn.rawQuery('SELECT COUNT(region_id) FROM region');

      if (resRegion[0]['COUNT(region_id)'] == 0) {
        for (var region in PokemonRegions.regions) {
          batch.execute('INSERT INTO region VALUES (null, ?)', [region]);
        }
      }

      // debugPrint(resUser.toString());
      // debugPrint(resRegion.toString());

      batch.commit();
    } on Exception catch (e, s) {
      const String message = 'Erro ao preencher dados padrão das tables';
      log(message, error: e, stackTrace: s);
      throw MessageException(message: 'Error while loading data');
    }
  }

  Future<UserModel> getUser() async {
    try {
      final conn = await _sqliteDatabase.openConnection();

      final res = await conn.rawQuery('SELECT * FROM user');
      // debugPrint(res.toString());

      return UserModel.fromMap(res[0]);
    } on Exception catch (e, s) {
      const String message = 'Erro ao buscar usuário';
      log(message, error: e, stackTrace: s);
      throw MessageException(message: 'Error while loading data');
    }
  }

  Future<void> updateUser({required String name, required String region, required String blobImage}) async {
    try {
      final conn = await _sqliteDatabase.openConnection();

      await conn.rawUpdate(
        '''
        UPDATE user
        SET
          username = ?,
          region = ?,
          avatar = ?
        WHERE
          user_id = 1
        ''',
        [
          name,
          region,
          blobImage,
        ],
      );
    } on Exception catch (e, s) {
      const String message = 'Erro ao buscar usuário';
      log(message, error: e, stackTrace: s);
      throw MessageException(message: 'Error while loading data');
    }
  }
}
