class UserProfile {
  final String uid;
  final int tokenBalance;
  final String subscriptionTier;
  final DateTime lastFreeClaimDate;
  final String role;

  UserProfile({
    required this.uid,
    required this.tokenBalance,
    required this.subscriptionTier,
    required this.lastFreeClaimDate,
    this.role = 'customer',
  });

  bool get canClaimMonthlyFree {
    final now = DateTime.now();
    return now.difference(lastFreeClaimDate).inDays >= 30;
  }

  bool get isPro => subscriptionTier == 'pro';
  bool get isStarter => subscriptionTier == 'starter';
  bool get isFree => subscriptionTier == 'free';
  bool get isAdmin => role == 'admin';

  UserProfile copyWith({
    String? uid,
    int? tokenBalance,
    String? subscriptionTier,
    DateTime? lastFreeClaimDate,
    String? role,
  }) => UserProfile(
        uid: uid ?? this.uid,
        tokenBalance: tokenBalance ?? this.tokenBalance,
        subscriptionTier: subscriptionTier ?? this.subscriptionTier,
        lastFreeClaimDate: lastFreeClaimDate ?? this.lastFreeClaimDate,
        role: role ?? this.role,
      );

  factory UserProfile.fromMap(Map<String, dynamic> data, String uid) {
    return UserProfile(
      uid: uid,
      tokenBalance: data['tokenBalance'] ?? 15,
      subscriptionTier: data['subscriptionTier'] ?? 'free',
      lastFreeClaimDate: (data['lastFreeClaimDate'] as dynamic)?.toDate() ?? DateTime.now(),
      role: data['role'] ?? 'customer',
    );
  }

  Map<String, dynamic> toMap() => {
        'tokenBalance': tokenBalance,
        'subscriptionTier': subscriptionTier,
        'lastFreeClaimDate': lastFreeClaimDate,
        'role': role,
      };
}
