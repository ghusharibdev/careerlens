class MatchResultModel {
  final int matchScore;
  final List<String> matchedSkills;
  final List<String> skillGaps;
  final List<String> talkingPoints;
  final List<String> suggestedQuestions;

  MatchResultModel({
    required this.matchScore,
    required this.matchedSkills,
    required this.skillGaps,
    required this.talkingPoints,
    required this.suggestedQuestions,
  });

  factory MatchResultModel.fromMap(Map<String, dynamic> map) {
    return MatchResultModel(
      matchScore: map['matchScore'] ?? 0,
      matchedSkills: List<String>.from(map['matchedSkills'] ?? []),
      skillGaps: List<String>.from(map['skillGaps'] ?? []),
      talkingPoints: List<String>.from(map['talkingPoints'] ?? []),
      suggestedQuestions: List<String>.from(map['suggestedQuestions'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
    'matchScore': matchScore,
    'matchedSkills': matchedSkills,
    'skillGaps': skillGaps,
    'talkingPoints': talkingPoints,
    'suggestedQuestions': suggestedQuestions,
  };
}
