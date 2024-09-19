import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:PetCare/class/extensions.dart';
import 'package:PetCare/pages/peso_page.dart';
import 'package:PetCare/pages/service_page.dart';
import 'package:PetCare/pages/shared_album.dart';
import 'package:PetCare/pages/tips_page.dart';
import 'package:PetCare/pages/vacuna_page.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:carousel_slider/carousel_controller.dart' as slider;
import 'package:image_picker/image_picker.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uni_links/uni_links.dart';

import '../class/ActividadEstilista.dart';
import '../class/ActividadNegocio.dart';
import '../class/CalendarioDay.dart';
import '../class/CalendarioWork.dart';
import '../class/Event.dart';
import '../class/Mascota.dart';
import '../class/Review.dart';
import '../class/SessionProvider.dart';
import '../class/User.dart';
import '../class/Vacunas.dart';
import '../class/carnet_page.dart';
import '../class/desparasitaciones.dart';
import '../class/scan_ship_page.dart';
import 'Config.dart';
import 'Utiles.dart';
import 'add_mascota.dart';

import 'package:geolocator/geolocator.dart';

import '../class/Negocio.dart';
import 'package:http/http.dart' as http;

import 'adoption_pets.dart';
import 'amigos_perruno_page.dart';
import 'frendly_page.dart';
import 'home_estilista.dart';
import 'package:url_launcher/url_launcher.dart';

import 'lost_pets_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeContent(),
    MisMascotasPage(),
    //NearbyBusinessesPage(),
    PetTipsPage(),
    SharedAlbumsPage(),
    ChatPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    final session = Provider.of<SessionProvider>(context, listen: false);
    session.checkTokenValidity(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Mis Mascotas',
          ),
          /*BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Servicio',
          ),*/
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb),
            label: 'Tips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.social_distance),
            label: 'Social',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
        unselectedItemColor: Colors.black,
        backgroundColor: Colors.blueGrey[900],
        elevation: 10,
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  @override
  _HomeContent createState() => _HomeContent();
}

