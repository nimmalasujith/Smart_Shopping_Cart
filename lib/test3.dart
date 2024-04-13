import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';

class VideoScreen extends StatefulWidget {
  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late StreamController<Image> _streamController;
  late IO.Socket socket;
  late List<Uint8List> _buffer; // Buffer for storing frames
  late bool _isPlaying; // Flag to control video playback

  @override
  void initState() {
    super.initState();
    _streamController = StreamController<Image>();
    _buffer = [];
    _isPlaying = false;

    _connectToSocket();
  }

  void _connectToSocket() {
    socket = IO.io('http://127.0.0.1:8000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.on('connect', (_) {
      print('Connected');
    });

    socket.on('frame', (event) {
      // Add received frame to buffer
      _buffer.add(base64Decode(event));
      // Start playing video if not already playing
      if (!_isPlaying) _playVideo();
    });

    socket.connect();
  }

  void _playVideo() async {
    _isPlaying = true;
    while (_buffer.isNotEmpty) {
      // Remove frame from buffer and display it
      final frame = _buffer.removeAt(0);
      final image = Image.memory(frame);
      // Update UI with the new frame
      _streamController.add(image);
      // Pause briefly to control frame rate
      await Future.delayed(Duration(milliseconds: 50));
    }
    _isPlaying = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Stream'),
      ),
      body: Center(
        child: StreamBuilder<Image>(
          stream: _streamController.stream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return snapshot.data!;
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _streamController.close();
    socket.disconnect();
    super.dispose();
  }
}
