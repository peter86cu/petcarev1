import 'dart:convert';
import 'dart:io';

import 'package:PetCare/pages/solicitudes-activity_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/uuid.dart';

import '../class/ActividadEstilista.dart';
import '../class/CalendarioDay.dart';
import '../class/CalendarioWork.dart';
import '../class/Negocio.dart';
import '../class/SessionProvider.dart';
import '../class/User.dart';
import 'Config.dart';
import 'Utiles.dart';
import 'negocio_page.dart';
import 'package:fl_chart/fl_chart.dart';



class HomeEstilista extends StatefulWidget {

  //final String userId;
   final int role;

  const HomeEstilista({required this.role});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomeEstilista> {
  int _currentIndex = 0;
  late String _userId;
  late User _user;
  final int rol=0;

  final List<Widget> _children = [

  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = Provider.of<SessionProvider>(context, listen: false);
      session.checkTokenValidity(context);
      _userId = session.user!.userid; // Obtén el userId desde el SessionProvider
      _user= session.user!;
      _children.addAll([
        HomePageEstilista(),
        CalendarPage(user: _user), // Pasa el userId a CalendarPage
        ManagementPage(),
        //ChatPage(),
        ProfilePage()
      ]);
    });
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      if (_currentIndex == 1) {
        _children[1] = CalendarPage(user: _user);
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
       // title: Text('Bottom Navigation Bar Example'),
      ),
      body: _children.isNotEmpty ? _children[_currentIndex] : Center(child: CircularProgressIndicator()), // Manejo de lista vacía
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Gestión',
          ),
          /*if(widget.role==1)
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),*/
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        onTap: onTabTapped,
        unselectedItemColor: Colors.black,
        backgroundColor: Colors.blueGrey[900],
        elevation: 10,
      ),
    );


  }
}