class _HomeContent extends State<HomeContent> {
  int _currentIndex = 0;
  final CarouselSliderController _controller =
      slider.CarouselSliderController();
  String? _selectedService;
  @override
  void initState() {
    super.initState();
    final session = Provider.of<SessionProvider>(context, listen: false);
    session.checkTokenValidity(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'lib/assets/perro.png', // Ruta de la imagen del logo
              height: 40, // Ajusta el tamaño del logo según tus necesidades
            ),
            SizedBox(width: 10),
            Text('PetCare+'), // Título de la cabecera
          ],
        ),
        centerTitle: true, // Centra el título en la AppBar
      ),
      body: Container(
        color: Colors.grey[200], // Color de fondo gris claro
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20), // Espacio entre el título y el carrusel
              // Carrusel de imágenes
              CarouselSlider(
                items: [
                  _buildCarouselItem('lib/assets/message1.jpg'),
                  _buildCarouselItem('lib/assets/message2.jpg'),
                  _buildCarouselItem('lib/assets/message3.jpg'),
                ],
                carouselController: _controller,
                options: CarouselOptions(
                  height: MediaQuery.of(context).size.height *
                      0.3, // Ajusta la altura según lo necesites
                  enlargeCenterPage: true,
                  autoPlay: true,
                  aspectRatio: 16 / 9,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  viewportFraction:
                      1.0, // Esto asegura que cada imagen ocupe todo el ancho de la pantalla
                ),
              ),
              // Puntos de la imagen activa
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [0, 1, 2].map((index) {
                  return GestureDetector(
                    onTap: () => _controller.animateToPage(index),
                    child: Container(
                      width: 12.0, // Tamaño del punto
                      height: 12.0, // Tamaño del punto
                      margin:
                          EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == index
                            ? Colors.blueAccent
                            : Colors.grey,
                      ),
                    ),
                  );
                }).toList(),
              ),
              // Sección de servicios
              _buildServicesSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarouselItem(String imagePath) {
    return Builder(
      builder: (BuildContext context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.symmetric(horizontal: 5.0),
          decoration: BoxDecoration(
            color: Colors.amber,
          ),
          child: Center(
            child: Image.asset(imagePath, fit: BoxFit.cover),
          ),
        );
      },
    );
  }

  final List<Map<String, dynamic>> _services = [
    {'name': 'SALUD', 'image': 'lib/assets/iconos/veterinario.png'},
    {'name': 'BELLEZA', 'image': 'lib/assets/peluqueria.png'},
    {'name': 'ALIMIENTACIÓN', 'image': 'lib/assets/iconos/tazon-del-perro.png'},
    {'name': 'TIPS', 'image': 'lib/assets/iconos/tips.png'},
    {'name': 'CIUDADPET', 'image': 'lib/assets/iconos/ciudadpet.png'},
    {'name': 'VIAJES', 'image': 'lib/assets/iconos/avion.png'},
    {'name': 'RECREACIÓN', 'image': 'lib/assets/iconos/parque-para-perros.png'},
  ];

  final Map<String, List<Map<String, dynamic>>> _subservices = {
    'SALUD': [
      {
        'name': 'Veterinarias',
        'image': 'lib/assets/iconos/veterinario-mascota.png'
      },
      {'name': 'Telemedicina', 'image': 'lib/assets/iconos/telemedicina.png'},
      {'name': 'Examenes', 'image': 'lib/assets/iconos/estetoscopio.png'},
      {
        'name': 'Nutrición',
        'image': 'lib/assets/iconos/alimentos-organicos.png'
      },
      {
        'name': 'Veterinario en casa',
        'image': 'lib/assets/iconos/ambulatorio.png'
      },
      {'name': 'Profilaxis', 'image': 'lib/assets/iconos/empaste-dental.png'},
      {
        'name': 'Seguro a tu mascota',
        'image': 'lib/assets/iconos/seguro-medico.png'
      },
      {
        'name': 'Lavado de dientes',
        'image': 'lib/assets/iconos/limpieza-dental.png'
      },
      {'name': 'Vacunación', 'image': 'lib/assets/iconos/jeringa.png'},
    ],
    'BELLEZA': [
      {'name': 'Peluquería', 'image': 'lib/assets/iconos/tijeras.png'},
      {'name': 'Baño', 'image': 'lib/assets/iconos/lavadero.png'},
      {'name': 'Corte de uñas', 'image': 'lib/assets/iconos/cortaunas.png'},
      {'name': 'Spa', 'image': 'lib/assets/iconos/spa.png'},
    ],
    'RECREACIÓN': [
      {'name': 'Paseos', 'image': 'lib/assets/iconos/perro-caminando.png'},
      {'name': 'Guarderias', 'image': 'lib/assets/iconos/mascota.png'},
      {'name': 'Eventos y ferias', 'image': 'lib/assets/iconos/evento.png'},
      {'name': 'Día de sol', 'image': 'lib/assets/iconos/sol-sonriente.png'},
      {'name': 'Pet Friendly', 'image': 'lib/assets/iconos/friendly.png'},
    ],
    'ALIMIENTACIÓN': [
      {'name': 'Comidas', 'image': 'lib/assets/iconos/hueso.png'},
      {
        'name': 'Comida Balanceada',
        'image': 'lib/assets/iconos/comida-balanceada.png'
      },
      {'name': 'Snacks', 'image': 'lib/assets/iconos/snacks.png'},
      {'name': 'Helados', 'image': 'lib/assets/iconos/helado.png'},
      {'name': 'Yogurt', 'image': 'lib/assets/iconos/yogurt.png'},
    ],

    'TIPS': [
      {
        'name': 'Alimentación',
        'image': 'lib/assets/iconos/plato-de-perro-vacio.png'
      },
      {'name': 'Cuidado del pelaje', 'image': 'lib/assets/iconos/peine.png'},
      {'name': 'Control de peso', 'image': 'lib/assets/iconos/balanza.png'},
      {'name': 'Actividad física', 'image': 'lib/assets/iconos/pelota.png'},
      {
        'name': 'Tu mascota ideal',
        'image': 'lib/assets/iconos/mascota-ideal.png'
      },
    ],
    'CIUDADPET': [
      {'name': 'Voluntariados', 'image': 'lib/assets/iconos/voluntariado.png'},
      {'name': 'Donaciones', 'image': 'lib/assets/iconos/donaciones.png'},
      {
        'name': 'Patrocinios',
        'image': 'lib/assets/iconos/apreton-de-manos.png'
      },
      {'name': 'Perdidos', 'image': 'lib/assets/iconos/collar-de-perro.png'},
      {
        'name': 'Adopción',
        'image': 'lib/assets/iconos/cuidadores-de-gatos.png'
      },
    ],
    'VIAJES': [
      {'name': 'Trámites', 'image': 'lib/assets/iconos/aeropuerto.png'},
      {
        'name': 'Seguro de viaje',
        'image': 'lib/assets/iconos/seguro-de-vuelo.png'
      },
      {'name': 'Ship', 'image': 'lib/assets/iconos/etiqueta-rfid.png'},
    ],
    // Agregar subservicios para los demás servicios...
  };

  Widget _buildServicesSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.orangeAccent),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          _selectedService == null
              ? GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                  ),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _services.length,
                  itemBuilder: (context, index) {
                    final service = _services[index];
                    final isSelected = _selectedService == service['name'];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedService = service['name'];
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 60.0, // Circle width
                            height: 60.0, // Circle height
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  isSelected ? Colors.blueAccent : Colors.white,
                            ),
                            child: service['image'] != null
                                ? ClipOval(
                                    child: Image.asset(
                                      service['image'] as String,
                                      fit: BoxFit.cover,
                                      width: 50.0, // Smaller image width
                                      height: 50.0, // Smaller image height
                                    ),
                                  )
                                : Icon(
                                    Icons.image, // Fallback icon
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.blue[600],
                                    size: 30.0, // Icon size
                                  ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            service['name'] as String,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color:
                                  isSelected ? Colors.blueAccent : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Servicios',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                        childAspectRatio:
                            3, // Adjust the aspect ratio if needed
                      ),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _subservices[_selectedService]!.length,
                      itemBuilder: (context, index) {
                        final subservice =
                            _subservices[_selectedService]![index];

                        return GestureDetector(
                          onTap: () {
                            // Aquí puedes manejar la acción cuando se selecciona un subservicio
                            _navigateToBusinessList(
                                context, subservice['name'], index);
                          },
                          child: Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.orangeAccent),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Row(
                              children: [
                                ClipOval(
                                  child: Image.asset(
                                    subservice['image'] as String,
                                    fit: BoxFit.cover,
                                    width: 30.0,
                                    height: 30.0,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    subservice['name'] as String,
                                    style: TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedService =
                              null; // Regresar a la lista principal
                        });
                      },
                      child: Text('Volver'),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  void _navigateToSubservice(BuildContext context, String subserviceName) {
    // Aquí puedes manejar la navegación a la pantalla de detalles del subservicio seleccionado
    // Por ejemplo:
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusinessListScreen(serviceName: subserviceName),
      ),
    ).then((_) {
      // No necesitas hacer nada aquí para el estado, ya que _selectedService se mantendrá
    });
    /* Navigator.push(
      context,
      MaterialPageRoute(
        //builder: (context) => SubserviceDetailScreen(subserviceName: subserviceName),
      ),
    );*/
  }

  void _navigateToBusinessList(
      BuildContext context, String serviceName, int posicion) {
    if (posicion < 3)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BusinessListScreen(serviceName: serviceName),
        ),
      ).then((_) {
        // No necesitas hacer nada aquí para el estado, ya que _selectedService se mantendrá
      });

    if (serviceName == 'Perdidos' && posicion == 3)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LostPetsScreen(),
        ),
      ).then((_) {
        // No necesitas hacer nada aquí para el estado, ya que _selectedService se mantendrá
      });

    if (serviceName == 'Adopción' && posicion == 4)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdoptionScreen(),
        ),
      ).then((_) {
        // No necesitas hacer nada aquí para el estado, ya que _selectedService se mantendrá
      });

    if (posicion == 8)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PetFriendlyPage(),
        ),
      ).then((_) {
        // No necesitas hacer nada aquí para el estado, ya que _selectedService se mantendrá
      });
  }

  Widget _buildLostPetsSection() {
    return Container(
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mascotas Perdidas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          CarouselSlider(
            options: CarouselOptions(
              height: 120,
              viewportFraction: 0.8,
              enableInfiniteScroll: true,
              enlargeCenterPage: true,
            ),
            items: [
              _buildPetProfile(
                'https://i.pinimg.com/564x/a4/6f/e4/a46fe42ef60ffcb5dc81f5aa85f8857b.jpg',
                'Mascota 1',
                'Contacto 1',
                'Dirección 1',
              ),
              _buildPetProfile(
                'https://i.pinimg.com/564x/a0/98/6f/a0986f78adb3992618df7f24f0bc1256.jpg',
                'Mascota 2',
                'Contacto 2',
                'Dirección 2',
              ),
              _buildPetProfile(
                'https://i.pinimg.com/564x/15/cd/41/15cd41e224c2cb5321cd2db7d46c9c3a.jpg',
                'Mascota 3',
                'Contacto 3',
                'Dirección 3',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdoptablePetsSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.greenAccent),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mascotas en Adopción',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          CarouselSlider(
            options: CarouselOptions(
              height: 120,
              viewportFraction: 0.8,
              enableInfiniteScroll: true,
              enlargeCenterPage: true,
            ),
            items: [
              _buildPetProfile(
                'https://i.pinimg.com/564x/26/24/9a/26249a78777f6e3527d959ed4399dc1e.jpg',
                'Mascota 4',
                'Raza 4',
                'Refugio 4',
                onTap: () {
                  _showPetDetails(context, 'Mascota 4', 'Raza 4', 3,
                      'Refugio 4', 'Dirección 4');
                },
              ),
              _buildPetProfile(
                'https://i.pinimg.com/564x/d5/3f/f1/d53ff1e5e45113fe77a362b7086f4ea7.jpg',
                'Mascota 5',
                'Raza 5',
                'Refugio 5',
                onTap: () {
                  _showPetDetails(context, 'Mascota 5', 'Raza 5', 4,
                      'Refugio 5', 'Dirección 5');
                },
              ),
              _buildPetProfile(
                'https://i.pinimg.com/564x/3a/77/fe/3a77fee4a95ecacfe98146ea2c7a4c06.jpg',
                'Mascota 6',
                'Raza 6',
                'Refugio 6',
                onTap: () {
                  _showPetDetails(context, 'Mascota 6', 'Raza 6', 2,
                      'Refugio 6', 'Dirección 6');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPetProfile(
      String photoUrl, String name, String contact, String address,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.0),
        margin: EdgeInsets.symmetric(vertical: 4.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(photoUrl,
                  width: 80, height: 80, fit: BoxFit.cover),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  if (contact.isNotEmpty) Text('Contacto: $contact'),
                  if (address.isNotEmpty) Text('Dirección: $address'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPetDetails(BuildContext context, String name, String breed, int age,
      String shelterName, String address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Raza: $breed'),
            Text('Edad: $age años'),
            Text('Nombre del Refugio: $shelterName'),
            Text('Dirección: $address'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

class MisMascotasPage extends StatefulWidget {
  @override
  _MisMascotasPageState createState() => _MisMascotasPageState();
}

class _MisMascotasPageState extends State<MisMascotasPage> {
  Mascota? selectedMascota;
  File? _imageFile;
  String _resultText = '';
  double colorPerfilPorciento = 0.0;
  final Map<String, Color> mascotaColors = {};
  List<Activity> events = []; // Lista para almacenar los eventos
  bool isLoading = false; // Para manejar el estado de carga
  String? token;
  StompClient? stompClient;

  @override
  void initState() {
    super.initState();
    // Obtén el token de la sesión
    final session = Provider.of<SessionProvider>(context, listen: false);
    session.checkTokenValidity(context);
    token = session.token;
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
    // Subscribe to the topic that provides updates for the selected mascota
    stompClient?.subscribe(
      destination: '/topic/events',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          // Parse the incoming JSON data
          final List<dynamic> newEventsData = jsonDecode(frame.body!);

          // Convert the JSON into a list of Event objects
          List<Event> newEvents =
              newEventsData.map((json) => Event.fromJson(json)).toList();

          // Update the events list of the selected mascota
          setState(() {
            // Iterate over the new events
            // Iterate over the new events
            for (var newEvent in newEvents) {
              // Find the index of the event if it exists
              final existingEventIndex = selectedMascota?.eventos
                  ?.indexWhere((event) => event.id == newEvent.id);

              if (existingEventIndex != null && existingEventIndex != -1) {
                // If the event exists, replace it
                selectedMascota?.eventos?[existingEventIndex] = newEvent;
              } else {
                // If the event does not exist, add it
                selectedMascota?.eventos?.add(newEvent);
              }
            }
          });
        }
      },
    );
  }

  Future<List<Activity>> fetchEventsForMascota(
      String mascotaId, String token) async {
    final baseUrl = Config.get('api_base_url');
    try {
      final url =
          Uri.parse('$baseUrl/activity-mascota?id=$mascotaId&status=Aprobada');
      final response = await http.get(
        url,
        headers: {
          'Authorization':
              'Bearer ' + token, // Reemplaza 'tu_token_aqui' con tu token real
          'Content-Type':
              'application/json; charset=utf-8', // Ejemplo de otro encabezado opcional
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => Activity.fromJson(data)).toList();
      } else {
        throw Exception('Error al cargar los eventos');
      }
    } catch (Error) {
      print(Error.toString());
      throw Exception('Error al cargar los eventos');
    }
  }

  Future<List<Event>> _fetchMascotaEvents(String mascotaId) async {
    try {
      final baseUrl = Config.get('api_base_url');
      final session = Provider.of<SessionProvider>(context, listen: false);
      final url = '$baseUrl/events/$mascotaId';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ' + session.token!,
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> eventosJson = json.decode(response.body);
        return eventosJson.map((json) => Event.fromJson(json)).toList();
      }
      if (response.statusCode == 204) {
        return [];
      } else {
        throw Exception('Failed to load events');
      }
    } catch (Error) {
      print(Error.toString());
      throw Exception('Error al cargar los eventos');
    }
  }

  @override
  void dispose() {
    // Properly close the WebSocket connection when the widget is disposed
    stompClient?.deactivate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = Provider.of<SessionProvider>(context);
    final mascotas = session.user?.mascotas ?? [];
    final userLogin = session.user!;
    String? token = session.token;

    if (mascotas.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) =>
                  AddMascotaPage(user: userLogin, token: token)),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Mascotas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            if (isLoading)
              Center(
                child: CircularProgressIndicator(),
              ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: mascotas.map((mascota) {
                  final completionPercentage =
                      _calculateProfileCompletion(mascota);
                  final completionColor =
                      _calculateCompletionColor(completionPercentage);
                  final color = _getColorForMascota(mascota);
                  return GestureDetector(
                    onTap: () async {
                      setState(() {
                        selectedMascota = mascota;
                        isLoading = true;
                      });

                      try {
                        final newEvents =
                            await _fetchMascotaEvents(mascota.mascotaid);

                        setState(() {
                          // Validar si el evento ya existe en la lista de eventos de la mascota
                          for (var newEvent in newEvents) {
                            final exists = mascota.eventos?.any(
                                    (existingEvent) =>
                                        existingEvent.actividadId ==
                                        newEvent.actividadId) ??
                                false;

                            // Si el evento no existe, agregarlo a la lista
                            if (!exists) {
                              mascota.eventos?.add(newEvent);
                            }
                          }
                          isLoading = false;
                        });
                      } catch (e) {
                        setState(() {
                          isLoading = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Error al cargar eventos: $e')),
                        );
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.all(8.0),
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: selectedMascota == mascota
                            ? color.withOpacity(0.5)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: CircularProgressIndicator(
                                      value: completionPercentage,
                                      strokeWidth: 5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          completionColor),
                                    ),
                                  ),
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundImage: Utiles.buildImageBase64(
                                        mascota.fotos, mascota.especie),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                mascota.nombre,
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: EdgeInsets.all(4.0),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${mascota.eventos?.where((evento) => !evento.leido).length ?? 0}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 20),

            // Verificación de si hay eventos antes de mostrar el contenedor
            if (selectedMascota != null &&
                selectedMascota!.eventos!
                    .where((evento) => !evento.leido)
                    .isNotEmpty)
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: selectedMascota!.eventos!
                      .where((evento) => !evento.leido)
                      .map((evento) {
                    final now = DateTime.now();
                    final fechaEvento =
                        DateTime.parse(evento.fecha + " " + evento.startTime);
                    final diferencia = fechaEvento.difference(now);

                    Color color;
                    IconData icon;
                    if (evento.isCompleted) {
                      color = Colors.green;
                      icon = Icons.check_circle;
                    } else if (diferencia.inDays == 0) {
                      color = Colors.red;
                      icon = Icons.warning;
                    } else if (diferencia.inDays < 7) {
                      color = Colors.yellow;
                      icon = Icons.warning_amber;
                    } else {
                      color = Colors.grey;
                      icon = Icons.info;
                    }

                    return Dismissible(
                      key: Key(evento.id.toString()),
                      direction: DismissDirection.horizontal,
                      onDismissed: (direction) async {
                        // Perform the asynchronous work first
                        evento.leido = true;
                        await updateEventsPet(evento, selectedMascota!);

                        // Then update the UI synchronously
                        setState(() {
                          // No need to update `evento.leido` here, as it's already updated
                        });

                        // Show the Snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Evento "${evento.title}" marcado como leído')),
                        );
                      },
                      background: Container(
                        color: Colors.green,
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Icon(Icons.done, color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          if (evento.isCompleted) {
                            await _showEventRatingDialog(context, evento);
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 8),
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(color: color, width: 2),
                          ),
                          child: Row(
                            children: [
                              Icon(icon, color: color),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      evento.title,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Fecha y hora: ${evento.startTime}',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            SizedBox(height: 20),
            // Contenedor para los botones de vacunas, desparasitaciones y cargar cartilla
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                    child: _buildActionButton(
                  icon: FontAwesomeIcons.syringe,
                  label: 'Ver Vacunas',
                  color: selectedMascota != null
                      ? _getColorForMascota(selectedMascota!)
                      : Colors.grey,
                  onTap: selectedMascota != null
                      ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) =>
                                    VaccinationPage(mascota: selectedMascota!)),
                          );
                        }
                      : null,
                )),
                Expanded(
                    child: _buildActionButton(
                  icon: FontAwesomeIcons.clinicMedical,
                  label: 'Ver Desparasi',
                  color: selectedMascota != null
                      ? _getColorForMascota(selectedMascota!)
                      : Colors.grey,
                  onTap: selectedMascota != null
                      ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) =>
                                    VaccinationPage(mascota: selectedMascota!)),
                          );
                        }
                      : null,
                )),
              ],
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                // Lógica para el nuevo botón
              },
              child: Container(
                padding: EdgeInsets.all(8),
                margin: EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: selectedMascota != null
                      ? _calculateCompletionColor(
                          _calculateProfileCompletion(selectedMascota!))
                      : Colors
                          .grey, // Usar el color calculado o gris si no hay mascota seleccionada
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add,
                        color:
                            Colors.white), // Cambiar el icono según necesites
                    SizedBox(width: 8),
                    Text(
                      'Completar Perfil', // Cambiar el texto según necesites
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: FontAwesomeIcons.weight,
                  label: 'Agregar Peso',
                  color: selectedMascota != null
                      ? _getColorForMascota(selectedMascota!)
                      : Colors.grey,
                  onTap: selectedMascota != null
                      ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) =>
                                    PesoPage(mascota: selectedMascota!)),
                          );
                        }
                      : null,
                ),
                _buildActionButton(
                  icon: FontAwesomeIcons.paw,
                  label: 'Amigo Perruno',
                  color: selectedMascota != null
                      ? _getColorForMascota(selectedMascota!)
                      : Colors.grey,
                  onTap: selectedMascota != null
                      ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => AmigosPerrunosPage(
                                    mascota: selectedMascota!)),
                          );
                        }
                      : null,
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: FontAwesomeIcons.search,
                  label: 'Buscar Evento',
                  color: selectedMascota != null
                      ? _getColorForMascota(selectedMascota!)
                      : Colors.grey,
                  onTap: selectedMascota != null
                      ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => NearbyBusinessesPage(
                                    mascota: selectedMascota!)),
                          );
                        }
                      : null,
                ),
                _buildActionButton(
                  icon: FontAwesomeIcons.file,
                  label: 'Carne',
                  color: selectedMascota != null &&
                          selectedMascota!.microchip != null
                      ? _getColorForMascota(selectedMascota!)
                      : Colors.grey,
                  onTap: selectedMascota != null &&
                          selectedMascota!.microchip != ""
                      ? () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => CertificatePage(
                              mascota: selectedMascota!,
                              user: session.user!, // Pass the logged-in user
                            ),
                          ));
                        }
                      : null, // Deshabilitar el onTap si no se cumple la condición
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: FontAwesomeIcons.microchip,
                  label: 'Escanear Chip',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScanChipScreen(),
                      ),
                    );
                  },
                ),

                //Aqui va el otro boton
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateEventsPet(Event event, Mascota selectedMascota) async {
    final baseUrl = Config.get('api_base_url');
    final session = Provider.of<SessionProvider>(context, listen: false);
    final url = '$baseUrl/event-update'; // URL para eliminar fotos

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ' + session.token!,
        'mascotaId': selectedMascota.mascotaid,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id': event.id,
        'title': event.title,
        'descripcion': event.description,
        'fecha': event.fecha,
        'startTime': event.startTime,
        'endTime': event.endTime,
        'completed': event.isCompleted,
        'leido': event.leido,
        'actividadid': event.actividadId
      }),
    );

    if (response.statusCode == 200) {
      print('Foto eliminada con éxito.');
    } else {
      print('Error al eliminar la foto: ${response.body}');
    }
  }

  Future<void> _showEventRatingDialog(
      BuildContext context, Event evento) async {
    if (evento.isCompleted) {
      final _ratingController = TextEditingController();
      int _rating = 0;
      final session = Provider.of<SessionProvider>(context, listen: false);
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Evaluar Evento'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Descripción: ${evento.description}'),
                SizedBox(height: 8),
                Text('Fecha y hora: ${evento.fecha} ${evento.startTime}'),
                SizedBox(height: 16),
                // Calificación con estrellas
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < _rating ? Icons.star : Icons.star_border,
                        color: Colors.yellow,
                      ),
                      onPressed: () {
                        setState(() {
                          _rating = index + 1;
                        });
                      },
                    );
                  }),
                ),
                SizedBox(height: 16),
                // Campo para comentario
                TextField(
                  controller: _ratingController,
                  decoration: InputDecoration(
                    labelText: 'Comentario',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  // Guardar la calificación y comentario
                  final comentario = _ratingController.text;
                  final calificacion = _rating;

                  // Crear una instancia de Review
                  final review = Review(
                    id: Utiles.getId(), // Genera un ID único para la reseña
                    user: session.user!,
                    actividadid: evento.actividadId,
                    comment: comentario,
                    rating: calificacion,
                    timestamp: DateTime.now(),
                    likes: 0,
                    responses: [],
                  );

                  // Aquí puedes llamar a la API para guardar la calificación y comentario
                  // por ejemplo, usando la función `saveReview` (ver más abajo)

                  await _saveReview(evento.actividadId, review);

                  // Marcar evento como leído
                  evento.leido = true;
                  Navigator.of(context).pop();
                },
                child: Text('Enviar Calificación'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancelar'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _saveReview(String actividadId, Review review) async {
    // Aquí debes implementar la lógica para llamar a tu API y guardar la calificación
    // Por ejemplo, usando http:
    final session = Provider.of<SessionProvider>(context, listen: false);

    final baseUrl = Config.get('api_base_url');
    String? token = session.token;

    final response = await http.post(
      Uri.parse('$baseUrl/api/comments/comment/new'),
      headers: {
        'Authorization': 'Bearer ' + token!,
        'Content-Type': 'application/json'
      },
      body: jsonEncode(review.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save review');
    }
  }

  void _showLostPetModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(FontAwesomeIcons.exclamationTriangle, color: Colors.red),
              SizedBox(width: 10),
              Text('Advertencia'),
            ],
          ),
          content: Text('¿Su mascota se ha perdido?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar modal al cancelar
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                // Acción al confirmar
                Navigator.of(context).pop();
                // Aquí puedes agregar la lógica adicional al confirmar
              },
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(8),
          margin: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: onTap != null ? color : Colors.grey,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorForMascota(Mascota mascota) {
    // Si ya se ha asignado un color a la mascota, usarlo
    if (mascotaColors.containsKey(mascota.mascotaid)) {
      return mascotaColors[mascota.mascotaid]!;
    }

    // Asignar un nuevo color aleatorio a la mascota
    final color =
        Colors.primaries[mascotaColors.length % Colors.primaries.length];
    mascotaColors[mascota.mascotaid] = color;
    return color;
  }
}

