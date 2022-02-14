import 'dart:async';
import 'dart:convert';
import 'package:f_network/photo_list.dart';
import 'package:f_network/repository.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import './models.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<Album> _futureAlbum;
  Future<Album>? _createFutureAlbum;

  final _textController = TextEditingController();

  final _channel =
      WebSocketChannel.connect(Uri.parse('wss://echo.websocket.org'));

  @override
  void initState() {
    super.initState();
    _futureAlbum = fetchAlbum();
  }

  @override
  void dispose() {
    _textController.dispose();
    _channel.sink.close();
    super.dispose();
  }

  Widget deleteBlock() {
    return Center(
      child: FutureBuilder<Album>(
        future: _futureAlbum,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(snapshot.data?.title ?? 'Delete'),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _futureAlbum =
                            deleteAlbum(snapshot.data!.id.toString());
                      });
                    },
                    child: const Text('Delete data'),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
          }

          return const CircularProgressIndicator();
        },
      ),
    );
  }

  Widget photosBlock() {
    return FutureBuilder<List<Photo>>(
      future: fetchPhotos(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('An error has occured'),
          );
        } else if (snapshot.hasData) {
          return PhotoList(
            photos: snapshot.data!,
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget _buildCreateAlbumColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
          controller: _textController,
          decoration: const InputDecoration(hintText: 'Enter title'),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _createFutureAlbum = createAlbum(_textController.text);
            });
          },
          child: const Text('Create data'),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _createFutureAlbum = updateAlbum(_textController.text);
            });
          },
          child: const Text('Update data'),
        ),
      ],
    );
  }

  FutureBuilder<Album> _buildCreateAlbum() {
    return FutureBuilder<Album>(
      future: _createFutureAlbum,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text(snapshot.data!.title);
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Widget createAlbumBlock() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      child: _createFutureAlbum == null
          ? _buildCreateAlbumColumn()
          : _buildCreateAlbum(),
    );
  }

  Widget webSocket() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Form(
            child: TextFormField(
              controller: _textController,
              decoration: const InputDecoration(labelText: 'Send a message'),
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          StreamBuilder(
            builder: (context, snapshot) {
              return Text(snapshot.hasData ? '${snapshot.data}' : '');
            },
            stream: _channel.stream,
          ),
          IconButton(
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                _channel.sink.add(_textController.text);
              }
            },
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Delete data example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Delete data example'),
        ),
        body: webSocket(),
      ),
    );
  }
}
