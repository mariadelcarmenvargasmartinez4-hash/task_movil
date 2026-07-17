class FamilyReward {
  final String id;
  final String title;
  final int points;

  const FamilyReward({
    required this.id,
    required this.title,
    required this.points,
  });

  factory FamilyReward.fromJson(Map<String, dynamic> json) {
    return FamilyReward(
      id: json['id'] as String,
      title: json['title'] as String,
      points: json['points'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'points': points,
    };
  }
}

class ClaimedReward {
  final String id;
  final String rewardId;
  final String title;
  final String claimedBy;
  final int points;
  final String claimedAt;

  const ClaimedReward({
    required this.id,
    required this.rewardId,
    required this.title,
    required this.claimedBy,
    required this.points,
    required this.claimedAt,
  });

  factory ClaimedReward.fromJson(Map<String, dynamic> json) {
    return ClaimedReward(
      id: json['id'] as String,
      rewardId: json['rewardId'] as String,
      title: json['title'] as String,
      claimedBy: json['claimedBy'] as String,
      points: json['points'] as int,
      claimedAt: json['claimedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rewardId': rewardId,
      'title': title,
      'claimedBy': claimedBy,
      'points': points,
      'claimedAt': claimedAt,
    };
  }
}