Color _calculateCompletionColor(double completionPercentage) {
  if (completionPercentage <= 0.2) {
    return Colors.red.shade900;
  } else if (completionPercentage <= 0.3) {
    return Colors.red.shade600;
  } else if (completionPercentage <= 0.4) {
    return Colors.red.shade500;
  } else if (completionPercentage <= 0.5) {
    return Colors.lightGreenAccent;
  } else if (completionPercentage < 0.6) {
    return Colors.lightGreen;
  } else if (completionPercentage <= 0.7) {
    return Colors.lightGreen;
  } else {
    return Colors.green;
  }
}

double _calculateProfileCompletion(Mascota mascota) {
  final attributes = [
    mascota.nombre,
    mascota.especie,
    mascota.raza,
    mascota.edad,
    mascota.genero,
    mascota.color,
    mascota.tamano,
    mascota.peso,
    mascota.personalidad,
    mascota.historialMedico,
    mascota.necesidadesEspeciales,
    mascota.comportamiento,
    mascota.fotos,
  ];
  final filledAttributes = attributes
      .where((attr) => attr != null && attr.toString().isNotEmpty)
      .length;
  return filledAttributes / attributes.length;
}

void _showVacunasDialog(BuildContext context, List<Vacunas> vacunas) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Lista de Vacunas'),
        content: SingleChildScrollView(
          child: Column(
            children: vacunas.map((vacuna) {
              return ListTile(
                title: Text(vacuna.nombreVacuna),
                subtitle: Text('Fecha: ${vacuna.fechaAdministracion}'),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cerrar'),
          ),
          TextButton(
            onPressed: () {
              _generatePDFVacunas(vacunas);
            },
            child: Text('Descargar PDF'),
          ),
        ],
      );
    },
  );
}

