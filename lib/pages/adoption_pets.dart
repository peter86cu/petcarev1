import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AdoptionScreen extends StatelessWidget {
  final List<Pet> adoptionPets = [
    Pet(
      name: "Luna",
      sex: "Hembra",
      breed: "Labrador",
      shelterName: "Refugio Feliz",
      address: "789 Oak St",
      phone: "+1234567890",
      photoUrl: "https://i.pinimg.com/564x/26/24/9a/26249a78777f6e3527d959ed4399dc1e.jpg",
      interestedCount: 5,
    ),
    Pet(
      name: "Rocky",
      sex: "Macho",
      breed: "Bulldog",
      shelterName: "Hogar de Mascotas",
      address: "123 Pine St",
      phone: "+0987654321",
      photoUrl: "https://i.pinimg.com/564x/d5/3f/f1/d53ff1e5e45113fe77a362b7086f4ea7.jpg",
      interestedCount: 8,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets_sharp),  // Icono representativo
            SizedBox(width: 10),
            Text('Mascotas en Adopción'),  // Título de la pantalla
          ],
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.grey[200],  // Color de fondo gris claro
        child: ListView.builder(
          itemCount: adoptionPets.length,
          itemBuilder: (context, index) {
            final pet = adoptionPets[index];
            return GestureDetector(
              onTap: () => _showAdoptionDialog(context, pet),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),  // Borde redondeado
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),  // Sombra para darle profundidad
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipOval(
                        child: Image.network(
                          pet.photoUrl,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pet.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text('Sexo: ${pet.sex}'),
                            Text('Raza: ${pet.breed}'),
                            SizedBox(height: 8),
                            Text('Refugio: ${pet.shelterName}'),
                            Text(pet.address),
                            SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => _openWhatsApp(pet.phone),
                              child: Text(
                                pet.phone,
                                style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '${pet.interestedCount} personas interesadas',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showAdoptionDialog(BuildContext context, Pet pet) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('¿Quieres adoptar a ${pet.name}?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sexo: ${pet.sex}'),
              Text('Raza: ${pet.breed}'),
              Text('Refugio: ${pet.shelterName}'),
              Text('Dirección: ${pet.address}'),
              SizedBox(height: 8),
              Text('Teléfono: ${pet.phone}'),
              SizedBox(height: 8),
              Text('Cantidad de interesados: ${pet.interestedCount}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _sendAdoptionRequest(pet.phone, pet.name);
                Navigator.of(context).pop();
              },
              child: Text('Adoptar'),
            ),
          ],
        );
      },
    );
  }

  void _sendAdoptionRequest(String phone, String petName) async {
    final whatsappUrl = "https://wa.me/$phone?text=Hola,%20me%20interesa%20adoptar%20a%20$petName.";
    if (await canLaunch(whatsappUrl)) {
      await launch(whatsappUrl);
    } else {
      throw 'No se pudo abrir $whatsappUrl';
    }
  }

  void _openWhatsApp(String phone) async {
    final whatsappUrl = "https://wa.me/$phone";
    if (await canLaunch(whatsappUrl)) {
      await launch(whatsappUrl);
    } else {
      throw 'No se pudo abrir $whatsappUrl';
    }
  }
}

class Pet {
  final String name;
  final String sex;
  final String breed;
  final String shelterName;
  final String address;
  final String phone;
  final String photoUrl;
  final int interestedCount;

  Pet({
    required this.name,
    required this.sex,
    required this.breed,
    required this.shelterName,
    required this.address,
    required this.phone,
    required this.photoUrl,
    required this.interestedCount,
  });
}
