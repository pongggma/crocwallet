class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final bool unlocked;

  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    this.unlocked = false,
  });

  AchievementModel copyWith({bool? unlocked}) => AchievementModel(
        id: id,
        title: title,
        description: description,
        emoji: emoji,
        unlocked: unlocked ?? this.unlocked,
      );
}
