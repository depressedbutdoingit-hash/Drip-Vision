import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/character.dart';

class DripSwapperView extends StatelessWidget {
  final Character character;
  final Function(Outfit) onOutfitSelected;

  const DripSwapperView({
    super.key,
    required this.character,
    required this.onOutfitSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      color: DripTheme.surface.withOpacity(0.95),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${character.name}'s Closet",
                  style: const TextStyle(
                    color: DripTheme.nebulaCyan,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    shadows: [
                      Shadow(
                        color: DripTheme.nebulaCyan,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.checkroom, color: DripTheme.cosmicTeal, size: 20),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: character.closet.length,
              itemBuilder: (context, index) {
                final outfit = character.closet[index];
                final isSelected = outfit.id == character.activeOutfitId;
                return GestureDetector(
                  onTap: () => onOutfitSelected(outfit),
                  child: Container(
                    width: 130,
                    margin: const EdgeInsets.only(left: 12, bottom: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? DripTheme.cosmicTeal : Colors.grey.shade800,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      color: DripTheme.surfaceLight,
                      image: outfit.outfitImageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(outfit.outfitImageUrl!),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(isSelected ? 0.3 : 0.6),
                                BlendMode.darken,
                              ),
                            )
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: DripTheme.cosmicTeal.withOpacity(0.3),
                                blurRadius: 12,
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(14),
                            ),
                          ),
                          child: Text(
                            outfit.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
