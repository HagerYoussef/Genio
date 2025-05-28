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
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      final response = await http.get(
        Uri.parse('https://back-end-api.genio.ae/api/user/chat'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);

        groupedPreviews.clear();

        for (var chat in data) {
          final String chatId = chat['id'];
          final String preview = chat['name'];
          final String createdAt = chat['createdAt'];

          final parsedDate = DateTime.tryParse(createdAt);
          if (parsedDate == null) continue;

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

        setState(() {
          groupedPreviews = Map.fromEntries(groupedPreviews.entries.toList().reversed);
        });
      } else {
        print('❌ Failed to load chats from API: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error loading chats: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFFD4EBFF),
        child: Column(
          children: [
            _buildHeader(),
            const Divider(indent: 20, endIndent: 25, color: Color(0XFF99B5DD)),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
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
                ],
              ),
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
        /*onTap: () async {
          final chatId = chat['chatId']!;
          Navigator.of(context).pop();
          Navigator.pushReplacementNamed(context, NewChatBot.routeName, arguments: {"chatId": chatId});
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
