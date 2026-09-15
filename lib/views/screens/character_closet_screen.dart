import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../models/character_dna.dart';
import '../../views/widgets/galaxy_background.dart';

class CharacterClosetScreen extends ConsumerStatefulWidget {
  final CharacterDNA character;

  const CharacterClosetScreen({super.key, required this.character});

  @override
  ConsumerState<CharacterClosetScreen> createState() => _CharacterClosetScreenState();
}

class _CharacterClosetScreenState extends ConsumerState<CharacterClosetScreen> {
  late CharacterDNA _character;

  @override
  void initState() {
    super.initState();
    _character = widget.character;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      body: Stack(
        children: [
          const GalaxyBackground(starCount: 50, intensity: 0.2),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _character.name.toUpperCase(),
                              style: theme.textTheme.headlineSmall?.copyWith(
                                letterSpacing: 4,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'WARDROBE',
                              style: TextStyle(
                                fontSize: 12,
                                letterSpacing: 4,
                                color: DripTheme.cosmicTeal.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: _character.closet.isEmpty
                    ? _buildEmptyState()
                    : GridView.builder(
                        padding: const EdgeInsets.all(20),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _character.closet.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _character.closet.length) {
                            return _buildAddOutfitCard();
                          }
                          return _buildOutfitCard(_character.closet[index]);
                        },
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.checkroom, size: 64, color: Colors.white10),
          const SizedBox(height: 16),
          Text(
            'NO OUTFITS YET',
            style: TextStyle(
              color: Colors.white30,
              letterSpacing: 4,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add outfits to build your character\'s wardrobe',
            style: TextStyle(color: Colors.white20, fontSize: 12),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addOutfit,
            icon: const Icon(Icons.add),
            label: const Text('ADD OUTFIT'),
            style: ElevatedButton.styleFrom(
              backgroundColor: DripTheme.cosmicTeal,
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutfitCard(Outfit outfit) {
    final isDefault = outfit.id == _character.defaultOutfitId;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDefault
            ? DripTheme.cosmicTeal.withOpacity(0.5)
            : Colors.white.withOpacity(0.08),
          width: isDefault ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: outfit.referenceImageUrl != null
                ? ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      outfit.referenceImageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  )
                : Center(
                    child: Icon(
                      Icons.checkroom,
                      size: 48,
                      color: Colors.white10,
                    ),
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  outfit.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  outfit.description,
                  style: TextStyle(
                    color: Colors.white40,
                    fontSize: 11,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isDefault)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: DripTheme.cosmicTeal.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'DEFAULT',
                        style: TextStyle(
                          fontSize: 9,
                          color: DripTheme.cosmicTeal,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddOutfitCard() {
    return GestureDetector(
      onTap: _addOutfit,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: DripTheme.cosmicTeal.withOpacity(0.2),
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              size: 40,
              color: DripTheme.cosmicTeal.withOpacity(0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'ADD OUTFIT',
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 2,
                color: DripTheme.cosmicTeal.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addOutfit() {
    // Show dialog to add outfit
  }
}