void _showDesparasitacionesDialog(
    BuildContext context, List<Desparasitaciones> desparasitaciones) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Lista de Desparasitaciones'),
        content: SingleChildScrollView(
          child: Column(
            children: desparasitaciones.map((desparasitacion) {
              return ListTile(
                title: Text(desparasitacion.nombreProducto),
                subtitle: Text('Fecha: ${desparasitacion.fechaAdministracion}'),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cerrar'),
          ),
          TextButton(
            onPressed: () {
              _generatePDFDespa(desparasitaciones);
            },
            child: Text('Descargar PDF'),
          ),
        ],
      );
    },
  );
}

void _generatePDFVacunas(List<Vacunas> vacunas) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Lista de Vacunas', style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 16),
            pw.Column(
              children: vacunas.map((vacuna) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Nombre: ${vacuna.nombreVacuna}'),
                    pw.Text('Fecha: ${vacuna.fechaAdministracion}'),
                    pw.SizedBox(height: 8),
                  ],
                );
              }).toList(),
            ),
          ],
        );
      },
    ),
  );
}

void _generatePDFDespa(List<Desparasitaciones> desparacitacion) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Lista de Vacunas', style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 16),
            pw.Column(
              children: desparacitacion.map((desparacitacion) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Nombre: ${desparacitacion.nombreProducto}'),
                    pw.Text('Fecha: ${desparacitacion.fechaAdministracion}'),
                    pw.SizedBox(height: 8),
                  ],
                );
              }).toList(),
            ),
          ],
        );
      },
    ),
  );

  final output = await getTemporaryDirectory();
  final file = File("${output.path}/desparacitaciones.pdf");
  await file.writeAsBytes(await pdf.save());

  // Usa el paquete 'printing' para mostrar la opción de imprimir o compartir el PDF
  /*await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );*/
}

