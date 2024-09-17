import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PetFriendlyPage extends StatelessWidget {
  final List<Map<String, dynamic>> petFriendlyPlaces = [
    {
      'name': 'Dog Park Central',
      'services': 'Parque, Agua, Comida',
      'address': '1234 Woof St, Dogtown',
      'images': [
        'lib/assets/nuevo_centro1.jpg',
        'lib/assets/nuevo_centro2.jpg',
        'lib/assets/nuevo_centro3.jpg',
      ],
    },
    {
      'name': 'Cat Cafe',
      'services': 'Comida, Bebidas, Juego',
      'address': '5678 Meow Ave, Cat City',
      'images': [
        'lib/assets/cafe1.png',
        'lib/assets/cafe2.jpg',
        'lib/assets/cafe3.jpg',
      ],
    },
    // Añadir más lugares aquí
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pet Friendly Places'),
      ),
      body: ListView.builder(
        itemCount: petFriendlyPlaces.length,
        itemBuilder: (context, index) {
          final place = petFriendlyPlaces[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: CarouselSlider(
                      options: CarouselOptions(
                        height: 150.0,
                        enlargeCenterPage: true,
                        enableInfiniteScroll: true,
                        autoPlay: true,
                      ),
                      items: place['images'].map<Widget>((image) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullScreenImageGallery(
                                  images: place['images'],
                                  initialIndex: place['images'].indexOf(image),
                                ),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              image,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            place['name'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            place['services'],
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 5),
                          Text(
                            place['address'],
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class FullScreenImageGallery extends StatelessWidget {
  final List<String> images;
  final int initialIndex;

  FullScreenImageGallery({required this.images, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: AssetImage(images[index]),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
        itemCount: images.length,
        pageController: PageController(initialPage: initialIndex),
        onPageChanged: (index) {
          // Puedes añadir lógica adicional si es necesario
        },
      ),
    );
  }
}
