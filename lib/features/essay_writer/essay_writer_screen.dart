import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:genio_ai/features/account/account_settings.dart';
import 'package:genio_ai/features/history/history_screen.dart';
import 'package:genio_ai/features/other_models/other_models.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:uuid/uuid.dart';
import '../home_screen/homescreen.dart';
import '../login/presentation/widgets/text_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../upgrade_screen.dart';

class EssayWriter extends StatefulWidget {
  const EssayWriter({super.key});
  static String routeName = 'EssayWriter';

  @override
  State<EssayWriter> createState() => _EssayWriterState();
}

class _EssayWriterState extends State<EssayWriter> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  String? _chatId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.microtask(() async {
      final prefs = await SharedPreferences.getInstance();
      final args = ModalRoute.of(context)?.settings.arguments;

      if (args != null && args is Map && args.containsKey('chatId')) {
        _chatId = args['chatId'];
        await prefs.setString("chat_id_essay", _chatId!);
        print("📥 Using passed chatId for EssayWriter: $_chatId");
      } else {
        _chatId = prefs.getString("chat_id_essay");

        if (_chatId == null || _chatId!.isEmpty) {
          _chatId = const Uuid().v4();
          await prefs.setString("chat_id_essay", _chatId!);
          print("🆕 Created new essay chatId: $_chatId");
        } else {
          print("📦 Loaded saved essay chatId: $_chatId");
        }
      }

      await _loadChatHistory();
    });
  }

  Future<bool> checkEssayLimit(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final isProUser = prefs.getBool('is_pro_user') ?? false;
    final usage = prefs.getInt('essay_ai_usage') ?? 0;

    print("📊 Essay Usage: $usage | isProUser: $isProUser");

    if (isProUser) return true;

    if (usage >= 2) {
      await QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: "Limit Reached",
        text: "You've reached the free usage limit. Please subscribe to continue.",
        confirmBtnText: 'Subscribe Now',
        confirmBtnColor: const Color(0xFF0047AB),
        confirmBtnTextStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Colors.white,
        ),
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
          Navigator.pushNamed(context, UpgradeScreen.routeName);
        },
      );
      return false;
    }

    await prefs.setInt('essay_ai_usage', usage + 1);
    return true;
  }


  Future<void> _loadChatIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _chatId = prefs.getString("chat_id_essay");

    if (_chatId == null || _chatId!.isEmpty) {
      _chatId = const Uuid().v4();
      await prefs.setString("chat_id_essay", _chatId!);
    }
    _loadChatHistory();
  }

  Future<void> _saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = jsonEncode(_messages);
    await prefs.setString('chat_history_$_chatId', historyJson);
  }

  void _sendMessage() async {
    final allowed = await checkEssayLimit(context);
    if (!allowed) return;

    if (_chatId == null) return;

    final prompt = _controller.text.trim();
    if (prompt.isEmpty) return;

    await _saveChatPreviewIfNeeded(prompt);

    setState(() {
      _messages.add({"text": prompt, "sender": "user"});
      _controller.clear();
    });
    await _saveChatHistory();
    _scrollToBottom();

    final essayResponse = await generateEssayWithGemini(prompt);

    setState(() {
      _messages.add({"text": essayResponse ?? "⚠️ Failed to generate essay.", "sender": "ai"});
    });
    await _saveChatHistory();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<String?> generateEssayWithGemini(String prompt) async {
    const apiKey = 'AIzaSyCexovbqoaLZKcO4e2g3OGWyk7i7DADmp0';
    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey",
    );

    final body = {
      "contents": [
        {
          "role": "user",
          "parts": [
            {"text": "Write a well-structured essay about the following topic:\n\n$prompt"}
          ]
        }
      ],
      "generationConfig": {
        "temperature": 0.7,
        "topK": 40,
        "topP": 0.95,
        "maxOutputTokens": 1024,
      }
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
      return text?.trim();
    } else {
      return null;
    }
  }

  Future<void> _loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('chat_history_$_chatId');
    if (historyJson != null) {
      final List decoded = jsonDecode(historyJson);
      setState(() {
        _messages = decoded.map<Map<String, String>>((item) {
          return {
            "text": item["text"].toString(),
            "sender": item["sender"].toString(),
          };
        }).toList();
      });
    }
  }

  Future<void> _saveChatPreviewIfNeeded(String prompt) async {
    final prefs = await SharedPreferences.getInstance();
    final historyRaw = prefs.getString("local_chats_preview");
    Map<String, dynamic> allPreviews = historyRaw != null ? jsonDecode(historyRaw) : {};

    if (!allPreviews.containsKey(_chatId)) {
      allPreviews[_chatId!] = {
        "preview": prompt.split(' ').take(10).join(' '),
        "timestamp": DateTime.now().toIso8601String(),
        "type": "essay"
      };
      await prefs.setString("local_chats_preview", jsonEncode(allPreviews));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.pushReplacementNamed(context, HomeScreen.routeName); // أو '/main'
        }
      },
      child: Scaffold(
        drawer: const History(),
        endDrawer: const OtherModels(),
        backgroundColor: const Color(0xffF0F8FF),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(85),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xffF0F8FF),
            elevation: 0,
            title: Builder(
              builder: (context) => Row(
                children: [
                  IconButton(
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    icon: const ImageIcon(
                      AssetImage('assets/images/menu.png'),
                      color: Color(0xff0047AB),
                    ),
                  ),
                  Image.asset('assets/images/Group.png', height: 30),
                  const SizedBox(width: 8),
                  const TextAuth(
                    text: 'Genio AI',
                    size: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff0047AB),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const ImageIcon(
                  AssetImage('assets/images/flash.png'),
                  color: Color(0xff0047AB),
                ),
                onPressed: () {},
              ),
              Builder(
                builder: (context) => IconButton(
                  icon: const ImageIcon(
                    AssetImage('assets/images/edit.png'),
                    color: Color(0xff0047AB),
                  ),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, AccountSettings.routeName);
                },
                icon: const ImageIcon(
                  AssetImage('assets/images/menu_vector.png'),
                  color: Color(0xff0047AB),
                  size: 24,
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                color: const Color(0xff0047AB),
                height: 0.5,
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            if (_messages.isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 16, bottom: 8),
                child: TextAuth(
                  text: 'What essay do you want to write?',
                  size: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff0047AB),
                ),
              ),
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const TextAuth(
                      text: 'What essay do you want to write?',
                      size: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff0047AB),
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(),
                  ],
                ),
              )
                  : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  bool isUser = _messages[index]['sender'] == 'user';
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: isUser ? const Color(0xff0047AB) : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MarkdownBody(
                            data: _messages[index]['text']!,
                            styleSheet: MarkdownStyleSheet(
                              p: GoogleFonts.poppins(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: isUser ? Colors.white : Colors.black,
                              ),
                              strong: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (!isUser)
                            Align(
                              alignment: Alignment.bottomRight,
                              child: IconButton(
                                icon: const Icon(Icons.copy, size: 18, color: Colors.grey),
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: _messages[index]['text']!),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Copied to clipboard!")),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_messages.isNotEmpty) _buildInputField(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 7),
            decoration: BoxDecoration(
              color: const Color(0xff0047AB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: _sendMessage,
              icon: const ImageIcon(
                AssetImage('assets/images/link.png'),
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xffD4EBFF),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
              ),
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: "Describe the essay topic...",
                  hintStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  border: InputBorder.none,
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 7),
            decoration: BoxDecoration(
              color: const Color(0xff0047AB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: _sendMessage,
              icon: const ImageIcon(
                AssetImage('assets/images/send.png'),
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
