import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_game_backlog_tracker/models/game.dart';
import 'package:flutter_game_backlog_tracker/services/notification_service.dart';
import 'package:flutter_game_backlog_tracker/services/supabase_service.dart';
import 'package:image_picker/image_picker.dart';

class AddGameUi extends StatefulWidget {
  const AddGameUi({super.key});

  @override
  State<AddGameUi> createState() => _AddGameUiState();
}

class _AddGameUiState extends State<AddGameUi> {
  final gameNameCtrl = TextEditingController();
  final genreCtrl = TextEditingController();
  final hoursCtrl = TextEditingController();
  final reviewCtrl = TextEditingController();

  String? status = 'want';
  int progress = 0;
  bool reminderEnabled = false;
  TimeOfDay reminderTime = const TimeOfDay(hour: 20, minute: 0);
  int timeLimit = 2;
  String? gameImageUrl;
  File? file;
  Uint8List? webImageBytes;
  XFile? pickedFile;

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      pickedFile = picked;
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() => webImageBytes = bytes);
      } else {
        setState(() => file = File(picked.path));
      }
    }
  }

  bool get hasImage => kIsWeb ? webImageBytes != null : file != null;

  Widget buildImagePreview() {
    if (!hasImage) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.add_photo_alternate_rounded, size: 40, color: Color(0xFF555555)),
          SizedBox(height: 8),
          Text('เพิ่มรูปเกม', style: TextStyle(color: Color(0xFF555555), fontSize: 12)),
        ],
      );
    }
    if (kIsWeb) {
      return Image.memory(webImageBytes!, fit: BoxFit.cover);
    } else {
      return Image.file(file!, fit: BoxFit.cover);
    }
  }

  Future<void> pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: reminderTime,
    );
    if (picked != null) setState(() => reminderTime = picked);
  }

  Future<void> save() async {
    if (gameNameCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาใส่ชื่อเกม'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final service = SupabaseService();

    if (pickedFile != null) {
      gameImageUrl = await service.uploadFile(pickedFile!);
    }

    final game = Game(
      gameName: gameNameCtrl.text,
      genre: genreCtrl.text,
      status: status,
      hoursPlayed: double.tryParse(hoursCtrl.text) ?? 0,
      progress: progress,
      reminderEnabled: reminderEnabled,
      reminderTime: '${reminderTime.hour}:${reminderTime.minute}',
      timeLimit: timeLimit,
      review: reviewCtrl.text,
      gameImageUrl: gameImageUrl,
    );

    await service.insertGame(game);

    // ตั้ง Notification ถ้าเปิด reminder
    if (reminderEnabled) {
      await NotificationService.scheduleDailyNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: '🎮 ถึงเวลาเล่นเกมแล้ว!',
        body: 'อย่าลืมเล่น ${gameNameCtrl.text} วันนี้นะ!',
        hour: reminderTime.hour,
        minute: reminderTime.minute,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('เพิ่มเกมสำเร็จ'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        title: const Text('เพิ่มเกมใหม่', style: TextStyle(color: Color(0xFFF0F0F0))),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFF0F0F0)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // รูปเกม
            GestureDetector(
              onTap: pickImage,
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2A2A2A)),
                ),
                clipBehavior: Clip.hardEdge,
                child: buildImagePreview(),
              ),
            ),
            const SizedBox(height: 20),

            // ชื่อเกม
            const Text('ชื่อเกม', style: TextStyle(color: Color(0xFF888888), fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: gameNameCtrl,
              style: const TextStyle(color: Color(0xFFF0F0F0)),
              decoration: const InputDecoration(hintText: 'เช่น Elden Ring'),
            ),
            const SizedBox(height: 16),

            // ประเภท
            const Text('ประเภท', style: TextStyle(color: Color(0xFF888888), fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: genreCtrl,
              style: const TextStyle(color: Color(0xFFF0F0F0)),
              decoration: const InputDecoration(hintText: 'เช่น RPG, Action'),
            ),
            const SizedBox(height: 16),

            // Status
            const Text('สถานะ', style: TextStyle(color: Color(0xFF888888), fontSize: 13)),
            const SizedBox(height: 8),
            Row(
              children: ['want', 'playing', 'done'].map((s) {
                final labels = {'want': 'Want', 'playing': 'Playing', 'done': 'Done'};
                final colors = {
                  'want': const Color(0xFFA78BFA),
                  'playing': const Color(0xFFF5C14A),
                  'done': const Color(0xFF4ADE80),
                };
                final isActive = status == s;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => status = s),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isActive ? colors[s]!.withOpacity(0.2) : const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isActive ? colors[s]! : const Color(0xFF2A2A2A),
                          ),
                        ),
                        child: Text(
                          labels[s]!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isActive ? colors[s]! : const Color(0xFF666666),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // ชั่วโมงที่เล่น
            const Text('ชั่วโมงที่เล่นแล้ว', style: TextStyle(color: Color(0xFF888888), fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: hoursCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Color(0xFFF0F0F0)),
              decoration: const InputDecoration(hintText: 'เช่น 12.5'),
            ),
            const SizedBox(height: 16),

            // Progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('ความคืบหน้า', style: TextStyle(color: Color(0xFF888888), fontSize: 13)),
                Text('$progress%', style: const TextStyle(color: Color(0xFFF5C14A), fontSize: 13)),
              ],
            ),
            Slider(
              value: progress.toDouble(),
              min: 0,
              max: 100,
              divisions: 20,
              activeColor: const Color(0xFFF5C14A),
              inactiveColor: const Color(0xFF2A2A2A),
              onChanged: (val) => setState(() => progress = val.toInt()),
            ),
            const SizedBox(height: 16),

            // Reminder
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('แจ้งเตือนให้เล่น', style: TextStyle(color: Color(0xFFF0F0F0), fontSize: 14)),
                      Switch(
                        value: reminderEnabled,
                        activeColor: const Color(0xFFF5C14A),
                        onChanged: (val) => setState(() => reminderEnabled = val),
                      ),
                    ],
                  ),
                  if (reminderEnabled) ...[
                    const Divider(color: Color(0xFF2A2A2A)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('เวลาแจ้งเตือน', style: TextStyle(color: Color(0xFF888888), fontSize: 13)),
                        GestureDetector(
                          onTap: pickReminderTime,
                          child: Text(
                            '${reminderTime.hour.toString().padLeft(2, '0')}:${reminderTime.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(color: Color(0xFFF5C14A), fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('จำกัดเวลาต่อวัน', style: TextStyle(color: Color(0xFF888888), fontSize: 13)),
                        Text('$timeLimit ชั่วโมง', style: const TextStyle(color: Color(0xFFF5C14A), fontSize: 13)),
                      ],
                    ),
                    Slider(
                      value: timeLimit.toDouble(),
                      min: 1,
                      max: 8,
                      divisions: 7,
                      activeColor: const Color(0xFFF5C14A),
                      inactiveColor: const Color(0xFF2A2A2A),
                      onChanged: (val) => setState(() => timeLimit = val.toInt()),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Review
            const Text('รีวิว / โน้ต', style: TextStyle(color: Color(0xFF888888), fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: reviewCtrl,
              maxLines: 3,
              style: const TextStyle(color: Color(0xFFF0F0F0)),
              decoration: const InputDecoration(hintText: 'ความคิดเห็นเกี่ยวกับเกมนี้...'),
            ),
            const SizedBox(height: 24),

            // ปุ่มบันทึก
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF5C14A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('บันทึก', style: TextStyle(color: Color(0xFF0F0F0F), fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}