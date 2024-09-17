import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

import '../class/ActividadEstilista.dart';
import '../class/SessionProvider.dart';
import 'Config.dart';

class SolicitudesPage extends StatefulWidget {
  @override
  _SolicitudesPageState createState() => _SolicitudesPageState();
}

class _SolicitudesPageState extends State<SolicitudesPage> {



  Future<List<Activity>> fetchPendingActivities() async {
    final session = Provider.of<SessionProvider>(context, listen: false);
    final baseUrl = Config.get('api_base_url');
    String userId= session.user!.userid;
    final url = Uri.parse('$baseUrl/activity-estilista?id=$userId&status=Pendiente');
    String? token= session.token;
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer '+token!, // Reemplaza 'tu_token_aqui' con tu token real
      'Content-Type': 'application/json; charset=utf-8', // Ejemplo de otro encabezado opcional
    },);

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => Activity.fromJson(json)).toList();
    }else if (response.statusCode == 204) {
      throw Exception('No hay eventos que gestionar');
    }
    else
   {
      throw Exception('Failed to load pending activities');
    }
  }

  Future<void> approveActivity(Activity activity) async {
    final session = Provider.of<SessionProvider>(context, listen: false);
    final baseUrl = Config.get('api_base_url');
    final url = Uri.parse('$baseUrl/add-evento');
    String? token= session.token;
    final dateFormat = DateFormat('yyyy-MM-dd');

    String status='Aprobada';

    final response = await http.post(url, headers: {
      'Authorization': 'Bearer '+token!, // Reemplaza 'tu_token_aqui' con tu token real
      'Content-Type': 'application/json; charset=utf-8',
    }, body: jsonEncode({'actividadid': activity.actividadid, 'status': status, 'mascota': activity.mascota.toJson(),'title':activity.title,'description':activity.description,'time':activity.startime,'fecha':activity.fecha,'usuario':activity.user?.toJson()}));

    if (response.statusCode == 200) {
      // Actualización exitosa, recargar actividades pendientes
      setState(() {
        _pendingActivities = fetchPendingActivities();
      });
    } else {
      throw Exception('Failed to approve activity');
    }
  }

  Future<void> rejectActivity(String activityId, String reason) async {
    final session = Provider.of<SessionProvider>(context, listen: false);
    final baseUrl = Config.get('api_base_url');
    final url = Uri.parse('$baseUrl/reject-activity');
    String? token = session.token;
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ' + token!,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'activityId': activityId, 'reason': reason}),
    );

    if (response.statusCode == 200) {
      setState(() {
        _pendingActivities = fetchPendingActivities();
      });
    } else {
      throw Exception('Failed to reject activity');
    }
  }

  void showRejectDialog(String activityId) {
    TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Rechazar Actividad'),
          content: TextField(
            controller: reasonController,
            decoration: InputDecoration(hintText: 'Motivo de rechazo'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                rejectActivity(activityId, reasonController.text);
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void showActivityDetails(Activity activity) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(activity.title),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Mascota: ${activity.mascota.nombre}'),
              SizedBox(height: 10),
              Text('Fecha: ${activity.fecha}'),
              SizedBox(height: 10),
              Text('Hora: ${activity.startime}'),
              SizedBox(height: 10),
              Text('Actividad: ${activity.title}'),
              SizedBox(height: 10),
              Text('Detalles: ${activity.description}'),
              // Asegúrate de tener un campo "details" en tu clase Activity
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

  late Future<List<Activity>> _pendingActivities;

  @override
  void initState() {
    super.initState();
    _pendingActivities = fetchPendingActivities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Solicitudes'),
      ),
      body: FutureBuilder<List<Activity>>(
        future: _pendingActivities,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No pending activities found'));
          }

          final activities = snapshot.data!;

          return ListView.builder(
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              return ListTile(
                leading: Icon(Icons.pending_actions),
                title: Text(activity.title),
                subtitle: Text(activity.startime),
                onTap: () => showActivityDetails(activity),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.check, color: Colors.green),
                      onPressed: () {
                        approveActivity(activity);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        showRejectDialog(activity.actividadid as String);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

