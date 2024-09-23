import 'dart:convert';
import 'dart:io';

import 'package:PetCare/pages/shared_album.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'dart:typed_data'; // Asegúrate de que esta importación esté presente

import '../class/Album.dart';
import '../class/Mascota.dart';
import '../class/SessionProvider.dart';
import 'Config.dart';
import 'Utiles.dart';

import 'package:http/http.dart' as http;

import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';


class AmigosPerrunosPage extends StatefulWidget {
  final Mascota mascota;

  AmigosPerrunosPage({required this.mascota});

  @override
  _AmigosPerrunosPageState createState() => _AmigosPerrunosPageState();
}

class _AmigosPerrunosPageState extends State<AmigosPerrunosPage> {
  List<Album> albums = [];
  bool isLoading = false; // Controlador del loader para álbumes
  bool isSavingPhoto = false; // Controlador del loader para guardar fotos

  @override
  void initState() {
    super.initState();
    _loadAlbumsFromDatabase();
    final session = Provider.of<SessionProvider>(context, listen: false);

    session.checkTokenValidity(context);

  }

  Future<void> _loadAlbumsFromDatabase() async {
    final loadedAlbums = await fetchAlbumsFromDatabase(widget.mascota.mascotaid);

    setState(() {
      albums = loadedAlbums;
      isLoading = false; // Ocultar el loader después de la carga
    });
  }

