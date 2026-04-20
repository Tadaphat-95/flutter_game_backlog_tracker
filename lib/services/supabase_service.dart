import 'dart:io';
import 'package:flutter_game_backlog_tracker/models/game.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  // ดึงข้อมูลเกมทั้งหมด
  Future<List<Game>> getGames() async {
    final data = await supabase
        .from('games_tb')
        .select('*')
        .order('created_at', ascending: false);
    return data.map((game) => Game.fromJson(game)).toList();
  }

  // อัปโหลดรูปเกม
  Future<String> uploadFile(XFile file) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}-${file.name}';

    if (kIsWeb) {
      final bytes = await file.readAsBytes();
      await supabase.storage.from('games_bk').uploadBinary(fileName, bytes);
    } else {
      await supabase.storage.from('games_bk').upload(fileName, File(file.path));
    }

    return supabase.storage.from('games_bk').getPublicUrl(fileName);
  }

  // ลบรูปเกม
  Future deleteFile(String fileUrl) async {
    String fileName = fileUrl.split('/').last;
    await supabase.storage.from('games_bk').remove([fileName]);
  }

  // เพิ่มเกมใหม่
  Future insertGame(Game game) async {
    await supabase.from('games_tb').insert(game.toJson());
  }

  // แก้ไขเกม
  Future updateGame(String id, Game game) async {
    await supabase.from('games_tb').update(game.toJson()).eq('id', id);
  }

  // ลบเกม
  Future deleteGame(String id) async {
    await supabase.from('games_tb').delete().eq('id', id);
  }
}