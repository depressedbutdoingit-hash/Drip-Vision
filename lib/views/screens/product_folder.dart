import 'package:flutter/material.dart';
import '../../core/theme.dart';

class ProductFolderScreen extends StatelessWidget {
  final List<Map<String, String>> clientGenerations;
  final Function(String id) onDelete;
  final Function(String lastFrameUrl) onContinueScene;

  const ProductFolderScreen({
    super.key,
    required this.clientGenerations,
    required this.onDelete,
    required this.onContinueScene,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'My Creations',
          style: TextStyle(
            color: DripTheme.nebulaCyan,
            shadows: [
              Shadow(color: DripTheme.cosmicTeal, blurRadius: 15),
            ],
          ),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: clientGenerations.length,
        itemBuilder: (context, index) {
          final item = clientGenerations[index];
          return Container(
            decoration: BoxDecoration(
              color: DripTheme.surface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: DripTheme.cosmicTeal.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: DripTheme.cosmicTeal.withOpacity(0.1),
                  blurRadius: 15,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      item['thumbnailUrl']!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: DripTheme.surfaceLight),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => onDelete(item['id']!),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DripTheme.cosmicTeal,
                          foregroundColor: DripTheme.voidBlack,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        icon: const Icon(Icons.movie_creation, size: 14),
                        label: const Text('Continue', style: TextStyle(fontSize: 11)),
                        onPressed: () => onContinueScene(item['lastFrameUrl']!),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
