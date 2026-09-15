class StoreOutfit {
  final String id;
  final String name;
  final String description;
  final String? previewImageUrl;
  final int priceTokens;
  final bool isFree;
  final OutfitRarity rarity;
  final List<String> tags;
  final String? fullBodyReferenceUrl;
  final String? faceReferenceUrl;

  const StoreOutfit({
    required this.id,
    required this.name,
    required this.description,
    this.previewImageUrl,
    required this.priceTokens,
    this.isFree = false,
    this.rarity = OutfitRarity.common,
    this.tags = const [],
    this.fullBodyReferenceUrl,
    this.faceReferenceUrl,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'previewImageUrl': previewImageUrl,
    'priceTokens': priceTokens,
    'isFree': isFree,
    'rarity': rarity.name,
    'tags': tags,
    'fullBodyReferenceUrl': fullBodyReferenceUrl,
    'faceReferenceUrl': faceReferenceUrl,
  };

  factory StoreOutfit.fromJson(Map<String, dynamic> json) => StoreOutfit(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    previewImageUrl: json['previewImageUrl'],
    priceTokens: json['priceTokens'] ?? 0,
    isFree: json['isFree'] ?? false,
    rarity: OutfitRarity.values.firstWhere(
      (r) => r.name == json['rarity'],
      orElse: () => OutfitRarity.common,
    ),
    tags: List<String>.from(json['tags'] ?? []),
    fullBodyReferenceUrl: json['fullBodyReferenceUrl'],
    faceReferenceUrl: json['faceReferenceUrl'],
  );
}

enum OutfitRarity { common, rare, epic, legendary }

class OutfitCatalog {
  static const List<StoreOutfit> allOutfits = [
    StoreOutfit(
      id: 'outfit_casual',
      name: 'Casual',
      description: 'Everyday comfort. Jeans, t-shirt, sneakers.',
      priceTokens: 0,
      isFree: true,
      rarity: OutfitRarity.common,
      tags: ['basic', 'casual', 'everyday'],
    ),
    StoreOutfit(
      id: 'outfit_business',
      name: 'Business Casual',
      description: 'Blazer, slacks, loafers. Ready for the office.',
      priceTokens: 0,
      isFree: true,
      rarity: OutfitRarity.common,
      tags: ['basic', 'professional', 'work'],
    ),
    StoreOutfit(
      id: 'outfit_streetwear',
      name: 'Streetwear',
      description: 'Hoodie, cargo pants, high-tops. Urban edge.',
      priceTokens: 0,
      isFree: true,
      rarity: OutfitRarity.common,
      tags: ['basic', 'urban', 'youth'],
    ),
    StoreOutfit(
      id: 'outfit_pajamas',
      name: 'Cozy Pajamas',
      description: 'Soft flannel set. Perfect for lazy mornings.',
      priceTokens: 0,
      isFree: true,
      rarity: OutfitRarity.common,
      tags: ['basic', 'sleep', 'cozy'],
    ),
    StoreOutfit(
      id: 'outfit_galaxy_gown',
      name: 'Galaxy Gown',
      description: 'A flowing dress woven from starlight and nebula silk.',
      priceTokens: 150,
      isFree: false,
      rarity: OutfitRarity.legendary,
      tags: ['premium', 'fantasy', 'glowing'],
    ),
    StoreOutfit(
      id: 'outfit_neon_punk',
      name: 'Neon Punk',
      description: 'Leather jacket with holographic spikes and LED trims.',
      priceTokens: 80,
      isFree: false,
      rarity: OutfitRarity.rare,
      tags: ['premium', 'cyberpunk', 'edgy'],
    ),
    StoreOutfit(
      id: 'outfit_cyber_kimono',
      name: 'Cyber Kimono',
      description: 'Traditional silhouette meets circuit-board patterns.',
      priceTokens: 120,
      isFree: false,
      rarity: OutfitRarity.epic,
      tags: ['premium', 'fusion', 'elegant'],
    ),
    StoreOutfit(
      id: 'outfit_ethereal_wings',
      name: 'Ethereal Wings',
      description: 'Translucent wings that shimmer with every movement.',
      priceTokens: 200,
      isFree: false,
      rarity: OutfitRarity.legendary,
      tags: ['premium', 'fantasy', 'angelic'],
    ),
    StoreOutfit(
      id: 'outfit_midnight_tux',
      name: 'Midnight Tuxedo',
      description: 'Sleek black with subtle cosmic teal threading.',
      priceTokens: 100,
      isFree: false,
      rarity: OutfitRarity.rare,
      tags: ['premium', 'formal', 'sleek'],
    ),
    StoreOutfit(
      id: 'outfit_rose_gold_armor',
      name: 'Rose Gold Armor',
      description: 'Delicate plates with rose gold filigree. Battle-ready beauty.',
      priceTokens: 180,
      isFree: false,
      rarity: OutfitRarity.legendary,
      tags: ['premium', 'fantasy', 'warrior'],
    ),
    StoreOutfit(
      id: 'outfit_velvet_dream',
      name: 'Velvet Dream',
      description: 'Deep purple velvet with silver moon embroidery.',
      priceTokens: 90,
      isFree: false,
      rarity: OutfitRarity.rare,
      tags: ['premium', 'romantic', 'soft'],
    ),
    StoreOutfit(
      id: 'outfit_holo_cat',
      name: 'Holo Cat Ears',
      description: 'Holographic cat ear headband with matching tail accessory.',
      priceTokens: 60,
      isFree: false,
      rarity: OutfitRarity.rare,
      tags: ['premium', 'cute', 'playful'],
    ),
    StoreOutfit(
      id: 'outfit_sakura_miko',
      name: 'Sakura Miko',
      description: 'Pink shrine maiden robes with floating cherry blossoms.',
      priceTokens: 130,
      isFree: false,
      rarity: OutfitRarity.epic,
      tags: ['premium', 'cute', 'anime'],
    ),
    StoreOutfit(
      id: 'outfit_ocean_prince',
      name: 'Ocean Prince',
      description: 'Coral crown, pearl buttons, tide-patterned cape.',
      priceTokens: 110,
      isFree: false,
      rarity: OutfitRarity.epic,
      tags: ['premium', 'fantasy', 'royal'],
    ),
  ];

  static List<StoreOutfit> get freeOutfits =>
      allOutfits.where((o) => o.isFree).toList();

  static List<StoreOutfit> get premiumOutfits =>
      allOutfits.where((o) => !o.isFree).toList();
}
