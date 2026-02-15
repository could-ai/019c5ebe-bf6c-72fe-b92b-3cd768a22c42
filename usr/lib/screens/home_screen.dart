import 'package:flutter/material.dart';
import '../models/soccer_match.dart';
import '../services/stats_service.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StatsService _statsService = StatsService();
  late List<SoccerMatch> _allMatches;
  late List<SoccerMatch> _filteredMatches;
  
  // Current Filter State
  final FilterCriteria _criteria = FilterCriteria(
    minExpectedGoals: 2.5,
    minHomeForm: 0.0,
    requireHighProbability: false,
  );

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _allMatches = _statsService.getUpcomingMatches();
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filteredMatches = _statsService.applyRules(_allMatches, _criteria);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soccer Stats Analyzer'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildMatchList(_allMatches, "All Upcoming Games"),
          _buildRulesView(),
          _buildMatchList(_filteredMatches, "High Probability Outcomes"),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer),
            label: 'All Games',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tune),
            label: 'Rules',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Predictions',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildMatchList(List<SoccerMatch> matches, String title) {
    if (matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('No matches found matching criteria.', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final match = matches[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateFormat('MMM d, HH:mm').format(match.matchDate), 
                               style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(match.league, style: const TextStyle(color: Colors.blue, fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(match.homeTeam, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text('Avg Goals: ${match.homeTeamAvgGoals.toStringAsFixed(1)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text('VS', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey)),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(match.awayTeam, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text('Avg Goals: ${match.awayTeamAvgGoals.toStringAsFixed(1)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Expected Goals: ${match.expectedTotalGoals.toStringAsFixed(2)}', 
                               style: TextStyle(
                                 fontWeight: FontWeight.bold, 
                                 color: match.expectedTotalGoals > 2.5 ? Colors.green : Colors.orange
                               )),
                          if (match.recentFormHome > 0.7)
                            const Icon(Icons.local_fire_department, color: Colors.red, size: 20),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRulesView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Analysis Rules', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('Configure the rules to narrow down high probability outcomes.'),
          const SizedBox(height: 24),
          
          _buildSectionHeader('Goal Expectations'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Min Expected Goals'),
                      Text(_criteria.minExpectedGoals.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Slider(
                    value: _criteria.minExpectedGoals,
                    min: 0.0,
                    max: 5.0,
                    divisions: 50,
                    label: _criteria.minExpectedGoals.toStringAsFixed(1),
                    onChanged: (value) {
                      setState(() {
                        _criteria.minExpectedGoals = value;
                        _applyFilters();
                      });
                    },
                  ),
                  const Text('Filters games where the combined average scoring potential exceeds this value.', 
                             style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          _buildSectionHeader('Team Form'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Min Home Team Form'),
                      Text('${(_criteria.minHomeForm * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Slider(
                    value: _criteria.minHomeForm,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    onChanged: (value) {
                      setState(() {
                        _criteria.minHomeForm = value;
                        _applyFilters();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          _buildSectionHeader('Advanced Logic'),
          SwitchListTile(
            title: const Text('Require High Probability Matchup'),
            subtitle: const Text('Only show games where a strong attack meets a weak defense.'),
            value: _criteria.requireHighProbability,
            onChanged: (bool value) {
              setState(() {
                _criteria.requireHighProbability = value;
                _applyFilters();
              });
            },
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedIndex = 2; // Jump to predictions
                });
              },
              icon: const Icon(Icons.check_circle),
              label: const Text('View Results'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
