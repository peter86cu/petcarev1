import 'package:PetCare/pages/reviews_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

import '../class/ActividadEstilista.dart';
import '../class/ActividadNegocio.dart';
import '../class/Mascota.dart';
import '../class/Negocio.dart';
import '../class/SessionProvider.dart';
import '../class/User.dart';
import 'Config.dart';
import 'Utiles.dart';
import 'calendario_page.dart';
import 'home_propietario.dart';

class BusinessListScreen extends StatefulWidget {
  final String serviceName;
  //final BuildContext context;

  const BusinessListScreen({
    required this.serviceName,
  });

  @override
  _BusinessListScreenT createState() => _BusinessListScreenT();
}

class _BusinessListScreenT extends State<BusinessListScreen> {
  @override
  void initState() {
    super.initState();
    final session = Provider.of<SessionProvider>(context, listen: false);
    session.checkTokenValidity(context);
  }

  Future<List<Business>> fetchBusinesses() async {
    final session = Provider.of<SessionProvider>(context, listen: false);
    final baseUrl = Config.get('api_base_url');
    String? token = session.token;

    var url = Uri.parse('$baseUrl/api/businesses/list-businesses');

    final params = {'search': widget.serviceName};

    final uri = Uri.http(url.authority, url.path, params);

    var response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer ' + token!,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((item) => Business.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load businesses');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.pets),
            SizedBox(width: 10),
            Text(widget.serviceName),
          ],
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.grey[200],
        child: FutureBuilder<List<Business>>(
          future: fetchBusinesses(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final businesses = snapshot.data!;
              final uniqueBusinesses = <String, Business>{};

              for (var business in businesses) {
                uniqueBusinesses[business.name] = business;
              }

              final filteredBusinesses = uniqueBusinesses.values.toList();

              filteredBusinesses.sort((a, b) => b.rating.compareTo(a.rating));

              return ListView.builder(
                padding: EdgeInsets.all(8.0),
                itemCount: filteredBusinesses.length,
                itemBuilder: (context, index) {
                  final business = filteredBusinesses[index];
                  return GestureDetector(
                    onTap: () => _navigateToBusinessDetails(
                        context, business, widget.serviceName),
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipOval(
                            child: Image.network(
                              business.logoUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  business.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(business.address),
                                SizedBox(height: 8),
                                Row(
                                  children: List.generate(5, (starIndex) {
                                    return Icon(
                                      starIndex < business.rating
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: Colors.amber,
                                      size: 16,
                                    );
                                  }),
                                ),
                                SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () =>
                                      _navigateToReviews(context, business),
                                  child: Text(
                                    '${business.reviewCount} Comentarios',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  void _navigateToBusinessDetails(
      BuildContext context, Business business, String serviceName) {
    final session = Provider.of<SessionProvider>(context, listen: false);
    User user = session.user!;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BusinessDetailsScreen(
          business: business,
          selectedServiceType: serviceName,
          user: user,
        ),
      ),
    );
  }

  void _navigateToReviews(BuildContext context, Business business) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewsScreen(business: business),
      ),
    );
  }
}

class BusinessDetailsScreen extends StatefulWidget {
  final Business business;
  final String selectedServiceType;
  final User user;

  const BusinessDetailsScreen({
    required this.business,
    required this.selectedServiceType,
    required this.user,
  });

  @override
  _BusinessDetailsScreenState createState() => _BusinessDetailsScreenState();
}

class _BusinessDetailsScreenState extends State<BusinessDetailsScreen> {
  List<Mascota> selectedMascotas = [];
  List<ActivityBussines> filteredServices = [];
  ActivityBussines? selectedService;
  late String selectedStartTime;
  late String selectedEndTime;
  late String descripcionServicio = '';
  late DateTime selectedDay = DateTime.now();
  late double precio = 0.0;
  bool showFirstService = false;

  @override
  void initState() {
    super.initState();
    filteredServices = widget.business.services
        .where((service) => service.actividad == widget.selectedServiceType)
        .toList();
    selectedStartTime = '';
    selectedEndTime = '';
  }

  void _navigateToSelectDateScreen(BuildContext context, Mascota mascota,
      ActivityBussines service, User user, Business business) async {
    final response = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CalendarPageBusinessAll(
          user: user,
          business: business,
          mascota: mascota,
          service: service,
        ),
      ),
    );

    if (response != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reserva realizada con éxito')),
      );

      selectedStartTime = response['selectedStartTime'];
      selectedEndTime = response['selectedEndTime'];
      service = response['service'];

      setState(() {
        mascota.isSelected = false;
        mascota.reservedTime = true;
        descripcionServicio = service.descripcion;
        selectedDay = response['selectedDay'];
        precio = service.precio;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _clearSelection(); // Limpia las selecciones al retroceder
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.business.name),
        ),
        body: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.user.mascotas?.length,
                      itemBuilder: (context, index) {
                        final mascota = widget.user.mascotas?[index];
                        return CheckboxListTile(
                          value: mascota?.isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              mascota.isSelected = value ?? false;
                              if (mascota.isSelected) {
                                selectedService = filteredServices.isNotEmpty
                                    ? filteredServices.first
                                    : null;
                                mascota.actividadId = selectedService?.id;
                                selectedMascotas.add(mascota);
                                showFirstService = true;
                              } else {
                                selectedMascotas.remove(mascota);
                                showFirstService = false;
                                selectedService = null;
                              }
                            });
                          },
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: Utiles.buildImageBase64(
                                        mascota!.fotos, mascota.especie),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      mascota.nombre,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              if (mascota.isSelected)
                                IconButton(
                                  icon: Icon(Icons.calendar_month),
                                  onPressed: () {
                                    if (selectedService != null) {
                                      _navigateToSelectDateScreen(
                                        context,
                                        mascota,
                                        selectedService!,
                                        widget.business.user!,
                                        widget.business,
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Debe seleccionar un servicio primero.'),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              if (mascota.reservedTime)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Reservado para el día ${DateFormat('dd-MM-yyyy').format(selectedDay)}'),
                                    Text('Hora inicio: $selectedStartTime'),
                                    Text('Hora fin: $selectedEndTime'),
                                  ],
                                ),
                            ],
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: filteredServices.length,
                            itemBuilder: (context, index) {
                              final service = filteredServices[index];
                              final isActive = service == selectedService &&
                                  showFirstService;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedService = service;
                                    showFirstService = true;
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 8.0),
                                  padding: EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? Colors.lightBlue[100]
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(10.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        service.descripcion,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text('Precio: \$${service.precio}'),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: selectedMascotas.isEmpty ||
                        selectedStartTime.isEmpty ||
                        selectedEndTime.isEmpty
                    ? null // Deshabilita el botón si no hay una reserva completa
                    : () {
                        double totalPrice = selectedMascotas.fold(0.0,
                            (sum, mascota) => sum + selectedService!.precio);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReservationSummaryScreen(
                              mascotas: selectedMascotas,
                              selectedDay: selectedDay,
                              startTime: selectedStartTime,
                              endTime: selectedEndTime,
                              totalPrice: totalPrice,
                              selectedService: selectedService!,
                              business: widget.business,
                            ),
                          ),
                        ).then((_) {
                          _clearSelection(); // Limpia las selecciones al regresar o después de confirmar
                        });
                      },
                child: Text('Continuar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearSelection() {
    setState(() {
      selectedMascotas.clear();
      selectedService = null;
      showFirstService = false;
      selectedDay = DateTime.now();
      selectedStartTime = '';
      selectedEndTime = '';
      widget.user.mascotas?.forEach((mascota) {
        mascota.isSelected = false;
        mascota.reservedTime = false;
        mascota.actividadId = null;
      });
    });
  }
}

