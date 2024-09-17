import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LostPetsScreen extends StatelessWidget {
  final List<Pet> lostPets = [
    Pet(
      name: "Max",
      phone: "+1234567890",
      address: "123 Main St",
      photoUrl: "https://i.pinimg.com/564x/a4/6f/e4/a46fe42ef60ffcb5dc81f5aa85f8857b.jpg",
    ),
    Pet(
      name: "Bella",
      phone: "+0987654321",
      address: "456 Maple Ave",
      photoUrl: "https://i.pinimg.com/564x/a0/98/6f/a0986f78adb3992618df7f24f0bc1256.jpg",
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
            Text('Mascotas Perdidas'),  // Título de la pantalla
          ],
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.grey[200],  // Color de fondo gris claro
        child: ListView.builder(
          itemCount: lostPets.length,
          itemBuilder: (context, index) {
            final pet = lostPets[index];
            return Padding(
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
                          Text(pet.address),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _openWhatsApp(String phone) async {
    final whatsappUrl = "https://wa.me/$phone";
    if (await canLaunch(whatsappUrl)) {
      await launch(whatsappUrl);
    } else {
      throw 'Could not launch $whatsappUrl';
    }
  }
}

class Pet {
  final String name;
  final String phone;
  final String address;
  final String photoUrl;

  Pet({
    required this.name,
    required this.phone,
    required this.address,
    required this.photoUrl,
  });
}
