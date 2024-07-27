import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './model/user.dart';

class DrinkDetailPage extends StatefulWidget {
  final int drinkId;
  final User user;

  DrinkDetailPage({required this.drinkId, required this.user});

  @override
  _DrinkDetailPageState createState() => _DrinkDetailPageState();
}

class _DrinkDetailPageState extends State<DrinkDetailPage> {
  Future<Map<String, dynamic>>? _drinkFuture;
  Future<List<dynamic>>? _reviewsFuture;
  final _reviewController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _drinkFuture = _fetchDrinkDetail();
    _reviewsFuture = _fetchReviews();
  }

  Future<Map<String, dynamic>> _fetchDrinkDetail() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:3000/drink/getDrinkDetail/${widget.drinkId}'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load drink detail');
      }
    } catch (e) {
      throw Exception('Error fetching drink detail: $e');
    }
  }

  Future<List<dynamic>> _fetchReviews() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:3000/review/getAllReview/${widget.drinkId}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        return data;
      } else {
        throw Exception('Failed to load reviews');
      }
    } catch (e) {
      throw Exception('Error fetching reviews: $e');
    }
  }

  Future<void> _submitReview() async {
    if (_reviewController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Review field mustn't be empty")),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/review/giveReview'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userID': widget.user.userId,
          'drinkID': widget.drinkId,
          'reviewContent': _reviewController.text,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _reviewsFuture = _fetchReviews(); // Refresh reviews
          _reviewController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Review submitted successfully")),
          );
        });
      } else {
        throw Exception('Failed to submit review');
      }
    } catch (e) {
      print('Error submitting review: $e');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _updateReview(String reviewId, String newContent) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:3000/review/updateReview/$reviewId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'reviewContent': newContent}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _reviewsFuture = _fetchReviews(); // Refresh reviews
          _reviewController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Review updated successfully")),
          );
        });
      } else {
        throw Exception('Failed to update review');
      }
    } catch (e) {
      print('Error updating review: $e');
    }
  }

  Future<void> _deleteReview(int reviewId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3000/review/deleteReview/$reviewId'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _reviewsFuture = _fetchReviews();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Review deleted successfully")),
          );
        });
      } else {
        throw Exception('Failed to delete review');
      }
    } catch (e) {
      print('Error deleting review: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _drinkFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Drink Detail'),
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Drink Detail'),
            ),
            body: Center(child: Text("Error: ${snapshot.error}")),
          );
        } else if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Drink Detail'),
            ),
            body: Center(child: Text("No details available")),
          );
        } else {
          final drink = snapshot.data!;
          return DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                title: Text('Drink Detail'),
                bottom: TabBar(
                  tabs: [
                    Tab(text: 'Details'),
                    Tab(text: 'Reviews'),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  _buildDetailsTab(drink),
                  _buildReviewsTab(),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildDetailsTab(Map<String, dynamic> drink) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            "http://localhost:3000/${drink['DrinkImage']}",
            fit: BoxFit.cover,
            height: 250,
            width: double.infinity,
          ),
          SizedBox(height: 16),
          Text(
            drink['DrinkName'],
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Price: ${(drink['DrinkPrice']).toString()}',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          SizedBox(height: 8),
          Text(
            drink['DrinkDescription'],
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Reviews:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          _buildReviewForm(),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildReviewForm() {
    return Column(
      children: [
        TextField(
          controller: _reviewController,
          decoration: InputDecoration(
            labelText: 'Write a review',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitReview,
          child: _isSubmitting
              ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : Text('Submit Review'),
        ),
      ],
    );
  }

  Widget _buildReviewsTab() {
    return FutureBuilder<List<dynamic>>(
      future: _reviewsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No reviews yet.'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final review = snapshot.data![index];
              final isUserReview = review['Username'] == widget.user.username;
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Text(review['Username']),
                  subtitle: Text(review['ReviewContent']),
                  trailing: isUserReview
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                _showUpdateDialog(
                                  review['ReviewID']
                                      .toString(), 
                                  review['ReviewContent'],
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _deleteReview(review['ReviewID']);
                              },
                            ),
                          ],
                        )
                      : null,
                ),
              );
            },
          );
        }
      },
    );
  }

  void _showUpdateDialog(String reviewId, String currentContent) {
    _reviewController.text = currentContent;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Review'),
          content: TextField(
            controller: _reviewController,
            decoration: InputDecoration(
              labelText: 'Update your review',
            ),
            maxLines: 3,
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (_reviewController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Update field mustn't be empty")),
                  );
                } else {
                  Navigator.of(context).pop();
                  _updateReview(reviewId, _reviewController.text);
                }
              },
              child: Text('Update'),
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
}