class HomePageEstilista extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Estilista'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Tarjeta de estadísticas de ventas
              _buildSalesStatsCard(),
              SizedBox(height: 16),

              // Tarjeta de estadísticas de turnos
              _buildTurnStatsCard(),
              SizedBox(height: 16),

              // Gráfico de picos de reservas
              _buildReservationPeakGraph(),
              SizedBox(height: 16),

              // Gráfico de ganancias
              _buildEarningsGraph(),
              SizedBox(height: 16),

              // Gráfico de estadísticas de turnos por actividad
              _buildActivityTurnStatsGraph(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSalesStatsCard() {
    final int totalSales = 120;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estadísticas de Ventas Generadas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              '$totalSales ventas',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTurnStatsCard() {
    final int reservedTurns = 80;
    final int canceledTurns = 20;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Turnos por Horarios',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Reservados: $reservedTurns',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'Cancelados: $canceledTurns',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationPeakGraph() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pico de Reservas por Actividad',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 200, // Ajusta la altura según sea necesario
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        FlSpot(0, 5),
                        FlSpot(1, 7),
                        FlSpot(2, 3),
                        FlSpot(3, 8),
                        FlSpot(4, 5),
                        FlSpot(5, 10),
                      ],
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 4,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.3),
                      ),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsGraph() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total de Ganancias por Semana',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 200, // Ajusta la altura según sea necesario
              child: BarChart(
                BarChartData(
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [BarChartRodData(toY: 1500, color: Colors.green)],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [BarChartRodData(toY: 2000, color: Colors.green)],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [BarChartRodData(toY: 1800, color: Colors.green)],
                    ),
                    BarChartGroupData(
                      x: 3,
                      barRods: [BarChartRodData(toY: 2200, color: Colors.green)],
                    ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTurnStatsGraph() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estadísticas de Turnos por Actividad',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 200, // Ajusta la altura según sea necesario
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(value: 40, title: 'Corte', color: Colors.blue),
                    PieChartSectionData(value: 30, title: 'Color', color: Colors.orange),
                    PieChartSectionData(value: 20, title: 'Manicura', color: Colors.red),
                    PieChartSectionData(value: 10, title: 'Otros', color: Colors.green),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




class CalendarPage extends StatefulWidget {
  final User user;
  CalendarPage({required this.user});


  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late Future<List<Activity>> _activitiesFuture;
  late Map<DateTime, List<Activity>> _events={};
  late Set<int> _workableDays= {1, 2, 3, 4, 5}; // Días de la semana habilitados
  late List<Calendariowork> _workingHours; // Horarios de trabajo
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  //final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;



  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _events = {};
      final session = Provider.of<SessionProvider>(context, listen: false);
    session.checkTokenValidity(context);
      String? token =  session.token;
      _fetchActivitiesAndInitializeCalendar(session.user!.userid, token!);
    _initializeNotifications();

   // _firebaseMessaging.requestPermission();
   /* _firebaseMessaging.getToken().then((String? token) {
      assert(token != null);
      print("Token del dispositivo: $token");
      // Envía el token al servidor para enviar notificaciones al dispositivo
    });*/

   /* FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      if (notification != null) {
        _showNotification(notification.title ?? 'Notificación',
            notification.body ?? 'Tienes un nuevo mensaje');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notificación abierta con la app en segundo plano');
    });*/

  }

  void _initializeNotifications() {
    // Configuración de Android
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuración de iOS y macOS
    const DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings();

    // Configuración para ambas plataformas
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'update_channel_id', // ID del canal
      'Updates', // Nombre del canal
      channelDescription: 'Notificaciones generales de la aplicación',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Actualización disponible',
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
    DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0, // ID de notificación
      title,
      body,
      platformChannelSpecifics,
      payload: 'data', // Datos adicionales, si es necesario
    );
  }




  Future<void> _fetchActivitiesAndInitializeCalendar(String userid, String token) async {
    try {
      // Obtén las actividades y datos de calendario de la API
      List<Activity> activities = await fetchActivities(userid, token); // Reemplaza con valores reales
      List<Calendarioday> calendarDays = await fetchCalendarDays(userid, token); // Implementa este método para obtener los días laborables
     // _workingHours = await fetchWorkingHours(); // Implementa este método para obtener los horarios de trabajo
      Map<DateTime, List<Activity>> groupedEvents={};
      // Agrupa las actividades por fecha
      if(activities.isNotEmpty)
        groupedEvents = _groupActivitiesByDate(activities);

      // Obtén los días laborables
      _workableDays = _getWorkableDays(calendarDays);

      setState(() {
        _events = groupedEvents;
      });
    } catch (e) {
      // Manejo de errores
      print('Error fetching activities: $e');
    }
  }



  Future<List<Calendarioday>> fetchCalendarDays(String userId, String token) async {


    final baseUrl = Config.get('api_base_url');
    final url = Uri.parse('$baseUrl/api/parameters/calendario-word-user');
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=utf-8'
    };
    // Agrega los parámetros a la URL
    final params = {
      'userid': userId
    };

    // Construye la URL con los parámetros
    final uri = Uri.http(url.authority, url.path, params);
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((item) => Calendarioday.fromJson(item)).toList();


    }else if (response.statusCode == 204) {
      Utiles.showErrorDialogBoton(context:context, title:'Notificación', content:'No ha definido un calendario. Registre uno a continuación.',onConfirm: () {
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

  Map<DateTime, List<Activity>> _groupActivitiesByDate(List<Activity> activities) {
    Map<DateTime, List<Activity>> data = {};
    for (var activity in activities) {
      final date = DateTime.parse(activity.fecha); // Asegúrate de que `activity.date` esté en formato compatible
      if (data[activity.fecha] == null) data[date] = [];
      data[date]!.add(activity);
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
    final url = Uri.parse('$baseUrl/activity-estilista?id=$userId&status=All');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer '+token, // Reemplaza 'tu_token_aqui' con tu token real
      'Content-Type': 'application/json; charset=utf-8', // Ejemplo de otro encabezado opcional
    },);

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => Activity.fromJson(json)).toList();
    }else if (response.statusCode == 204) {
      Future<List<Activity>> _activitiesFuture = Future.value([]);
      return  _activitiesFuture;
    } else {
      throw Exception('Failed to load activities');
    }
  }




  void _showActivityDetailModal(Activity activity) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(activity.mascota.nombre),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Descripción: ${activity.title}'),
              Text('Inicio: ${activity.startime}'),
              Text('Fin: ${activity.endtime}'),
              Text('Estado: ${activity.status}'),
            ],
          ),
          actions: activity.status != 'Terminado'
              ? [
            TextButton(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Actualizar Evento'),
              onPressed: () {
                Navigator.of(context).pop();
                _showUpdateEventModal(activity);
              },
            ),
          ]
              : [],
        );
      },
    );
  }



  void _showUpdateEventModal(Activity activity) {
    final TextEditingController noteController = TextEditingController(text: activity.note);
    String? selectedStatus = activity.status; // Inicializar con el estado actual

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Actualizar Evento'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: noteController,
                    decoration: InputDecoration(
                      labelText: 'Nota',
                    ),
                  ),
                  SizedBox(height: 16),
                  DropdownButton<String>(
                    value: selectedStatus,
                    hint: Text('Estado'),
                    items: [
                      DropdownMenuItem(value: 'Aprobada', child: Text('Aprobada')),
                      DropdownMenuItem(value: 'Confirmada', child: Text('Confirmada')),
                      DropdownMenuItem(value: 'Procesando', child: Text('Procesando')),
                      DropdownMenuItem(value: 'Terminado', child: Text('Terminado')),
                      DropdownMenuItem(value: 'Desechado', child: Text('Desechado')),
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedStatus = newValue;
                      });
                    },
                    isExpanded: true, // Asegura que el DropdownButton ocupe todo el espacio horizontal disponible
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              child: Text('Enviar'),
              onPressed: () {
                if (selectedStatus != null) {
                  // Crear una copia de la actividad para actualizarla
                  final updatedActivity = activity.copyWith(
                    note: noteController.text,
                    status: selectedStatus!,
                  );
                  _updateActivityInDatabase(updatedActivity); // Método para actualizar la base de datos
                  Navigator.of(context).pop();
                } else {
                  // Mostrar mensaje de error si no se seleccionó un estado
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Por favor, selecciona un estado.')),
                  );
                }
              },
            ),
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }




  Future<void> _updateActivityInDatabase(Activity activity) async {
    // Aquí va la lógica para actualizar la actividad en tu base de datos
    try {
      // Ejemplo con un API REST usando HTTP package
      final baseUrl = Config.get('api_base_url');
      final url = Uri.parse('$baseUrl/add-evento'); // Asegúrate de que esta sea la URL correcta
      final session = Provider.of<SessionProvider>(context, listen: false);
      final token = session.token;


      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: jsonEncode(activity),
      );


      if (response.statusCode == 200) {
        // Actualización exitosa
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Evento actualizado exitosamente.')),
        );
      } else {
        // Error en la actualización
        throw Exception('Error al actualizar el evento');
      }
    } catch (e) {
      // Manejo de errores
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar el evento: $e')),
      );
    }
  }

  void _showAddActivityModal() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Agregar Nueva Actividad', style: Theme.of(context).textTheme.titleMedium),
              TextField(
                decoration: InputDecoration(labelText: 'Título'),
                // Aquí puedes almacenar el valor en una variable o en un controlador
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Descripción'),
                // Aquí puedes almacenar el valor en una variable o en un controlador
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Guardar'),
                onPressed: () {
                  // Aquí deberías guardar la nueva actividad y actualizar el estado
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
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
      body: _events == null // Verificar si _events es null
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
                // _showActivityDetails(_getEventsForDay(selectedDay));
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
            child: _getEventsForDay(_selectedDay ?? _focusedDay).isEmpty // Verifica si la lista de eventos está vacía
                ? Center(child: Text('No hay eventos para este día.')) // Mensaje si no hay eventos
                : ListView.builder(
              itemCount: _getEventsForDay(_selectedDay ?? _focusedDay).length,
              itemBuilder: (context, index) {
                final activity = _getEventsForDay(_selectedDay ?? _focusedDay)[index];
                // Definir el color de fondo según el estado de la actividad
                Color backgroundColor;
                switch (activity.status) {
                  case 'Terminado':
                    backgroundColor = Colors.green.shade100; // Verde claro
                    break;
                  case 'Confirmada':
                    backgroundColor = Colors.blue.shade100; // Azul claro
                    break;
                  case 'Desechado':
                    backgroundColor = Colors.red.shade100; // Rojo claro
                    break;
                  default:
                    backgroundColor = Colors.yellow.shade100; // Amarillo claro para otros estados
                    break;
                }

                return Container(
                  color: backgroundColor, // Asignar el color de fondo
                  child: ListTile(
                    leading: Image(
                      image: Utiles.buildImageBase64(activity.mascota.fotos, activity.mascota.especie),
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${activity.mascota.nombre}\n', // Nombre de la mascota seguido de un salto de línea
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: activity.description, // Descripción de la actividad
                          ),
                        ],
                      ),
                    ),
                    subtitle: Text('${activity.startime} - ${activity.endtime}'),
                    onTap: () => _showActivityDetailModal(activity),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _showAddActivityModal,
      ),
    );
  }

  }





