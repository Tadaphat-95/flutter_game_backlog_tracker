class Game {
  String? id;
  String? gameName;
  String? genre;
  String? status;
  double? hoursPlayed;
  int? progress;
  bool? reminderEnabled;
  String? reminderTime;
  int? timeLimit;
  String? review;
  String? gameImageUrl;
  String? createdAt;

  Game({
    this.id,
    this.gameName,
    this.genre,
    this.status,
    this.hoursPlayed,
    this.progress,
    this.reminderEnabled,
    this.reminderTime,
    this.timeLimit,
    this.review,
    this.gameImageUrl,
    this.createdAt,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'],
      gameName: json['game_name'],
      genre: json['genre'],
      status: json['status'],
      hoursPlayed: json['hours_played']?.toDouble(),
      progress: json['progress'],
      reminderEnabled: json['reminder_enabled'],
      reminderTime: json['reminder_time'],
      timeLimit: json['time_limit'],
      review: json['review'],
      gameImageUrl: json['game_image_url'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'game_name': gameName,
      'genre': genre,
      'status': status,
      'hours_played': hoursPlayed,
      'progress': progress,
      'reminder_enabled': reminderEnabled,
      'reminder_time': reminderTime,
      'time_limit': timeLimit,
      'review': review,
      'game_image_url': gameImageUrl,
    };
  }
}