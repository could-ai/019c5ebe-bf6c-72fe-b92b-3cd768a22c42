import 'dart:math';
import '../models/soccer_match.dart';

class StatsService {
  // Mock data generation
  List<SoccerMatch> getUpcomingMatches() {
    final List<String> teams = [
      'Arsenal', 'Man City', 'Liverpool', 'Aston Villa', 'Tottenham',
      'Chelsea', 'Newcastle', 'Man Utd', 'West Ham', 'Brighton',
      'Real Madrid', 'Barcelona', 'Atletico', 'Sevilla', 'Valencia',
      'Bayern', 'Dortmund', 'Leverkusen', 'Leipzig', 'Stuttgart'
    ];

    final List<String> leagues = ['Premier League', 'La Liga', 'Bundesliga'];
    final Random random = Random();
    final List<SoccerMatch> matches = [];

    for (int i = 0; i < 20; i++) {
      String home = teams[random.nextInt(teams.length)];
      String away = teams[random.nextInt(teams.length)];
      while (home == away) {
        away = teams[random.nextInt(teams.length)];
      }

      matches.add(SoccerMatch(
        id: 'match_$i',
        homeTeam: home,
        awayTeam: away,
        league: leagues[random.nextInt(leagues.length)],
        matchDate: DateTime.now().add(Duration(days: random.nextInt(7), hours: random.nextInt(24))),
        homeTeamAvgGoals: 0.8 + random.nextDouble() * 2.5, // 0.8 to 3.3
        awayTeamAvgGoals: 0.5 + random.nextDouble() * 2.0, // 0.5 to 2.5
        homeTeamAvgConceded: 0.5 + random.nextDouble() * 1.5,
        awayTeamAvgConceded: 0.8 + random.nextDouble() * 2.0,
        recentFormHome: 0.3 + random.nextDouble() * 0.7, // 0.3 to 1.0
        recentFormAway: 0.2 + random.nextDouble() * 0.7,
      ));
    }
    
    // Sort by date
    matches.sort((a, b) => a.matchDate.compareTo(b.matchDate));
    return matches;
  }

  List<SoccerMatch> applyRules(List<SoccerMatch> matches, FilterCriteria criteria) {
    return matches.where((match) {
      bool passesGoals = match.expectedTotalGoals >= criteria.minExpectedGoals;
      bool passesHomeForm = match.recentFormHome >= criteria.minHomeForm;
      bool passesAwayForm = match.recentFormAway >= criteria.minAwayForm;
      
      // Example "High Probability" rule: If Home team scores a lot and Away team concedes a lot
      bool passesProbability = true;
      if (criteria.requireHighProbability) {
        passesProbability = (match.homeTeamAvgGoals > 1.5 && match.awayTeamAvgConceded > 1.5) ||
                            (match.awayTeamAvgGoals > 1.5 && match.homeTeamAvgConceded > 1.5);
      }

      return passesGoals && passesHomeForm && passesAwayForm && passesProbability;
    }).toList();
  }
}
