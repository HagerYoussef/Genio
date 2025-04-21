import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:genio_ai/delete.dart';
import 'package:genio_ai/features/chat_bot/new_chat.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:genio_ai/features/login/presentation/widgets/text_auth.dart';
import 'package:intl/intl.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  Map<String, List<Map<String, String>>> groupedPreviews = {};

  @override
  void initState() {
    super.initState();
    _loadChatList();
  }

  Future<void> _loadChatList() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('local_chats');
    if (raw != null) {
      final Map<String, dynamic> allChats = json.decode(raw);
      groupedPreviews.clear();

      allChats.forEach((chatId, chatMessages) {
        final List messages = chatMessages;
        final userMsg = messages.firstWhere(
              (msg) => msg['sender'] == 'user',
          orElse: () => null,
        );

        if (userMsg != null) {
          final text = userMsg['text'] ?? '';
          final timestamp = userMsg['timestamp']; // التاريخ المفترض يتسجل عند الإرسال
          final preview = text.split(' ').take(20).join(' ');

          final dateKey = timestamp != null
              ? DateFormat.yMMMMd().format(DateTime.parse(timestamp))
              : 'Unknown';

          if (!groupedPreviews.containsKey(dateKey)) {
            groupedPreviews[dateKey] = [];
          }

          groupedPreviews[dateKey]!.add({'chatId': chatId, 'preview': preview});
        }
      });

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFFD4EBFF),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildHeader(),
            const Divider(
              indent: 20,
              endIndent: 25,
              color: Color(0XFF99B5DD),
            ),
            _buildSectionTitle('History'),
            ...groupedPreviews.entries.expand((entry) => [
              _buildDateGroup(entry.key),
              ...entry.value.map(_buildItem),
            ]),
            const Divider(
              indent: 20,
              endIndent: 25,
              color: Color(0XFF99B5DD),
            ),
            _buildUserInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 50, bottom: 5),
      child: Column(
        children:[ 
          Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Image.asset('assets/images/historyIcon.png'),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {},
              icon: Image.asset('assets/images/search.png'),
            ),
            IconButton(
              onPressed: () {},
              icon: const ImageIcon(
                AssetImage('assets/images/edit.png'),
                color: Color(0xff0047AB),
                size: 24,
              ),
            ),
          ],
        ),
          SizedBox(
            height: 15,
          ),
          Row(
            children: [
              Image.asset('assets/images/appicon.png',width: 45,height: 45,),
              SizedBox(width: 5,),
              TextAuth(text: 'Genio AI', size: 18, fontWeight: FontWeight.w600, color: Color(0XFF0047AB))
            ],
          ),
    ]
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 15, bottom: 10),
      child: TextAuth(
        text: title,
        size: 18,
        fontWeight: FontWeight.w600,
        color: const Color(0XFF003F56),
      ),
    );
  }

  Widget _buildDateGroup(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 10, bottom: 5),
      child: TextAuth(
        text: title,
        size: 16,
        fontWeight: FontWeight.w500,
        color: const Color(0XFF004B67),
      ),
    );
  }

  Widget _buildItem(Map<String, String> chat) {
    return ListTile(
      dense: true,
      title: Padding(
        padding: const EdgeInsets.only(left: 50, bottom: 5),
        child: TextAuth(
          text: chat['preview']!,
          size: 14,
          fontWeight: FontWeight.w400,
          color: const Color(0XFF004B67),
        ),
      ),
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('chatId', chat['chatId']!);
        Navigator.of(context).pop();
        Navigator.pushReplacementNamed(context, NewChatBot.routeName);
      },
    );
  }

  Widget _buildUserInfo() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundImage: AssetImage('assets/images/user.png'),
        ),
        title: const TextAuth(
          text: 'Hager Mohammed',
          size: 16,
          fontWeight: FontWeight.w500,
          color: Color(0XFF0047AB),
        ),
      ),
    );
  }
}