class AddActivityModal extends StatefulWidget {
  final Function(Activity) addActivity;

  AddActivityModal({required this.addActivity});

  @override
  _AddActivityModalState createState() => _AddActivityModalState();
}

class _AddActivityModalState extends State<AddActivityModal> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  String _time = '';
  String _image = 'lib/assets/default.jpg';

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      /*widget.addActivity(
        Activity(
          title: _title,
          description: _description,
          time: _time,
          image: _image,
        ),
      );*/
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Agregar Actividad'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Título'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor ingrese un título.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Descripción'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor ingrese una descripción.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _description = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Hora'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor ingrese la hora.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _time = value!;
                },
              ),
              // Agregar más campos según sea necesario
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: Text('Cancelar'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: Text('Guardar'),
          onPressed: _submit,
        ),
      ],
    );
  }
}

class ManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Página de Gestión'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.calendar_today),
              label: Text('Gestionar Calendario'),
              onPressed: () => _showCalendarManagementDialog(context),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.business),
              label: Text('Gestionar Actividades'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ActivityManagementPage()),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.assignment),
              label: Text('Gestionar Solicitudes'),
              onPressed: () {
                // Navegar a la página de gestión de solicitudes
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SolicitudesPage()),
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.business),
              label: Text('      Negocio                  '),
              onPressed: () {
                // Navegar a la página de gestión de solicitudes
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterBusinessPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  void _showCalendarManagementDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CalendarManagementDialog();
      },
    );
  }


}


