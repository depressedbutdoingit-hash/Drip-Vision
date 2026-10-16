// Add this file as lib/screens/drips_screen.dart
import 'package:flutter/material.dart';

class DripsScreen extends StatelessWidget {
  const DripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Drips'),
        backgroundColor: const Color(0xFF121416),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your Drips', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: 12, // replace with your real list
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: const DecorationImage(
                        image: NetworkImage('https://picsum.photos/id/1015/200/200'), // replace with your real thumbnail
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF00FFAA).withOpacity(0.3), blurRadius: 15),
                      ],
                    ),
                    child: const Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Text('Drip #${index + 1}', style: TextStyle(color: Colors.white, fontSize: 14)),
                      ),
                    ),
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