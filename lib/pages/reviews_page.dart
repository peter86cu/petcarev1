import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';

import '../class/Negocio.dart';
import '../class/Review.dart';
import '../class/SessionProvider.dart';
import '../class/UserRoles.dart';
import 'Config.dart';
import 'Utiles.dart';

class ReviewsScreen extends StatefulWidget {
  final Business business;

  ReviewsScreen({required this.business});

  @override
  _ReviewsScreenState createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  List<Review> reviews = [];
  Map<int, bool> likedReviews = {};
  Map<int, bool> expandedReviews = {};
  Map<int, TextEditingController> responseControllers = {};
  Map<int, bool> showResponseField = {};

  @override
  void initState() {
    super.initState();
    final session = Provider.of<SessionProvider>(context, listen: false);

    session.checkTokenValidity(context);
    fetchReviews(widget.business.id).then((loadedReviews) {
      setState(() {
        reviews = loadedReviews;
        likedReviews = {for (int i = 0; i < reviews.length; i++) i: false};
        expandedReviews = {for (int i = 0; i < reviews.length; i++) i: false};
        responseControllers = {for (int i = 0; i < reviews.length; i++) i: TextEditingController()};
        showResponseField = {for (int i = 0; i < reviews.length; i++) i: false};
      });
    });
  }

  Future<List<Review>> fetchReviews(String businessId) async {
    final session = Provider.of<SessionProvider>(context, listen: false);
    final baseUrl = Config.get('api_base_url');
    String? token =session.token;
    var url = Uri.parse('$baseUrl/api/comments/business/$businessId'); // Reemplaza con la URL de tu API

    final uri = Uri.http(url.authority, url.path);

    var response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer '+token!, // Reemplaza 'tu_token_aqui' con tu token real
        'Content-Type': 'application/json', // Ejemplo de otro encabezado opcional
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((data) => Review.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load responses');
      //Utiles.showErrorDialog(context: context, title: 'Error', content: response.body);
    }
  }

  /*Future<List<ReviewResponse>> fetchCommentResponses(String commentId) async {
    final response = await http.get(Uri.parse('https://example.com/api/responses/$commentId'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((data) => ReviewResponse.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load responses');
    }
  }*/


  Future<void> addCommentResponse(String commentId, ReviewResponse nuevo) async {
    final responseBody = json.encode(nuevo.toJson());
    final session = Provider.of<SessionProvider>(context, listen: false);


    final baseUrl = Config.get('api_base_url');
    String? token =  session.token;

    final response = await http.post(
      Uri.parse('$baseUrl/api/responses/comment/new'),
      headers: {
        'Authorization': 'Bearer '+ token!,
        'commentId': commentId,
        'Content-Type': 'application/json'
      },
      body: jsonEncode(nuevo.toJson()),
    );




    /*if (response.statusCode == 200) {
      setState(() {
        // Update the review with the new response
        final review = reviews.firstWhere((review) => review.id == commentId);
        review.responses.add(nuevo);
      });
    } else {
      throw Exception('Failed to add response');
    }*/
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comentarios de ${widget.business.name}'),
      ),
      body: ListView.builder(
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          final review = reviews[index];
          final isLiked = likedReviews[index] ?? false;
          final isExpanded = expandedReviews[index] ?? false;
          final showField = showResponseField[index] ?? false;

          return Container(
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                           CircleAvatar(
                            backgroundImage: Utiles.buildImageBase64(review.user.photo!, 'user'), // Ajusta 'especie' según tu necesidad
                            radius: 15,
                          ),
                          SizedBox(width: 8),
                          Text(
                            review.user.name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          RatingBar.builder(
                            initialRating: review.rating.toDouble(),
                            minRating: 1,
                            allowHalfRating: false,
                            itemCount: 5,
                            itemSize: 20.0,
                            itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                            onRatingUpdate: (rating) {
                              // Puedes manejar la actualización aquí si es necesario
                            },
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '${_formatTimeAgo(review.timestamp)}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isExpanded
                                ? review.comment
                                : review.comment.length > 200
                                ? '${review.comment.substring(0, 200)}...'
                                : review.comment,
                            style: TextStyle(fontSize: 16.0),
                          ),
                          if (review.comment.length > 200)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  expandedReviews[index] = !isExpanded;
                                });
                              },
                              child: Text(
                                isExpanded ? 'Ver menos' : 'Más',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                        ],
                      ),
                      if (review.responses.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            children: review.responses.map((response) {
                              return Container(
                                margin: EdgeInsets.symmetric(vertical: 4.0),
                                padding: EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(20.0),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (response.user.photo != null)
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: CircleAvatar(
                                          backgroundImage: Utiles.buildImageBase64(response.user.photo!, 'especie'), // Ajusta 'especie' según tu necesidad
                                          radius: 15,
                                        ),
                                      ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            response.user.name,
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            response.response,
                                            style: TextStyle(fontSize: 16.0),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      if (showField)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: responseControllers[index],
                                    decoration: InputDecoration(
                                      hintText: 'Escribe tu respuesta...',
                                      border: InputBorder.none,
                                    ),
                                    maxLines: 2,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.send, color: Colors.blue),
                                  onPressed: () {
                                    if (responseControllers[index]!.text.isNotEmpty) {
                                      final session = Provider.of<SessionProvider>(context, listen: false);
                                      String? token =session.token;
                                      List<UserRoles> lstRoles = [];
                                      final response = ReviewResponse(
                                        id: Utiles.getId(), // Generar un ID único para la respuesta
                                        comment: review.id  ,
                                        user: session.user!, // Reemplaza con el nombre del usuario que responde
                                        response: responseControllers[index]!.text,
                                        timestamp: DateTime.now(),
                                      );

                                      addCommentResponse(review.id, response).then((_) {
                                        setState(() {
                                          review.responses.add(response);
                                          responseControllers[index]!.clear();
                                          showResponseField[index] = false;
                                        });
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            showResponseField[index] = !showResponseField[index]!;
                          });
                        },
                        child: Row(
                          children: [
                            Icon(Icons.reply, color: Colors.grey[600], size: 20.0),
                            SizedBox(width: 4),
                            Text(
                              'Responder',
                              style: TextStyle(color: Colors.grey[600], fontSize: 16.0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 16.0, thickness: 1.0),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays >= 1) {
      return '${difference.inDays}d';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}m';
    } else {
      return '${difference.inSeconds}s';
    }
  }
}



