class SoccerMatch {
  final String id;
  final String homeTeam;
  final String awayTeam;
  final String league;
  final DateTime matchDate;
  final double homeTeamAvgGoals;
  final double awayTeamAvgGoals;
  final double homeTeamAvgConceded;
  final double awayTeamAvgConceded;
  final double recentFormHome; // 0.0 to 1.0
  final double recentFormAway; // 0.0 to 1.0

  SoccerMatch({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.league,
    required this.matchDate,
    required this.homeTeamAvgGoals,
    required this.awayTeamAvgGoals,
    required this.homeTeamAvgConceded,
    required this.awayTeamAvgConceded,
    required this.recentFormHome,
    required this.recentFormAway,
  });

  // Simple calculation for expected total goals based on averages
  double get expectedTotalGoals {
    // Basic formula: (Home Attack + Away Attack + Home Conceded + Away Conceded) / 4 * adjustment
    // This is a simplified mock logic.
    return (homeTeamAvgGoals + awayTeamAvgGoals + homeTeamAvgConceded + awayTeamAvgConceded) / 2.0;
  }
}

class FilterCriteria {
  double minExpectedGoals;
  double minHomeForm;
  double minAwayForm;
  bool requireHighProbability;

  FilterCriteria({
    this.minExpectedGoals = 2.5,
    this.minHomeForm = 0.0,
    this.minAwayForm = 0.0,
    this.requireHighProbability = false,
  });
}
