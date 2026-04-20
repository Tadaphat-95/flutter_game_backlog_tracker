import 'package:flutter/material.dart';
import 'package:flutter_game_backlog_tracker/models/game.dart';
import 'package:flutter_game_backlog_tracker/services/supabase_service.dart';
import 'package:flutter_game_backlog_tracker/views/add_game_ui.dart';
import 'package:flutter_game_backlog_tracker/views/update_delete_game_ui.dart';

class ShowAllGameUi extends StatefulWidget {
  const ShowAllGameUi({super.key});

  @override
  State<ShowAllGameUi> createState() => _ShowAllGameUiState();
}

class _ShowAllGameUiState extends State<ShowAllGameUi> {
  final service = SupabaseService();
  List<Game> games = [];
  String selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    loadGames();
  }

  void loadGames() async {
    final data = await service.getGames();
    setState(() {
      games = data;
    });
  }

  List<Game> get filteredGames {
    if (selectedStatus == 'all') return games;
    return games.where((g) => g.status == selectedStatus).toList();
  }

  Color statusColor(String? status) {
    switch (status) {
      case 'playing': return const Color(0xFFF5C14A);
      case 'done': return const Color(0xFF4ADE80);
      case 'want': return const Color(0xFFA78BFA);
      default: return const Color(0xFF888888);
    }
  }

  String statusLabel(String? status) {
    switch (status) {
      case 'playing': return 'Playing';
      case 'done': return 'Done';
      case 'want': return 'Want';
      default: return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        title: const Text(
          'My Games',
          style: TextStyle(
            color: Color(0xFFF0F0F0),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${games.length} games tracked',
          style: const TextStyle(color: Color(0xFF555555), fontSize: 12),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFF5C14A),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddGameUi()),
          ).then((_) => loadGames());
        },
        child: const Icon(Icons.add, color: Color(0xFF0F0F0F)),
      ),
      body: Column(
        children: [
          // Filter Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: ['all', 'playing', 'done', 'want'].map((status) {
                final isActive = selectedStatus == status;
                final label = status == 'all' ? 'All' : statusLabel(status);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => selectedStatus = status),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFFF5C14A) : const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isActive ? const Color(0xFFF5C14A) : const Color(0xFF2A2A2A),
                        ),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isActive ? const Color(0xFF0F0F0F) : const Color(0xFF666666),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Game List
          Expanded(
            child: filteredGames.isEmpty
                ? const Center(
                    child: Text(
                      'ยังไม่มีเกม\nกด + เพื่อเพิ่มเกมแรก!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF555555), fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredGames.length,
                    itemBuilder: (context, index) {
                      final game = filteredGames[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdateDeleteGameUi(game: game),
                            ),
                          ).then((_) => loadGames());
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF2A2A2A)),
                          ),
                          child: Row(
                            children: [
                              // รูปเกม
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: game.gameImageUrl != null && game.gameImageUrl!.isNotEmpty
                                    ? Image.network(
                                        game.gameImageUrl!,
                                        width: 56,
                                        height: 56,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 56,
                                        height: 56,
                                        color: const Color(0xFF2A2A2A),
                                        child: const Icon(
                                          Icons.sports_esports_rounded,
                                          color: Color(0xFF555555),
                                          size: 28,
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 14),
                              // ข้อมูลเกม
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      game.gameName ?? '-',
                                      style: const TextStyle(
                                        color: Color(0xFFF0F0F0),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${game.genre ?? '-'} · ${game.hoursPlayed?.toStringAsFixed(0) ?? 0}h',
                                      style: const TextStyle(
                                        color: Color(0xFF666666),
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Progress bar
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: (game.progress ?? 0) / 100,
                                        backgroundColor: const Color(0xFF2A2A2A),
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          statusColor(game.status),
                                        ),
                                        minHeight: 4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Status tag
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor(game.status).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  statusLabel(game.status),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: statusColor(game.status),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}