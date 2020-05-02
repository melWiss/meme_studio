import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart' as path;
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter/foundation.dart';

Future getDatabase() async {
  File database = File(join(
      (await path.getApplicationDocumentsDirectory()).path,
      'pictures_database.db'));
  if (!(await database.exists())) {
    database = await database.create(recursive: true);
  }
  String data = await database.readAsString();
  if (data.length == 0) {
    database.writeAsStringSync(jsonEncode({}));
  }
  return database;
}

Future<void> insertPicture(String picture) async {
  File db = await getDatabase();
  Map<String, dynamic> data = jsonDecode(db.readAsStringSync());
  if (!data.keys.contains(picture)) {
    ImageProperties props =
        await FlutterNativeImage.getImageProperties(picture);
    File file = await FlutterNativeImage.compressImage(picture,
        quality: 80,
        targetWidth: 100,
        targetHeight: (props.height * 100 / props.width).round());
    data.addEntries([
      MapEntry(picture, {
        'path': picture,
        'uploaded': false,
        'thumb': base64Encode(file.readAsBytesSync())
      })
    ]);
    db.writeAsStringSync(jsonEncode(data));
  }
}

Future insertPictureSec(String picture)async{
  var bananas = await compute(insertPicture,picture);
}

Future<void> insertPictures(List<File> pictures) async {
  File db = await getDatabase();
  Map<String, dynamic> data = jsonDecode(db.readAsStringSync());
  pictures.forEach((pictureFile) async {
    String picture = pictureFile.path;
    if (!data.keys.contains(picture)) {
      ImageProperties props =
          await FlutterNativeImage.getImageProperties(picture);
      File file = await FlutterNativeImage.compressImage(picture,
          quality: 80,
          targetWidth: 100,
          targetHeight: (props.height * 100 / props.width).round());
      data.addEntries([
        MapEntry(picture, {
          'path': picture,
          'uploaded': false,
          'thumb': base64Encode(file.readAsBytesSync())
        })
      ]);
      db.writeAsStringSync(jsonEncode(data));
    }
  });
}

Future<List<Map<String, dynamic>>> getPictures() async {
  File db = await getDatabase();
  Map<String, dynamic> data = jsonDecode(db.readAsStringSync());
  List keys = data.keys.toList();
  List<Map<String, dynamic>> pics = List<Map<String, dynamic>>();
  for (var index = 0; index < keys.length; index++) {
    if (await File(data[keys[index]]['path']).exists())
      pics.add(data[keys[index]]);
    else
      await deletePicture(data[keys[index]]);
  }
  return pics;
}

Future<void> updatePicture(String picture, bool status) async {
  File db = await getDatabase();
  Map<String, dynamic> data = jsonDecode(db.readAsStringSync());
  if (data.keys.contains(picture)) {
    data[picture] = {
      'path': picture,
      'uploaded': status,
      'thumb': data[picture]['thumb']
    };
    db.writeAsStringSync(jsonEncode(data));
  }
}

Future<void> deletePicture(String picture) async {
  File db = await getDatabase();
  Map<String, dynamic> data = jsonDecode(db.readAsStringSync());
  if (data.keys.contains(picture)) {
    data.remove(picture);
    db.writeAsStringSync(jsonEncode(data));
  }
}

Future<void> deleteAllPictures()async{
  File db = await getDatabase();
  Map<String,dynamic> data = jsonDecode(db.readAsStringSync());
  data.clear();
  db.writeAsStringSync(jsonEncode(data));
}