class CalendarManagementDialog extends StatefulWidget {
  @override
  _CalendarManagementDialogState createState() => _CalendarManagementDialogState();
}

class _CalendarManagementDialogState extends State<CalendarManagementDialog> {
  List<bool> _selectedDays = List<bool>.generate(7, (index) => false);
  TimeOfDay _startTime = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = TimeOfDay(hour: 17, minute: 0);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Configurar Días Laborales y Horarios'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(7, (index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(_dayLabel(index)),
                    selected: _selectedDays[index],
                    onSelected: (selected) {
                      setState(() {
                        _selectedDays[index] = selected;
                      });
                    },
                  ),
                );
              }),
            ),
          ),
          SizedBox(height: 20),
          _buildTimePickerRow('Hora de inicio', _startTime, true),
          SizedBox(height: 10),
          _buildTimePickerRow('Hora de fin', _endTime, false),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            _saveWorkSchedule();
            Navigator.pop(context);
          },
          child: Text('Guardar'),
        ),
      ],
    );
  }

  Widget _buildTimePickerRow(String label, TimeOfDay time, bool isStartTime) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text('$label: ${time.format(context)}'),
        ),
        ElevatedButton(
          onPressed: () => _selectTime(context, isStartTime),
          child: Text('Seleccionar'),
        ),
      ],
    );
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _saveWorkSchedule() async {
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    final Uuid uuid = Uuid();
    String? token = sessionProvider.token;
    final url = Uri.parse('http://192.168.0.154:8080/workSchedule');

    final calendario = Calendariowork(
      id: uuid.v4(),
      user: sessionProvider.user!,
      startTime: _startTime.format(context),
      endTime: _endTime.format(context),
    );

    int pos = 0;
    for (var activityJson in _selectedDays) {
      String days = _dayLabel(pos);

      final day = Calendarioday(
        dayid: uuid.v4(),
        calendario: calendario,
        day: days,
        check: activityJson,
      );

      final response = await http.post(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer ' + token!,
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(day),
      );
      pos++;

      if (pos == 7) {
        if (response.statusCode == 200) {
          print('Configuración guardada correctamente');
        } else {
          print('Error al guardar la configuración');
        }
      }
    }
  }

  String _dayLabel(int index) {
    const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return days[index];
  }
}



class ActivityManagementPage extends StatefulWidget {
  @override
  _ActivityManagementPageState createState() => _ActivityManagementPageState();
}

class _ActivityManagementPageState extends State<ActivityManagementPage> {
  String _selectedActivity = '';
  String _selectedActivityId = '';
  List<Map<String, dynamic>> _activities = [];
  List<Map<String, dynamic>> _filteredActivities = [];
  TextEditingController _activityController = TextEditingController();

  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _availableSlotsController = TextEditingController();
  bool _isAvailable = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final session = Provider.of<SessionProvider>(context, listen: false);