class ReservationSummaryScreen extends StatefulWidget {
  final List<Mascota> mascotas;
  final DateTime selectedDay;
  final String startTime;
  final String endTime;
  final double totalPrice;
  final ActivityBussines selectedService;
  final Business business;

  const ReservationSummaryScreen({
    required this.mascotas,
    required this.selectedDay,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    required this.selectedService,
    required this.business,
  });
  @override
  SummaryScreenPage createState() => SummaryScreenPage();
}

class SummaryScreenPage extends State<ReservationSummaryScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resumen de Reserva'),
      ),
      body: Container(
        color: Colors.grey[200], // Color de fondo gris claro
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estimado cliente, este es el detalle de su reserva:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 16.0,
                  headingRowColor: MaterialStateColor.resolveWith(
                    (states) =>
                        Colors.blueAccent, // Color de fondo del encabezado
                  ),
                  headingTextStyle: TextStyle(
                    color: Colors.white, // Color del texto del encabezado
                    fontWeight: FontWeight.bold,
                  ),
                  columns: [
                    DataColumn(label: Text('Foto')),
                    DataColumn(label: Text('Nombre')),
                    DataColumn(label: Text('Fecha')),
                    DataColumn(label: Text('Hora Inicio')),
                    DataColumn(label: Text('Hora Fin')),
                    DataColumn(label: Text('Precio')),
                  ],
                  rows: [
                    ...widget.mascotas.map((mascota) {
                      return DataRow(cells: [
                        DataCell(
                          CircleAvatar(
                            backgroundImage: Utiles.buildImageBase64(
                                mascota.fotos,
                                mascota
                                    .especie), // Ajusta 'especie' según tu necesidad
                            radius: 20,
                          ),
                        ),
                        DataCell(Text(mascota.nombre)),
                        DataCell(Text(DateFormat('dd-MM-yyyy')
                            .format(widget.selectedDay))),
                        DataCell(Text(widget.startTime)),
                        DataCell(Text(widget.endTime)),
                        DataCell(Text('\$${widget.selectedService.precio}')),
                      ]);
                    }).toList(),
                    DataRow(
                      cells: [
                        DataCell(Text('')),
                        DataCell(Text('')),
                        DataCell(Text('')),
                        DataCell(Text('')),
                        DataCell(Text('Total')),
                        DataCell(Text('\$${widget.totalPrice}')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _handleReservation(context, widget.selectedDay,
                        widget.startTime, widget.endTime);
                  },
                  icon: Icon(Icons.bookmark_add, color: Colors.white),
                  label: Text('Reservar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Color de fondo del botón
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _handlePayment(context, widget.selectedDay,
                        widget.startTime, widget.endTime);
                  },
                  icon: Icon(Icons.payment, color: Colors.white),
                  label: Text('Pagar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Color de fondo del botón
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Método para manejar la reserva.
  void _handleReservation(BuildContext context, DateTime selectedDay,
      String selectedStartDate, String selectedEndDate) {
    _registrar(selectedDay, selectedStartDate, selectedEndDate, "Confirmada");
  }

  // Método para manejar el pago.
  void _handlePayment(BuildContext context, DateTime selectedDay,
      String selectedStartDate, String selectedEndDate) {
    List<ActivityBussines> lstEvento = [];

    for (var mascota in widget.mascotas) {
      // Buscar el servicio con el ID específico
      final evento = widget.business.services.firstWhere(
        (service) => service.id == mascota.actividadId,
        orElse: () => ActivityBussines(
            id: '',
            actividad: '',
            descripcion: '',
            tiempo: 0,
            turnos: 0,
            precio: 0.0,
            status: ''), // Retorna null si no se encuentra el servicio
      );
      lstEvento.add(evento);
    }
    String actividad = lstEvento.first.actividad;
    double precioTotal = 0.0;
    for (var event in lstEvento) {
      precioTotal += event.precio;
    }

    // Muestra un diálogo de confirmación
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmar Reserva y Pago'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Actividad: ${actividad}'),
              Text('Precio: ${precioTotal} UYU'),
              Text('Hora de inicio: ${selectedStartDate}'),
              Text('Hora de fin: ${selectedEndDate}'),
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
                    'title': actividad,
                    'quantity': 1,
                    'currency_id': 'UYU',
                    'unit_price': precioTotal,
                  }),
                );

                if (preferenceResponse.statusCode == 200) {
                  final preferenceId =
                      jsonDecode(preferenceResponse.body)['id'];

                  //final Uri mercadoPagoUrl = Uri.parse('https://flutter.dev');
                  final Uri mercadoPagoUrl = Uri.parse(
                    'https://www.mercadopago.com.uy/checkout/v1/redirect?preference-id=$preferenceId',
                  );
                  // print('Attempting to launch URL: $mercadoPagoUrl');

                  if (await canLaunchUrl(mercadoPagoUrl)) {
                    //print('Launching URL...');

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
                    //print('Failed to launch URL.');
                    Utiles.showErrorDialog(
                        context: context,
                        title: 'Error',
                        content: 'No se pudo iniciar $mercadoPagoUrl');
                    //throw 'Could not launch $mercadoPagoUrl';
                  }
                } else {
                  Utiles.showErrorDialog(
                      context: context,
                      title: 'Error',
                      content:
                          'No se pudo obtener id de preferencia de Mercado Pagos');

                  //print('Failed to create preference');
                }
              },
              child: Text('Pagar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _registrar(DateTime selectedDay, String startTime,
      String endTime, String status) async {
    setState(() {
      _isLoading = true;
    });

    final hourInicioString = startTime;
    final hourFinString = endTime;

    final session = Provider.of<SessionProvider>(context, listen: false);
    String? token = session.token;
    User? user = widget.business.user;

    List<Activity> lstReservas = [];
    for (var mascota in widget.mascotas) {
      // Buscar el servicio con el ID específico
      final foundService = widget.business.services.firstWhere(
        (service) => service.id == mascota.actividadId,
        orElse: () => ActivityBussines(
            id: '',
            actividad: '',
            descripcion: '',
            tiempo: 0,
            precio: 0.0,
            turnos: 0,
            status: ''), // Retorna null si no se encuentra el servicio
      );
      final dateFormat = DateFormat('yyyy-MM-dd hh:mm:ss');

      final reserva = Activity(
          actividadid: Utiles.getId(),
          mascota: mascota,
          user: user,
          title: foundService.actividad,
          description: foundService.descripcion,
          startime: hourInicioString,
          endtime: hourFinString,
          precio: foundService.precio,
          fecha:
              selectedDay.toIso8601String(), //dateFormat.format(selectedDay),
          status: status,
          turnos: 1);
      lstReservas.add(reserva);
    }

    // Convertir la lista de Activity a una lista de Map<String, dynamic>
    List<Map<String, dynamic>> jsonList =
        lstReservas.map((activity) => activity.toJson()).toList();

    final baseUrl = Config.get('api_base_url');
    final url = Uri.parse('$baseUrl/add-evento'); // URL
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'all': 'true',
        'Content-Type': 'application/json'
      },
      body: jsonEncode(jsonList),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      Utiles.showConfirmationDialog(
          context: context,
          title: 'Confirmación',
          content: response.body,
          onConfirm: () {
            Navigator.pushReplacementNamed(context, '/home_propietario');
          });
    }
    if (response.statusCode == 401) {
      Utiles.showErrorDialogUNAUTHORIZED(
          context: context, title: 'Sessión', content: "Debe autenticarse.");
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
      },
    );

    // }
  }
}