void _showMascotaDetails(BuildContext context, Mascota mascota) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(mascota.nombre),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Especie: ${mascota.especie}'),
            Text('Raza: ${mascota.raza}'),
            Text('Edad: ${mascota.edad}'),
            Text('Género: ${mascota.genero}'),
            Text('Color: ${mascota.color}'),
            Text('Tamaño: ${mascota.tamano}'),
            //Text('Peso: ${mascota.peso} ${mascota.}'),
            Text('Personalidad: ${mascota.personalidad}'),
            Text('Historial Médico: ${mascota.historialMedico}'),
            Text('Necesidades Especiales: ${mascota.necesidadesEspeciales}'),
            Text('Comportamiento: ${mascota.comportamiento}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cerrar'),
          ),
        ],
      );
    },
  );
}

class NearbyBusinessesPage extends StatefulWidget {
  final Mascota mascota;

  NearbyBusinessesPage({required this.mascota});

  @override
  _NearbyBusinessesPageState createState() => _NearbyBusinessesPageState();
}

class _NearbyBusinessesPageState extends State<NearbyBusinessesPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Business> _businesses = [];
  bool _isLoading = false;

  Future<void> _fetchNearbyBusinesses() async {
    setState(() {
      _isLoading = true;
    });

    //Position position = await _determinePosition();
    String query = _searchController.text;

    final session = Provider.of<SessionProvider>(context, listen: false);
    final baseUrl = Config.get('api_base_url');
    String? token = session.token;

    var url = Uri.parse(
        '$baseUrl/api/businesses/list-businesses'); // Reemplaza con la URL de tu API

    // Agrega los parámetros a la URL
    final params = {'search': query};

    // Construye la URL con los parámetros
    final uri = Uri.http(url.authority, url.path, params);

    var response = await http.get(
      uri,
      headers: {
        'Authorization':
            'Bearer ' + token!, // Reemplaza 'tu_token_aqui' con tu token real
        'Content-Type':
            'application/json', // Ejemplo de otro encabezado opcional
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _businesses =
            (data as List).map((json) => Business.fromJson(json)).toList();
        _isLoading = false;
      });
    } else {
      _businesses = [];
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load businesses');
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  void _navigateToBusinessCalendar(
      User user, Mascota mascota, Business business) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CalendarPageBusiness(
            user: user, mascota: mascota, business: business),
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buscar Servicio para ' + widget.mascota.nombre),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _fetchNearbyBusinesses,
                  child: Icon(Icons.search),
                ),
              ],
            ),
            SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : Expanded(
                    child: ListView.builder(
                      itemCount: _businesses.length,
                      itemBuilder: (context, index) {
                        var business = _businesses[index];
                        var users = business.user;

                        return ListTile(
                          leading: Image.network(
                            business.logoUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Text(business.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(business.address),
                              _buildStarRating(business.rating),
                            ],
                          ),
                          onTap: () => _navigateToBusinessCalendar(
                              users!, widget.mascota, _businesses[index]),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class CalendarPageBusiness extends StatefulWidget {
  final User user;
  final Mascota mascota;
  final Business business;
  CalendarPageBusiness(
      {required this.user, required this.mascota, required this.business});

  @override
  BusinessCalendarPage createState() => BusinessCalendarPage();
}

class BusinessCalendarPage extends State<CalendarPageBusiness> {
  late Future<List<Activity>> _activitiesFuture;
  late Map<DateTime, List<Activity>> _events = {};
  late Set<int> _workableDays = {}; // Días de la semana habilitados
  late List<Calendariowork> _workingHours; // Horarios de trabajo
  DateTime _focusedDay = DateTime.now();
  //DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  bool _isLoading = false;
  late List<Calendarioday> _calendarDays; // Días de trabajo y horarios
  late List<ActivityBussines> _activityBussines;
  late StreamSubscription _sub;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _events = {};
    final session = Provider.of<SessionProvider>(context, listen: false);

    String? token = session.token;
    _fetchActivitiesAndInitializeCalendar(widget.user.userid, token!);
    _fetchActivitiesBusiness(widget.business.id, token);

    // Escuchar los enlaces entrantes
    _initUniLinks();
  }

  Future<void> _initUniLinks() async {
    // Inicializar escuchando los enlaces entrantes
    _sub = uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        // Manejar la URL entrante
        _handleIncomingLink(uri);
      }
    }, onError: (err) {
      // Manejar errores de enlace
    });
  }

  void _handleIncomingLink(Uri uri) {
    // Obtener el estado de la transacción de la URL
    final String path = uri.host;

    if (path.contains('success')) {
      //Actualizar el estado de la reserva y registrar los datos de la transaccion
      // Redirige a la página de éxito
      Utiles.showConfirmationDialog(
          context: context,
          title: 'Pago exitoso',
          content: 'Su pago quedo registrado.',
          onConfirm: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          });
    } else if (path.contains('failure')) {
      // Redirige a la página de fallo
      /* Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FailureScreen()),
          );*/
      Utiles.showErrorDialog(
          context: context,
          title: 'Error',
          content: "No se pudo procesar el pago.");
    } else if (path.contains('pending')) {
      // Redirige a la página de pendiente
      /*Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PendingScreen()),
          );*/
      Utiles.showErrorDialog(
          context: context,
          title: 'Error',
          content: "No se pudo procesar el pago.");
    }
  }

  Future<void> _fetchActivitiesAndInitializeCalendar(
      String userid, String token) async {
    try {
      // Obtén las actividades y datos de calendario de la API
      List<Activity> activities =
          await fetchActivities(userid, token); // Reemplaza con valores reales
      List<Calendarioday> calendarDays = await fetchCalendarDays(userid,
          token); // Implementa este método para obtener los días laborables
      // _workingHours = await fetchWorkingHours(); // Implementa este método para obtener los horarios de trabajo
      Map<DateTime, List<Activity>> groupedEvents = {};
      // Agrupa las actividades por fecha
      if (activities.isNotEmpty)
        groupedEvents = _groupActivitiesByDate(activities);

      // Obtén los días laborables
      _workableDays = _getWorkableDays(calendarDays);
      _calendarDays = calendarDays;

      setState(() {
        _events = groupedEvents;
      });
    } catch (e) {
      // Manejo de errores
      print('Error fetching activities: $e');
    }
  }

  Future<void> _fetchActivitiesBusiness(String negocioId, String token) async {
    final baseUrl = Config.get('api_base_url');
    final url = Uri.parse('$baseUrl/api/businesses/list-activity-businesses');
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=utf-8'
    };
    // Agrega los parámetros a la URL
    final params = {'negocioId': negocioId};

    // Construye la URL con los parámetros
    final uri = Uri.http(url.authority, url.path, params);
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      _activityBussines =
          data.map((item) => ActivityBussines.fromJson(item)).toList();
    } else if (response.statusCode == 204) {
      Utiles.showErrorDialogBoton(
          context: context,
          title: 'Notificación',
          content: 'El negocio seleccionado (' +
              widget.business.name +
              ') no tiene eventos registrados. Seleccione otro.',
          onConfirm: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ManagementPage()),
            );
          });
      throw Exception('Failed to load calendar days');
    } else {
      throw Exception('Failed to load calendar days');
    }
  }

  Future<List<Calendarioday>> fetchCalendarDays(
      String userId, String token) async {
    final baseUrl = Config.get('api_base_url');
    final url = Uri.parse('$baseUrl/calendario-word-user');
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=utf-8'
    };
    // Agrega los parámetros a la URL
    final params = {'userid': userId};

    // Construye la URL con los parámetros
    final uri = Uri.http(url.authority, url.path, params);
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((item) => Calendarioday.fromJson(item)).toList();
    } else if (response.statusCode == 204) {
      Utiles.showErrorDialogBoton(
          context: context,
          title: 'Notificación',
          content: 'No ha definido un calendario. Registre uno a continuación.',
          onConfirm: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ManagementPage()),
            );
          });
      throw Exception('Failed to load calendar days');
    } else {
      throw Exception('Failed to load calendar days');
    }
  }

  Future<void> _registrar(DateTime selectedDay, DateTime startTime,
      DateTime endTime, ActivityBussines evento) async {
    // if (_formKey.currentState!.validate()) {
    //   _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    final hour = TimeOfDay(hour: startTime.hour, minute: startTime.minute);
    final hourInicioString =
        '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final hourFinString =
        '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';

    final session = Provider.of<SessionProvider>(context, listen: false);
    String? token = session.token;
    User? user = widget.business.user;

    final reserva = Activity(
        actividadid: Utiles.getId(),
        mascota: widget.mascota,
        user: user,
        title: widget.business.name,
        description: "",
        startime: hourInicioString,
        endtime: hourFinString,
        precio: evento.precio,
        fecha: selectedDay.toIso8601String(),
        status: "Aprobada",
        turnos: 1);

    final baseUrl = Config.get('api_base_url');
    final url = Uri.parse('$baseUrl/add-evento'); // URL
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode(reserva.toJson()),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      /*  Utiles.showConfirmationDialog(
          context: context,
          title: 'Registro exitoso',
          content: 'Su evento: ' + widget.business.name + " en el " + widget.business.name,
          onConfirm: () async {
            Navigator.of(context).pop(); // Cierra el diálogo de confirmación
            List<Activity> activities = await fetchActivities(session.user!.userid, token!) ; // Reemplaza con valores reales
            Map<DateTime, List<Activity>> groupedEvents={};

            if(activities.isNotEmpty)
              groupedEvents = _groupActivitiesByDate(activities);

              _events = groupedEvents;
              _showTimeSelectionDialog(selectedDay, _calendarDays); // Actualiza el modal



          },
        );*/

      // Inicializa el servicio de Mercado Pago
      // final mercadoPagoService = MercadoPagoService('TEST-7014566769079605-072823-7dbc2512afe8a0bbd20ea29e348bd00b-448163743'); // Reemplaza con tu Access Token

      // Muestra un diálogo de confirmación
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Confirmar Reserva y Pago'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Actividad: ${evento.actividad}'),
                Text('Precio: ${evento.precio} UYU'),
                Text(
                    'Hora de inicio: ${TimeOfDay.fromDateTime(startTime).format(context)}'),
                Text(
                    'Hora de fin: ${TimeOfDay.fromDateTime(endTime).format(context)}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  // Abre la URL de pago en el navegador
                  final baseUrl = Config.get('api_mercado_pago');
                  final url = Uri.parse('$baseUrl/create_preference');
                  final preferenceResponse = await http.post(
                    url,
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'title': evento.actividad,
                      'quantity': 1,
                      'currency_id': 'UYU',
                      'unit_price': evento.precio,
                    }),
                  );

                  if (preferenceResponse.statusCode == 200) {
                    final preferenceId =
                        jsonDecode(preferenceResponse.body)['id'];

                    //final Uri mercadoPagoUrl = Uri.parse('https://flutter.dev');
                    final Uri mercadoPagoUrl = Uri.parse(
                      'https://www.mercadopago.com.uy/checkout/v1/redirect?preference-id=$preferenceId',
                    );
                    print('Attempting to launch URL: $mercadoPagoUrl');

                    if (await canLaunchUrl(mercadoPagoUrl)) {
                      print('Launching URL...');

                      await launchUrl(mercadoPagoUrl,
                          mode: LaunchMode.externalApplication);
                      // Después de que el usuario complete el pago y vuelva a la aplicación,
                      // puedes navegar a la pantalla de verificación del pago
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentConfirmationScreen(
                              preferenceId: preferenceId),
                        ),
                      );
                    } else {
                      print('Failed to launch URL.');

                      throw 'Could not launch $mercadoPagoUrl';
                    }
                  } else {
                    print('Failed to create preference');
                  }
                },
                child: Text('Pagar'),
              ),
            ],
          );
        },
      );
    } else {
      Utiles.showErrorDialog(
          context: context, title: 'Error', content: jsonDecode(response.body));
    }

    Future.delayed(
      Duration(seconds: 2),
      () {
        setState(() {
          _isLoading = false;
        });
        // Show success dialog
        // Aquí va la acción a ejecutar cuando se confirma
        print('Perfil registrado confirmado');
      },
    );

    // }
  }

  Set<int> _getWorkableDays(List<Calendarioday> days) {
    final workableDays = <int>{};
    for (var day in days) {
      if (day.check) {
        final dayOfWeek = _getDayOfWeekFromString(day.day);
        if (dayOfWeek != null) {
          workableDays.add(dayOfWeek);
        }
      }
    }
    return workableDays;
  }

  int? _getDayOfWeekFromString(String dayString) {
    switch (dayString.toLowerCase()) {
      case 'lun':
        return DateTime.monday;
      case 'mar':
        return DateTime.tuesday;
      case 'mie':
        return DateTime.wednesday;
      case 'jue':
        return DateTime.thursday;
      case 'vie':
        return DateTime.friday;
      case 'sab':
        return DateTime.saturday;
      case 'dom':
        return DateTime.sunday;
      default:
        return null;
    }
  }

  Map<DateTime, List<Activity>> _groupActivitiesByDate(
      List<Activity> activities) {
    Map<DateTime, List<Activity>> data = {};
    for (var activity in activities) {
      final date = DateTime.parse(activity
          .fecha); // Asegúrate de que `activity.date` esté en formato compatible
      if (data[activity.fecha] == null) data[date] = [];
      data[activity.fecha]!.add(activity);
    }
    return data;
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  List<Activity> _getEventsForDay(DateTime day) {
    return _events[_normalizeDate(day)] ?? [];
  }

  bool _isDayEnabled(DateTime day) {
    return _workableDays.contains(day.weekday);
  }

  Future<List<Activity>> fetchActivities(String userId, String token) async {
    final baseUrl = Config.get('api_base_url');
    final url =
        Uri.parse('$baseUrl/activity-estilista?id=$userId&status=Aprobada');
    final response = await http.get(
      url,
      headers: {
        'Authorization':
            'Bearer ' + token!, // Reemplaza 'tu_token_aqui' con tu token real
        'Content-Type':
            'application/json; charset=utf-8', // Ejemplo de otro encabezado opcional
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => Activity.fromJson(json)).toList();
    } else if (response.statusCode == 204) {
      Future<List<Activity>> _activitiesFuture = Future.value([]);
      return _activitiesFuture;
    } else {
      throw Exception('Failed to load activities');
    }
  }

  void _showTimeSelectionDialog(
      DateTime selectedDay, List<Calendarioday> calendarDays) async {
    try {
      final eventsForDay = _getEventsForDay(selectedDay);

      int hourInicio = 0;
      int minutoInicio = 0;
      int hourFin = 0;
      int minutoFin = 0;

      for (var day in calendarDays) {
        hourInicio = int.parse(day.calendario.startTime.split(":")[0]);
        minutoInicio =
            int.parse(day.calendario.startTime.split(":")[1].substring(0, 2));
        hourFin = int.parse(day.calendario.endTime.split(":")[0]);
        minutoFin =
            int.parse(day.calendario.endTime.split(":")[1].substring(0, 2));
        break;
      }

      final startTime = TimeOfDay(
        hour: hourInicio,
        minute: minutoInicio,
      );

      final endTime = TimeOfDay(
        hour: hourFin,
        minute: minutoFin,
      );

      final selectedStartTime = await showDialog<TimeOfDay>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
                'Seleccionar Horas para el ${selectedDay.toLocal().toShortDateString()}'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(24, (index) {
                  final hour = TimeOfDay(hour: index, minute: 0);
                  final hourString =
                      '${hour.hour.toString().padLeft(2, '0')}:${hour.minute.toString().padLeft(2, '0')}';

                  bool isWithinWorkingHours =
                      hour.hour >= startTime.hour && hour.hour < endTime.hour;
                  final isOccupied = eventsForDay
                      .any((event) => event.startime.startsWith(hourString));

                  if (!isWithinWorkingHours) return Container();

                  return ListTile(
                    title: Text(hourString),
                    trailing: isOccupied
                        ? Icon(Icons.lock, color: Colors.red)
                        : Icon(Icons.check, color: Colors.green),
                    onTap: () {
                      if (!isOccupied) {
                        // _selectTimeRange(selectedDay);
                        Navigator.pop(context, hour);
                      }
                    },
                  );
                }),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cerrar'),
              ),
            ],
          );
        },
      );
      if (selectedStartTime != null) {
        _selectTimeRange(selectedDay, selectedStartTime);
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('No se encontró un día de calendario coincidente')),
      );
    }
  }

  void _selectTimeRange(DateTime selectedDay, TimeOfDay startHour) async {
    ActivityBussines? selectedActivity;
    DateTime? selectedStartTime;
    DateTime? selectedEndTime;

    // Mostrar el diálogo para seleccionar la actividad
    selectedActivity = await showDialog<ActivityBussines>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Seleccionar Actividad'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return DropdownButton<ActivityBussines>(
                hint: Text("Seleccionar Actividad"),
                value: selectedActivity,
                onChanged: (ActivityBussines? newValue) {
                  setState(() {
                    selectedActivity = newValue;
                  });
                },
                items: _activityBussines.map((ActivityBussines activity) {
                  return DropdownMenuItem<ActivityBussines>(
                    value: activity,
                    child: Text(activity.actividad),
                  );
                }).toList(),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(selectedActivity);
              },
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (selectedActivity == null) {
      // No se seleccionó ninguna actividad
      return;
    }

    selectedStartTime = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
      startHour.hour,
      startHour.minute,
    );

    selectedEndTime =
        selectedStartTime.add(Duration(minutes: selectedActivity!.tiempo));

    bool isConflicting = _getEventsForDay(selectedDay).any((event) {
      final eventStartTime = DateTime(
        selectedDay.year,
        selectedDay.month,
        selectedDay.day,
        int.parse(event.startime.split(":")[0]),
        int.parse(event.startime.split(":")[1].substring(0, 2)),
      );
      return selectedStartTime!.isAtSameMomentAs(eventStartTime) ||
          selectedStartTime!.isBefore(eventStartTime) &&
              selectedEndTime!.isAfter(eventStartTime);
    });

    if (isConflicting) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'El intervalo seleccionado se superpone con una actividad existente')),
      );
      return;
    }

    // Mostrar el precio y habilitar el botón para confirmar
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmar Reserva'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Actividad: ${selectedActivity?.actividad}'),
              Text('Precio: ${selectedActivity?.precio}'),
              Text('Hora de inicio: ${startHour.format(context)}'),
              Text(
                  'Hora de fin: ${TimeOfDay.fromDateTime(selectedEndTime!).format(context)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _registrar(selectedDay, selectedStartTime!, selectedEndTime!,
                    selectedActivity!);
              },
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendario'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  calendarFormat: _calendarFormat,
                  onDaySelected: (selectedDay, focusedDay) {
                    if (_isDayEnabled(selectedDay)) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      _showTimeSelectionDialog(selectedDay,
                          _calendarDays); // Aquí se pasan ambos argumentos
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Este día no es laborable')),
                      );
                    }
                  },
                  eventLoader: _getEventsForDay,
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  enabledDayPredicate: _isDayEnabled,
                ),
                const SizedBox(height: 8.0),
                Expanded(
                  child: ListView.builder(
                    itemCount: _getEventsForDay(_selectedDay).length,
                    itemBuilder: (context, index) {
                      final activity = _getEventsForDay(_selectedDay)[index];
                      return ListTile(
                        leading: Image.asset("lib/assets/perro.png",
                            width: 50, height: 50),
                        title: Text(activity.title),
                        subtitle: Text('${activity.startime} '),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class PaymentConfirmationScreen extends StatefulWidget {
  final String preferenceId;

  PaymentConfirmationScreen({required this.preferenceId});

  @override
  _PaymentConfirmationScreenState createState() =>
      _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen> {
  late Future<Map<String, dynamic>> paymentStatus;

  @override
  void initState() {
    super.initState();
    paymentStatus = _getPaymentStatus(widget.preferenceId);
  }

  Future<Map<String, dynamic>> _getPaymentStatus(String preferenceId) async {
    // URL de tu backend para verificar el estado del pago usando el preferenceId
    final baseUrl = Config.get('api_mercado_pago');
    final paymentStatusUrl = Uri.parse('$baseUrl/payment-status/$preferenceId');
    //final Uri paymentStatusUrl = Uri.parse('http://localhost:3000/payment-status/$preferenceId');

    final response = await http.get(paymentStatusUrl);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load payment status');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirmación de Pago'),
      ),
      body: Center(
        child: FutureBuilder<Map<String, dynamic>>(
          future: paymentStatus,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text('No hay información de pago disponible.');
            } else {
              final paymentData = snapshot.data!;
              final status = paymentData['status'];

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Estado del Pago: $status'),
                  if (status == 'approved')
                    Icon(Icons.check_circle, color: Colors.green, size: 64.0),
                  if (status != 'approved')
                    Icon(Icons.error, color: Colors.red, size: 64.0),
                  Text('ID de Preferencia: ${widget.preferenceId}'),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

class TipsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Tips',
        style: TextStyle(fontSize: 24.0),
      ),
    );
  }
}

class ChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Chat',
        style: TextStyle(fontSize: 24.0),
      ),
    );
  }
}

class SubscriptionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Suscripciones'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Elige tu plan de suscripción:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  SubscriptionPlan(
                    color: Colors.green,
                    title: 'Básico',
                    price: '\$5.00',
                    features: [
                      'Acceso a contenido básico',
                      'Soporte limitado',
                      'Actualizaciones mensuales'
                    ],
                    onSubscribe: () {
                      // Implementar suscripción utilizando Mercado Pago
                      print('Suscribirse al plan Básico');
                    },
                  ),
                  SubscriptionPlan(
                    color: Colors.red,
                    title: 'Estándar',
                    price: '\$15.00',
                    features: [
                      'Acceso a contenido estándar',
                      'Soporte prioritario',
                      'Actualizaciones semanales'
                    ],
                    onSubscribe: () {
                      // Implementar suscripción utilizando Mercado Pago
                      print('Suscribirse al plan Estándar');
                    },
                  ),
                  SubscriptionPlan(
                    color: Colors.black,
                    title: 'Premium',
                    price: '\$30.00',
                    features: [
                      'Acceso a todo el contenido',
                      'Soporte 24/7',
                      'Actualizaciones diarias'
                    ],
                    onSubscribe: () {
                      // Implementar suscripción utilizando Mercado Pago
                      print('Suscribirse al plan Premium');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SubscriptionPlan extends StatelessWidget {
  final Color color;
  final String title;
  final String price;
  final List<String> features;
  final VoidCallback onSubscribe;

  const SubscriptionPlan({
    required this.color,
    required this.title,
    required this.price,
    required this.features,
    required this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              price,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            ...features.map((feature) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Icon(Icons.check, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                          child: Text(feature,
                              style: TextStyle(color: Colors.white))),
                    ],
                  ),
                )),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: onSubscribe,
              child: Text('Suscribirse'),
              style: ElevatedButton.styleFrom(
                foregroundColor: color,
                backgroundColor: Colors.white, // Color del texto del botón
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfileManagementPageState createState() => _ProfileManagementPageState();
}

class _ProfileManagementPageState extends State<ProfilePage> {
  final _picker = ImagePicker();
  File? _profileImage;
  bool _isEditing = false;

  // Controladores para las contraseñas
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    final session = Provider.of<SessionProvider>(context, listen: false);
    session.checkTokenValidity(context);
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      // Llama al método para actualizar la imagen en la base de datos
      await _updateProfileImage(pickedFile);
    }
  }

  Future<void> _updateProfileImage(XFile pickedFile) async {
    final session = Provider.of<SessionProvider>(context, listen: false);

    // Convert the image to base64
    final bytes = await pickedFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    // Call the API to update the image in the database
    final response = await http.post(
      Uri.parse('${Config.get('api_base_url')}/api/user/update-photo'),
      headers: {
        'Authorization': 'Bearer ${session.token!}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'photo': base64Image,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Foto de perfil actualizada exitosamente')),
      );
      // Update the photo in the session
      session.updateUserPhoto(base64Image);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar la foto de perfil')),
      );
    }
  }

  void _showImageSourceDialog() {
    final session = Provider.of<SessionProvider>(context, listen: false);

    // Check if the platform is "manual"
    if (session.user?.plataforma == 'manual') {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Select Profile Picture'),
            actions: [
              TextButton(
                onPressed: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
                child: Text('Take a Photo'),
              ),
              TextButton(
                onPressed: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
                child: Text('Choose from Gallery'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
            ],
          );
        },
      );
    } else {
      // Show a message if the platform is not "manual"
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'No se permite cambiar la foto de perfil en esta plataforma.')),
      );
    }
  }

  // Mostrar el modal para cambiar la contraseña
  void _showChangePasswordDialog() {
    final session = Provider.of<SessionProvider>(context, listen: false);

    // Check if the platform is "manual"
    if (session.user?.plataforma == 'manual') {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Cambiar Contraseña'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _currentPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Contraseña Actual',
                  ),
                ),
                TextField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Nueva Contraseña',
                  ),
                ),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirmar Nueva Contraseña',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: _changePassword,
                child: Text('Guardar'),
              ),
            ],
          );
        },
      );
    } else {
      // Show a message if the platform is not "manual"
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'No se permite cambiar la contraseña en esta plataforma.')),
      );
    }
  }

  // Lógica para cambiar la contraseña
  Future<void> _changePassword() async {
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }

    // Llamar a la API para cambiar la contraseña
    final session = Provider.of<SessionProvider>(context, listen: false);
    final response = await http.post(
      Uri.parse('${Config.get('api_base_url')}/api/user/change-password'),
      headers: {
        'Authorization': 'Bearer ${session.token!}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Contraseña cambiada exitosamente')),
      );
      Navigator.of(context).pop(); // Cerrar el diálogo
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cambiar la contraseña')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = Provider.of<SessionProvider>(context);
    final user = session.user; // Obtener el usuario logueado

    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.white,
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: user?.photo != null
                          ? MemoryImage(base64Decode(user!.photo))
                          : null,
                      child:
                          _profileImage == null && user?.plataforma == 'manual'
                              ? IconButton(
                                  icon: Icon(Icons.camera_alt),
                                  onPressed: _showImageSourceDialog,
                                )
                              : null,
                    ),
                    if (_profileImage == null &&
                        user?.photo == null &&
                        user?.plataforma == 'manual')
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: IconButton(
                          icon: Icon(Icons.camera_alt, color: Colors.white),
                          onPressed: _showImageSourceDialog,
                        ),
                      ),
                  ],
                ),
                Divider(height: 1, color: Colors.grey),
                // Opciones de perfil
                ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Editar Perfil'),
                  onTap: () {
                    Navigator.pushNamed(context, '/editProfile');
                  },
                ),
                ListTile(
                  title: Text('Suscripciones'),
                  leading: Icon(Icons.subscriptions, color: Colors.blue),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubscriptionPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.lock),
                  title: Text('Cambiar Contraseña'),
                  onTap: _showChangePasswordDialog,
                ),
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Cerrar Sesión'),
                  onTap: () {
                    // Eliminar la sesión y redirigir a la página de login
                    Provider.of<SessionProvider>(context, listen: false)
                        .logout(context);
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
