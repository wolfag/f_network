import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:f_network/models.dart';

Future<Album> fetchAlbum() async {
  final http.Response response = await http.get(
    Uri.parse(
      'https://jsonplaceholder.typicode.com/albums/1',
    ),
    headers: {
      HttpHeaders.authorizationHeader: 'Basic your_api_token',
    },
  );

  if (response.statusCode == 200) {
    return Album.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load album');
  }
}

Future<Album> deleteAlbum(String id) async {
  final http.Response response = await http.delete(
    Uri.parse('https://jsonplaceholder.typicode.com/albums/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  if (response.statusCode == 200) {
    return Album.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to delete album');
  }
}

Future<List<Photo>> fetchPhotos() async {
  final http.Response response = await http.get(
    Uri.parse('https://jsonplaceholder.typicode.com/photos'),
  );

  if (response.statusCode == 200) {
    // return Photo.parsePhotos(response.body);
    return compute(Photo.parsePhotos, response.body);
  } else {
    throw Exception('Failed to load photos');
  }
}

Future<Album> createAlbum(String title) async {
  final http.Response response = await http.post(
    Uri.parse('https://jsonplaceholder.typicode.com/albums'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(
      <String, String>{
        'title': title,
      },
    ),
  );

  if (response.statusCode == 201) {
    return Album.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to create album');
  }
}

Future<Album> updateAlbum(String title) async {
  final http.Response response = await http.put(
    Uri.parse('https://jsonplaceholder.typicode.com/albums/1'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(
      <String, String>{
        'title': title,
      },
    ),
  );

  if (response.statusCode == 200) {
    return Album.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('has error when update album');
  }
}
