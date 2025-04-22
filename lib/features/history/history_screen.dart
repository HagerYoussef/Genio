import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:genio_ai/features/chat_bot/new_chat.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:genio_ai/features/login/presentation/widgets/text_auth.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  Map<String, List<Map<String, String>>> groupedPreviews = {};
  String? profileImageUrl;
  bool showSearchField = false;
  TextEditingController searchController = TextEditingController();
  String searchKeyword = '';

  @override
  void initState() {
    super.initState();
    _loadChatList();
    loadProfileImage();
  }

  void loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      profileImageUrl = prefs.getString('profile_image_url');
    });
  }

  Future<void> _loadChatList() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('local_chats');

    if (raw != null) {
      final Map<String, dynamic> allChats = json.decode(raw);
      groupedPreviews.clear();
////////////////////////////////////////
      // 🔹 Step 1: Load image generation previews
      final previewRaw = prefs.getString('local_chats_preview');

      if (previewRaw != null) {
        final Map<String, dynamic> imageChats = json.decode(previewRaw);

        imageChats.forEach((chatId, chatData) {
          final preview = chatData['preview'];
          final timestamp = chatData['timestamp'];

          if (preview != null && timestamp != null) {
            final parsedDate = DateTime.tryParse(timestamp);
            if (parsedDate != null) {
              final dateKey = DateFormat('yyyy-MM-dd').format(parsedDate);
              final displayDate = DateFormat('d MMMM').format(parsedDate);

              if (!groupedPreviews.containsKey(dateKey)) {
                groupedPreviews[dateKey] = [];
              }

              groupedPreviews[dateKey]!.add({
                'chatId': chatId,
                'preview': preview,
                'displayDate': displayDate,
              });
            }
          }
        });
      }
///////////////////////////////////
      allChats.forEach((chatId, chatMessages) {
        final List messages = chatMessages;

        final userMsg = messages.firstWhere(
          (msg) => msg['sender'] == 'user' && msg['timestamp'] != null,
          orElse: () => null,
        );

        if (userMsg != null) {
          final text = userMsg['text'] ?? '';
          final timestamp = userMsg['timestamp'];
          final preview = prefs.getString('_preview_$chatId') ?? text.split(' ').take(10).join(' ');

          final parsedDate = DateTime.parse(timestamp);
          final dateKey = DateFormat(
            'yyyy-MM-dd',
          ).format(parsedDate); // للتجميع
          final displayDate = DateFormat(
            'd MMMM',
          ).format(parsedDate); // ← لعرض "21 April"

          if (!groupedPreviews.containsKey(dateKey)) {
            groupedPreviews[dateKey] = [];
          }

          groupedPreviews[dateKey]!.add({
            'chatId': chatId,
            'preview': preview,
            'displayDate': displayDate, // ← أضفنا ده هنا
          });
        } else {
          print("⛔️ Skipping chat [$chatId] with no timestamp.");
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
            const Divider(indent: 20, endIndent: 25, color: Color(0XFF99B5DD)),
            _buildSectionTitle('History'),
            ...groupedPreviews.entries.expand(
                  (entry) {
                final filtered = entry.value.where((chat) =>
                    chat['preview']!.toLowerCase().contains(searchKeyword)).toList();

                if (filtered.isEmpty) return [];

                return [
                  _buildDateGroup(entry.value.first['displayDate'] ?? entry.key),
                  ...filtered.map(_buildItem),
                ];
              },
            ),
            const Divider(indent: 20, endIndent: 25, color: Color(0XFF99B5DD)),
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
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Image.asset('assets/images/historyIcon.png'),
              ),

              if (showSearchField)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, right: 4),
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        setState(() {
                          searchKeyword = value.toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search chats...',
                        filled: true,
                        fillColor: const Color(0xffF0F8FF),
                        hintStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0x800047ab), width: 1.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xff99B5DF), width: 1.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                )
              else
                const Spacer(), // 💡 علشان تسيب مساحة لما الـ TextField مش ظاهر
              IconButton(
                onPressed: () {
                  setState(() {
                    showSearchField = !showSearchField;
                    if (!showSearchField) {
                      searchController.clear();
                      searchKeyword = '';
                      _loadChatList(); // reload full list
                    }
                  });
                },
                icon: Image.asset('assets/images/search.png'),
              ),
            ],
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Image.asset('assets/images/appicon.png', width: 45, height: 45),
              SizedBox(width: 5),
              TextAuth(
                text: 'Genio AI',
                size: 18,
                fontWeight: FontWeight.w600,
                color: Color(0XFF0047AB),
              ),
            ],
          ),
        ],
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

          final raw = prefs.getString('local_chats_preview');
          String? type;

          if (raw != null) {
            final Map<String, dynamic> previews = json.decode(raw);
            type = previews[chat['chatId']]?['type'];
          }

          Navigator.of(context).pop();

          if (type == 'image') {
            Navigator.pushReplacementNamed(context, 'ImageGeneration', arguments: chat['chatId']);
          } else if (type == 'code') {
            Navigator.pushReplacementNamed(context, 'CodeGenerator', arguments: chat['chatId']);
          }else if (type == 'email') {
            Navigator.pushReplacementNamed(context, 'EmailWriter', arguments: chat['chatId']);
          }else if (type == 'summary') {
            Navigator.pushReplacementNamed(context, 'TextSummarizer', arguments: chat['chatId']);
          } else if (type == 'essay') {
            Navigator.pushReplacementNamed(context, 'EssayWriter', arguments: chat['chatId']);
          } else {
            Navigator.pushReplacementNamed(context, NewChatBot.routeName);
          }
        }
      /*onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('chatId', chat['chatId']!);
        Navigator.of(context).pop();
        Navigator.pushReplacementNamed(context, NewChatBot.routeName);
      },
       */
    );
  }

  Widget _buildUserInfo() {
    return FutureBuilder<String>(
      future: _getUserNameFromAPI(),
      builder: (context, snapshot) {
        final userName = snapshot.data ?? 'User';
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: profileImageUrl != null
                  ? NetworkImage(profileImageUrl!)
                  : const AssetImage('assets/images/img.png') as ImageProvider,
            ),
            title: TextAuth(
              text: userName,
              size: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0XFF0047AB),
            ),
          ),
        );
      },
    );
  }

  Future<String> _getUserNameFromAPI() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) return 'User';

    final response = await http.get(
      Uri.parse('https://back-end-api.genio.ae/api/user/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final name = data['name'] ?? 'User';
      return name;
    } else {
      return 'User';
    }
  }
}
// header
// IconButton(
//   onPressed: () {},
//   icon: const ImageIcon(
//     AssetImage('assets/images/edit.png'),
//     color: Color(0xff0047AB),
//     size: 24,
//   ),
// ),