    session.checkTokenValidity(context);
    _fetchActivities();
  }

  Future<void> _fetchActivities() async {
    final baseUrl = Config.get('api_base_url');
    final url = Uri.parse('$baseUrl/api/parameters/activities'); // Reemplaza con tu URL de API
    //final response = await http.get(url);
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);

    var response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${sessionProvider.token}', // Reemplaza 'tu_token_aqui' con tu token real
        'Content-Type': 'application/json', // Ejemplo de otro encabezado opcional
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      setState(() {
        _activities = data.map((item) {
          return {
            'id': item['id'],
            'actividad': item['actividad'],
            'status': item['status']
          };
        }).toList();
        _filteredActivities = _activities; // Inicialmente, los elementos filtrados son todos los elementos
      });
    } else {
      // Manejo de error
      print('Error al obtener actividades');
    }
  }

  Future<Business?> getBusinessByUserId(String userId, String token) async {
    final baseUrl = Config.get('api_base_url');
    final url = Uri.parse('$baseUrl/api/business/$userId'); // Reemplaza con tu URL de API

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return Business.fromJson(json);
      } else {
        print('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }

  Future<void> _saveActivity() async {
    setState(() {
      _isLoading = true;
    });


    try {
      final baseUrl = Config.get('api_base_url');

      final url = Uri.parse('$baseUrl/api/businesses/add-activity-businesses'); // Reemplaza con tu URL de API
      final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
      //final business = await getBusinessByUserId(sessionProvider.user!.userid, sessionProvider.token!);

      final activityData = {
        'id': Utiles.getId(),
        'negocio': Business(id: '', name: 'name', phone: 'phone', createdAt: DateTime.now(), longitud: 'longitud', latitud: 'latitud', address: 'address', logoUrl: 'logoUrl', rating: 0, services: [], reviewCount: 0),
        'actividad': _selectedActivityId,
        'descripcion': _descriptionController.text,
        'tiempo': _timeController.text,
        'precio': _priceController.text,
        'turnos': int.tryParse(_availableSlotsController.text) ?? 1,
        'status': _isAvailable
      };

      final response = await http.post(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer ${sessionProvider.token}',
          'userId': sessionProvider.user!.userid,
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(activityData),
      );

      if (response.statusCode == 200) {
        // Manejo de éxito
        Utiles.showConfirmationDialog(context:context, title:'Registro exitoso', content:'Actividad registrada.',onConfirm: () {
          // Limpiar los campos si es necesario
          setState(() {
            _selectedActivity = '';
            _descriptionController.clear();
            _timeController.clear();
            _priceController.clear();
            _availableSlotsController.clear();
            _isAvailable = true;
          });
        });


      } else {
        Utiles.showErrorDialog(context:context, title:'Error', content: jsonDecode(response.body) );

      }
    } catch (e) {
      print('Exception: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestionar Actividades'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Autocomplete<Map<String, dynamic>>(
              optionsBuilder: (TextEditingValue value) {
                if (value.text.isEmpty) {
                  return const Iterable<Map<String, dynamic>>.empty();
                }
                return _filteredActivities.where((activity) {
                  return activity['actividad']
                      .toLowerCase()
                      .contains(value.text.toLowerCase());
                });
              },
              displayStringForOption: (Map<String, dynamic> option) => option['actividad'],
              onSelected: (Map<String, dynamic> selection) {
                setState(() {
                  _selectedActivityId = selection['actividad'];
                });
              },
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  onFieldSubmitted: (value) => onFieldSubmitted(),
                  decoration: InputDecoration(
                    labelText: 'Buscar y Seleccionar Actividad',
                    border: OutlineInputBorder(),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _timeController,
              decoration: InputDecoration(
                labelText: 'Tiempo',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'Precio',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _availableSlotsController,
              decoration: InputDecoration(
                labelText: 'Turnos Disponibles por Hora',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            SwitchListTile(
              title: Text('Disponible'),
              value: _isAvailable,
              onChanged: (bool value) {
                setState(() {
                  _isAvailable = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveActivity,
              child: _isLoading
                  ? CircularProgressIndicator(
                color: Colors.white,
              )
                  : Text('Guardar'),
            ),
          ],
        ),
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

class ProfilePage extends StatefulWidget   {
  @override
  _ProfileManagementPageState createState() => _ProfileManagementPageState();
}

  class _ProfileManagementPageState extends State<ProfilePage> {

  final _picker = ImagePicker();
  File? _profileImage;
  bool _isEditing = false; // Add this line to manage the editing state

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _showImageSourceDialog() {
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
  }


  @override
  Widget build(BuildContext context) {
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
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : null,
                child: _profileImage == null
                    ? IconButton(
                  icon: Icon(Icons.camera_alt),
                  onPressed: _showImageSourceDialog,
                )
                    : null,
              ),
              if (_profileImage == null)
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
              Navigator.pushNamed(context, '/editProfile'); // Cambia esto a la ruta de tu página de edición de perfil
            },
          ),
          ListTile(
            leading: Icon(Icons.lock),
            title: Text('Cambiar Contraseña'),
            onTap: () {
              Navigator.pushNamed(context, '/changePassword'); // Cambia esto a la ruta de tu página de cambio de contraseña
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Cerrar Sesión'),
            onTap: () {
              // Eliminar la sesión y redirigir a la página de login
              Provider.of<SessionProvider>(context, listen: false).logout(context);
              Navigator.pushReplacementNamed(context, '/login'); // Cambia esto a la ruta de tu página de login
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

