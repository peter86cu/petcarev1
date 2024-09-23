import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:video_player/video_player.dart';

import '../class/Album.dart';
import '../class/SessionProvider.dart';
import 'Config.dart';
import 'Utiles.dart';


class SharedAlbumsPage extends StatefulWidget {
  @override
  _SharedAlbumsPageState createState() => _SharedAlbumsPageState();
}

class _SharedAlbumsPageState extends State<SharedAlbumsPage> {
  List<Album> albums = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    final session = Provider.of<SessionProvider>(context, listen: false);
    session.checkTokenValidity(context);
    _fetchSharedAlbums();
  }

  Future<void> _fetchSharedAlbums() async {
    final baseUrl = Config.get('api_base_url');
    final session = Provider.of<SessionProvider>(context, listen: false);
    final url = '$baseUrl/api/pet/albums-shared'; // Cambia la URL según tu API
    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer ${session.token!}', // Reemplaza con el token correcto
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        albums = data.map((json) => Album.fromJson(json)).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      // Manejar error en la consulta
      print('Error al obtener los álbumes compartidos: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: albums.length,
        itemBuilder: (context, index) {
          final album = albums[index];
          return AlbumViewer(album: album);
        },
      ),
    );
  }
}


class AlbumViewer extends StatefulWidget {
  final Album album;

  AlbumViewer({required this.album});

  @override
  _AlbumViewerState createState() => _AlbumViewerState();
}

class _AlbumViewerState extends State<AlbumViewer> {
  bool isLiked = false;
  int likeCount = 0;
  VideoPlayerController? _videoPlayerController;
  StompClient? stompClient;

  @override
  void initState() {
    super.initState();
    likeCount = widget.album.likeCount; // Cargar la cantidad de likes inicial
    _loadIsLiked();
    _connectWebSocket();
  }

  void _connectWebSocket() {
    final baseUrlWS = Config.get('api_ws_url');
    stompClient = StompClient(
      config: StompConfig(
        url: '$baseUrlWS/ws',
        onConnect: _onWebSocketConnected,
        onWebSocketError: (dynamic error) => print('WebSocket error: $error'),
        onDisconnect: (frame) => print('WebSocket disconnected'),
      ),
    );
    stompClient?.activate();
  }

  void _onWebSocketConnected(StompFrame frame) {
    stompClient?.subscribe(
      destination: '/topic/album/${widget.album.id}',
      callback: (StompFrame frame) {
        setState(() {
          likeCount = int.parse(frame.body!);
        });
      },
    );
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    stompClient?.deactivate();
    super.dispose();
  }

  Future<void> _loadIsLiked() async {
    final baseUrl = Config.get('api_base_url');
    final session = Provider.of<SessionProvider>(context, listen: false);
    final url = '$baseUrl/api/pet/albums/${widget.album.id}/isLiked';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${session.token!}',
        'Content-Type': 'application/json',
        'userId': session.user!.userid,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (mounted) {
        setState(() {
          isLiked = data['isLiked'];
        });
      }
    } else {
      print('Error al cargar estado de like: ${response.body}');
    }
  }

  Future<void> _handleLike() async {
    setState(() {
      isLiked = !isLiked;
      likeCount = isLiked ? likeCount + 1 : likeCount - 1;
    });

    final baseUrl = Config.get('api_base_url');
    final session = Provider.of<SessionProvider>(context, listen: false);
    final url = '$baseUrl/api/pet/albums/likes';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${session.token!}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'albumId': widget.album.id,
        'liked': isLiked,
        'user': session.user,
        'likeCount': likeCount
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        widget.album.likeCount = likeCount;
        widget.album.isLiked = isLiked;
      });
    } else {
      setState(() {
        isLiked = !isLiked;
        likeCount = isLiked ? likeCount + 1 : likeCount - 1;
      });
      print('Error al guardar el like: ${response.body}');
    }
  }
  Future<File> _createTempFileFromUint8List(Uint8List data) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4');
    await tempFile.writeAsBytes(data);
    return tempFile;
  }

  Future<void> _initializeVideoPlayer(Uint8List videoData) async {
    final videoFile = await _createTempFileFromUint8List(videoData);
    _videoPlayerController = VideoPlayerController.file(videoFile)
      ..initialize().then((_) {
        setState(() {}); // Redibujar cuando el video esté inicializado
        _videoPlayerController?.play(); // Reproducir el video automáticamente
      });
  }
  @override
  Widget build(BuildContext context) {
    final album = widget.album;

    return Stack(
      children: [
        GestureDetector(
          onDoubleTap: _handleLike,
          child: PageView.builder(
            itemCount: album.photos.length,
            itemBuilder: (context, index) {
              final mediaItem = album.photos[index];

              if (mediaItem.mediaType == 'image') {
                return Image.memory(
                  mediaItem.data,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                );
              } else if (mediaItem.mediaType == 'video') {
                // Inicializar el video si aún no ha sido inicializado
                _initializeVideoPlayer(mediaItem.data);

                return _videoPlayerController != null &&
                    _videoPlayerController!.value.isInitialized
                    ? AspectRatio(
                  aspectRatio: _videoPlayerController!.value.aspectRatio,
                  child: VideoPlayer(_videoPlayerController!),
                )
                    : Center(child: CircularProgressIndicator());
              } else {
                return SizedBox.shrink(); // Si no es ni imagen ni video, mostrar espacio vacío
              }
            },
          ),
        ),
        // Posición del avatar y el ícono de "like"
        Positioned(
          right: 16,
          top: MediaQuery.of(context).size.height / 3,
          child: Column(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage:
                Utiles.buildImageBase64(album.pet.fotos, album.pet.especie),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: _handleLike,
                child: Column(
                  children: [
                    Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : Colors.white,
                      size: 40,
                    ),
                    SizedBox(height: 8),
                    Text(
                      likeCount.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