  Future<List<Album>> fetchAlbumsFromDatabase(String petId) async {
    final baseUrl = Config.get('api_base_url');
    final session = Provider.of<SessionProvider>(context, listen: false);
    final url = '$baseUrl/api/pet/albums?petId=$petId'; // URL de tu API
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer '+session.token!,
        'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      // Convertir la respuesta en una lista de álbumes
      List<Album> albums = data.map((json) => Album.fromJson(json)).toList();

      return albums;
    } else {
      throw Exception('Error al obtener los álbumes: ${response.body}');
    }
  }

  Future<bool> saveAlbumToDatabase(Album album) async {
    final baseUrl = Config.get('api_base_url');
    final session = Provider.of<SessionProvider>(context, listen: false);

    final url = '$baseUrl/api/pet/albums'; // URL de tu API para guardar álbumes
    final requestBody = album.toJson();

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ' + session.token!,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      print('Álbum guardado con éxito.');
      return true;  // Álbum guardado correctamente
    } else if (response.statusCode == 400) {
      Utiles.showInfoDialog(
        context: context,
        title: 'Notificación',
        message: 'El álbum ' + album.name + ' ya existe',
      );
    } else {
      Utiles.showInfoDialog(
        context: context,
        title: 'Error',
        message: 'Error al guardar el álbum: ${response.body}',
      );
    }

    return false;  // Si hay un error, no se debe crear el álbum localmente
  }

  Future<void> addPhotoToDatabase(Photo photo) async {
    final baseUrl = Config.get('api_base_url');
    final session = Provider.of<SessionProvider>(context, listen: false);

    final url = '$baseUrl/api/pet/albums/photos'; // URL para agregar fotos


    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer '+session.token!,
        'Content-Type': 'application/json'},
        body: jsonEncode(photo.toJson())
    );

    if (response.statusCode == 200) {
      print('Foto añadida con éxito.');
    } else {
      print('Error al añadir la foto: ${response.body}');
    }
  }

  Future<void> deletePhotoFromDatabase(String albumId, String photoId) async {
    final baseUrl = Config.get('api_base_url');
    final session = Provider.of<SessionProvider>(context, listen: false);
    final url = '$baseUrl/api/pet/albums/$albumId/photos/$photoId'; // URL para eliminar fotos

    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer '+session.token!,
        'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print('Foto eliminada con éxito.');
    } else {
      print('Error al eliminar la foto: ${response.body}');
    }
  }

  Future<bool> _deleteAlbumFromApi(String albumId) async {
    final baseUrl = Config.get('api_base_url');
    final session = Provider.of<SessionProvider>(context, listen: false);
    final url = '$baseUrl/api/pet/albums/$albumId'; // URL de la API para eliminar el álbum

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer '+session.token!,
          'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // 200 (OK) o 204 (No Content) indica que la eliminación fue exitosa
        return true;
      } else {
        // Si la eliminación falla, imprimir el mensaje de error
        print('Error al eliminar el álbum: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error al conectar con la API: $e');
      return false;
    }
  }

  Future<bool> _updateSharedAlbums(List<Album> sharedAlbums) async {
    final baseUrl = Config.get('api_base_url');
    final session = Provider.of<SessionProvider>(context, listen: false);

    // Aquí estás actualizando los álbumes compartidos
    final url = '$baseUrl/api/pet/albums/share'; // Asegúrate de que este sea el endpoint correcto
    final List<Map<String, dynamic>> requestBody = sharedAlbums.map((album) => album.toJson()).toList();

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${session.token!}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        print('Álbumes compartidos con éxito.');
        return true;
      } else {
        print('Error al compartir álbumes: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error de conexión: $e');
      return false;
    }
  }

  void _showCreateAlbumDialog() {
    final TextEditingController albumNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Crear Álbum'),
          content: TextField(
            controller: albumNameController,
            decoration: InputDecoration(hintText: 'Nombre del Álbum'),
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Crear'),
              onPressed: () async {
                final newAlbum = Album(
                  id: Utiles.getId(),
                  name: albumNameController.text,
                  pet: widget.mascota,
                  fechaCreado: DateTime.now(),
                  photos: [],
                  likeCount: 0
                );
                // Llama al método saveAlbumToDatabase y chequea el resultado
                bool albumGuardado = await saveAlbumToDatabase(newAlbum);

                // Solo agrega el álbum a la lista local si se guardó correctamente (estado 200)
                if (albumGuardado) {
                  setState(() {
                    albums.add(newAlbum);
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _addPhotoToAlbum(Album album) async {
    // Permitir al usuario seleccionar tanto imágenes como videos
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery) ??
        await ImagePicker().pickVideo(source: ImageSource.gallery); // Permitir ambas opciones

    if (pickedFile != null) {
      final Uint8List fileBytes = await File(pickedFile.path).readAsBytes();
      final String fileExtension = pickedFile.path.split('.').last.toLowerCase();
      final String mediaType;

      setState(() {
        isSavingPhoto = true; // Mostrar el loader cuando se guarda la foto
      });

      // Verificar si es imagen o video
      if (fileExtension == 'mp4' || fileExtension == 'mov') {
        mediaType = 'video';
      } else if (fileExtension == 'jpg' || fileExtension == 'jpeg' || fileExtension == 'png') {
        mediaType = 'image';
      } else {
        // Formato no soportado
        Utiles.showInfoDialog(
          context: context,
          title: 'Error',
          message: 'Formato no soportado. Solo se permiten imágenes y videos.',
        );
        setState(() {
          isSavingPhoto = false; // Ocultar el loader si hay un error
        });
        return;
      }

      // Validar el tamaño máximo de 1MB
      if (fileBytes.length > 10485760) {
        Utiles.showInfoDialog(
          context: context,
          title: 'Error',
          message: 'El archivo no puede ser mayor a 1 MB.',
        );
        setState(() {
          isSavingPhoto = false; // Ocultar el loader si el archivo es demasiado grande
        });
        return;
      }

      // Crear objeto Photo o Video
      final newMedia = Photo(
        photoId: Utiles.getId(),
        album: album,
        data: fileBytes,
        fechaCreado: DateTime.now(),
        mediaType: mediaType, // Puede ser 'image' o 'video'
      );

      // Guardar en la base de datos
      await addPhotoToDatabase(newMedia);

      // Actualizar el estado del álbum localmente
      setState(() {
        album.photos.add(newMedia);
        isSavingPhoto = false; // Ocultar el loader después de guardar la foto

      });
    }
  }

  Future<void> _deleteAlbum(Album album) async {
    // Llamar a la API para eliminar el álbum
    final response = await _deleteAlbumFromApi(album.id);

    if (response) {
      setState(() {
        albums.remove(album);  // Eliminar álbum de la lista local solo si la API confirma su eliminación
      });
      print("Álbum eliminado exitosamente.");
    } else {
      print("Error al eliminar el álbum.");
    }
  }



  void _shareAlbum(Album album) async {
    List<String> photoPaths = [];

    for (var photo in album.photos) {
      final file = await _saveImageToTempFile(photo.data);
      photoPaths.add(file.path);
    }

    final String message = '¡Mira este increíble álbum de fotos de ${album.name}!';

    Share.shareFiles(
      photoPaths,
      text: message,
    );
  }

  Future<File> _saveImageToTempFile(Uint8List photoData) async {
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File(filePath);
    await file.writeAsBytes(photoData);
    return file;
  }

  void _viewPhoto(Album album, int index) {
    List<MediaItem> mediaItems = album.photos.map((photo) {
      // Si los datos ya están en Uint8List, los pasamos directamente, de lo contrario, los decodificamos
      Uint8List mediaData =photo.data;
      /*if (photo.data is String) {
        mediaData = base64Decode(photo.data); // Decodificar el base64 a Uint8List si es String
      } else {
        mediaData = photo.data; // Ya es Uint8List
      }*/

      return MediaItem(
        data: mediaData, // Asignar los datos de imagen o video
        mediaType: photo.mediaType, // Usar el tipo de medio del modelo (imagen o video)
      );
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoViewGalleryScreen(
          mediaItems: mediaItems,
          initialIndex: index,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final Mascota mascota = widget.mascota;

    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil de ${mascota.nombre}'),
      ),
      body: Stack(
        children: [
          // Contenido principal
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),

                // Recuadro para los datos de la mascota
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3), // Cambiar la posición de la sombra
                      ),
                    ],
                    border: Border.all(color: Colors.blueAccent),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: Utiles.buildImageBase64(mascota.fotos, mascota.especie),
                      ),
                      SizedBox(height: 20),
                      Text(
                        mascota.nombre,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Sexo: ${mascota.genero}',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Raza: ${mascota.raza}',
                        style: TextStyle(fontSize: 18),
                      ),
                      if (mascota.edad != null)
                        SizedBox(height: 10),
                      if (mascota.edad != null)
                        Text(
                          'Edad: ${mascota.edad}',
                          style: TextStyle(fontSize: 18),
                        ),
                    ],
                  ),
                ),

                SizedBox(height: 30),

                // Botones para Compartir y Crear Álbum
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _showShareAlbumDialog,
                        icon: Icon(Icons.share),
                        label: Text('Compartir Álbum'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _showCreateAlbumDialog,
                        icon: Icon(Icons.add),
                        label: Text('Crear Álbum'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // Grid de álbumes
                GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: albums.length,
                  itemBuilder: (context, index) {
                    final album = albums[index];
                    return Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  album.name,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.visible,
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteAlbum(album),
                              ),
                              IconButton(
                                icon: Icon(Icons.share, color: Colors.blue),
                                onPressed: () => _shareAlbum(album),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Expanded(
                            child: GridView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 4,
                                crossAxisSpacing: 4,
                                childAspectRatio: 1,
                              ),
                              itemCount: album.photos.length + 1,
                              itemBuilder: (context, index) {
                                if (index < album.photos.length) {
                                  final photo = album.photos[index];
                                  return GestureDetector(
                                    onLongPress: () {
                                      _showDeletePhotoDialog(album, index);
                                    },
                                    onTap: () {
                                      _viewPhoto(album, index);
                                    },
                                    child: Image.memory(
                                      photo.data,
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                } else {
                                  return IconButton(
                                    icon: Icon(Icons.add_a_photo, color: Colors.blue, size: 30),
                                    onPressed: () => _addPhotoToAlbum(album),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Loader mientras se cargan los álbumes
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),

          // Loader mientras se guarda la foto
          if (isSavingPhoto)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }


  void _showShareAlbumDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Seleccionar Álbumes para Compartir'),
              content: Container(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: albums.length,
                  itemBuilder: (context, index) {
                    final album = albums[index];
                    return CheckboxListTile(
                      title: Text(album.name),
                      value: album.isSelected,
                      onChanged: (bool? value) {
                        // Si el álbum ya está compartido, no permitir modificar la selección
                        if (album.isShared) {
                          Utiles.showInfoDialog(
                            context: context,
                            title: 'Información',
                            message: 'Este álbum ya ha sido compartido.',
                          );
                          return;
                        }
                        setState(() {
                          album.isSelected = value ?? false;
                        });
                      },
                      // Deshabilitar el checkbox si el álbum ya ha sido compartido
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: Colors.blue,
                      selected: album.isSelected,
                      // Si ya fue compartido, deshabilitar el checkbox
                      enabled: !album.isShared,
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Compartir'),
                  onPressed: () {
                    _navigateToSharedAlbumsPage();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }


  Future<void> _navigateToSharedAlbumsPage() async {
    final sharedAlbums = albums.where((album) => album.isSelected == true).toList();

    // Llamar a la API para actualizar el estado de los álbumes compartidos
    bool success = await _updateSharedAlbums(sharedAlbums);

    if (success) {
      // Si la actualización es exitosa, navega a la página de álbumes compartidos
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SharedAlbumsPage(),
        ),
      );
    } else {
      // Manejar el error de la actualización
      Utiles.showInfoDialog(
        context: context,
        title: 'Error',
        message: 'No se pudieron compartir los álbumes. Intente de nuevo.',
      );
    }
  }


  void _showDeletePhotoDialog(Album album, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Eliminar Foto'),
          content: Text('¿Estás seguro de que quieres eliminar esta foto del álbum?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Eliminar'),
              onPressed: () async {
                final Photo photoToDelete = album.photos[index];

                // Eliminar foto de la base de datos
                await deletePhotoFromDatabase(album.id, photoToDelete.photoId);

                setState(() {
                  album.photos.removeAt(index);
                });

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class MediaItem {
  final Uint8List data;
  final String mediaType; // 'image' o 'video'

  MediaItem({required this.data, required this.mediaType});
}

class PhotoViewGalleryScreen extends StatefulWidget {
  final List<MediaItem> mediaItems;
  final int initialIndex;

  PhotoViewGalleryScreen({required this.mediaItems, required this.initialIndex});

  @override
  _PhotoViewGalleryScreenState createState() => _PhotoViewGalleryScreenState();
}

class _PhotoViewGalleryScreenState extends State<PhotoViewGalleryScreen> {
  VideoPlayerController? _videoPlayerController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _initializeMedia();
    final session = Provider.of<SessionProvider>(context, listen: false);

    session.checkTokenValidity(context);
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  Future<void> _initializeMedia() async {
    if (widget.mediaItems[currentIndex].mediaType == 'video') {
      await _initializeVideo(currentIndex);
    }
  }

  Future<void> _initializeVideo(int index) async {
    // Escribir el video en un archivo temporal
    final tempVideoFile = await _writeToTempFile(widget.mediaItems[index].data, 'temp_video.mp4');
    _videoPlayerController?.dispose(); // Liberar el controlador anterior

    _videoPlayerController = VideoPlayerController.file(tempVideoFile)
      ..initialize().then((_) {
        setState(() {});
        _videoPlayerController?.play();
      });
  }

  Future<File> _writeToTempFile(Uint8List data, String fileName) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(data);
    return file;
  }

  void _onPageChanged(int index) async {
    setState(() {
      currentIndex = index;
    });

    // Si el nuevo medio es un video, inicializar el controlador del video
    if (widget.mediaItems[currentIndex].mediaType == 'video') {
      await _initializeVideo(currentIndex);
    } else {
      _videoPlayerController?.dispose(); // Si es una imagen, liberar el controlador del video
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Galería de Fotos y Videos'),
      ),
      body: PageView.builder(
        itemCount: widget.mediaItems.length,
        scrollDirection: Axis.vertical, // Estilo TikTok, scroll vertical
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          final mediaItem = widget.mediaItems[index];

          // Si es una imagen, mostrarla con PhotoView
          if (mediaItem.mediaType == 'image') {
            return PhotoView(
              imageProvider: MemoryImage(mediaItem.data),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
            );
          }
          // Si es un video, mostrarlo con VideoPlayer
          else if (mediaItem.mediaType == 'video' && _videoPlayerController != null && _videoPlayerController!.value.isInitialized) {
            return AspectRatio(
              aspectRatio: _videoPlayerController!.value.aspectRatio,
              child: VideoPlayer(_videoPlayerController!),
            );
          } else {
            return Center(child: CircularProgressIndicator()); // Mostrar indicador de carga mientras se inicializa el video
          }
        },
      ),
    );
  }
}


