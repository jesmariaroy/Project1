import 'package:flutter/material.dart';

class DishDetailPage extends StatefulWidget {
  final String dishName;

  DishDetailPage({required this.dishName});

  @override
  _DishDetailPageState createState() => _DishDetailPageState();
}

class _DishDetailPageState extends State<DishDetailPage> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dishName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.dishName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'This is a delicious dish made with fresh ingredients and prepared with love. Perfect for any occasion!',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  isFavorite = !isFavorite;
                });
                final snackBar = SnackBar(
                  content: Text(
                    isFavorite
                        ? '${widget.dishName} added to favorites!'
                        : '${widget.dishName} removed from favorites!',
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
            ),
          ],
        ),
      ),
    );
  }
}
