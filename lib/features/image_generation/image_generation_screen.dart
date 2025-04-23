import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:genio_ai/features/account/account_settings.dart';
import 'package:genio_ai/features/history/history_screen.dart';
import 'package:genio_ai/features/other_models/other_models.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../login/presentation/widgets/text_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ImageGeneration extends StatefulWidget {
  const ImageGeneration({super.key});
  static String routeName = 'ImageGeneration';

  @override
  State<ImageGeneration> createState() => _ImageGenerationState();
}

class _ImageGenerationState extends State<ImageGeneration> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  String chatHistoryKey = 'image_generation';
  int _freeLimit = 2;
  bool _isPro = false;
  int _imageGenerationCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
      _loadPlanStatus();
    });
  }

  @override
  /*void initState() {
    super.initState();
    _initializeChat();
    //_loadChatIdFromPrefs();
    _loadPlanStatus();
  }
   */

  void _initializeChat() {
    Future.microtask(() async {
      final prefs = await SharedPreferences.getInstance();
      final passedChatId = ModalRoute.of(context)?.settings.arguments;

      if (passedChatId is String) {
        _chatId = passedChatId;
        print("📥 Using chatId from arguments: $_chatId");
      } else {
        _chatId = const Uuid().v4();
        print("🆕 Created new chatId: $_chatId");
      }

      // ✅ دايمًا سجل آخر chatId مفتوح
      await prefs.setString("chatId_image_generation", _chatId!);

      _loadChatHistory();
    });
  }

  Future<void> _loadPlanStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isPro = prefs.getBool("is_pro_user") ?? false;
    _imageGenerationCount = prefs.getInt("image_generation_count") ?? 0;
    setState(() {});
  }

  Future<void> _loadChatIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _chatId = prefs.getString("chatId_image_generation");
    print("📥 Loaded existing chatId from prefs: $_chatId");

    if (_chatId != null) {
      _loadChatHistory();
    } else {
      _chatId = const Uuid().v4();
      await prefs.setString("chatId_image_generation", _chatId!);
      print("🆕 Created fallback chatId: $_chatId");
      _loadChatHistory();
    }
  }

  String? _chatId;
  Future<void> _loadOrCreateChatId() async {
    final prefs = await SharedPreferences.getInstance();
    _chatId = prefs.getString("chatId_image_generation");

    if (_chatId == null || _chatId!.isEmpty) {
      _chatId = const Uuid().v4();
      await prefs.setString("chatId_image_generation", _chatId!);
      print("🆕 Generated chatId: $_chatId");
    } else {
      print("📦 Loaded chatId: $_chatId");
    }
  }

  Future<void> _saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = jsonEncode(_messages);
    await prefs.setString('chat_history_$_chatId', historyJson);
    print("💾 Saving to: chat_history_$_chatId");
  }

  void _sendMessage() async {
    if (_chatId == null) {
      print("⛔ chatId not ready yet.");
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final isPro = prefs.getBool("is_pro_user") ?? false;
    int imageGenerationCount = prefs.getInt("image_generation_count") ?? 0;
    const int freeLimit = 2;

    if (!isPro && imageGenerationCount >= freeLimit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🛑 Free plan limit reached. Upgrade to continue.")),
      );
      return;
    }

    final prompt = _controller.text.trim();
    if (prompt.isEmpty) return;
    await _saveChatPreviewIfNeeded(prompt);

    setState(() {
      _messages.add({"text": prompt, "sender": "user"});
      _controller.clear();
    });
    await _saveChatHistory();
    _scrollToBottom();

    final imageUrl = await generateImageLinkWithGemini(prompt);

    if (imageUrl != null && imageUrl.startsWith("https://image.pollinations.ai")) {
      setState(() {
        _messages.add({"text": imageUrl, "sender": "ai"});
      });
      await _saveChatHistory();

      if (!isPro) {
        imageGenerationCount++;
        await prefs.setInt("image_generation_count", imageGenerationCount);
      }
    } else {
      setState(() {
        _messages.add({"text": "⚠️ Failed to generate image.", "sender": "ai"});
      });
    }

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

  Future<String?> generateImageLinkWithGemini(String prompt) async {
    const apiKey = 'AIzaSyCexovbqoaLZKcO4e2g3OGWyk7i7DADmp0';
    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey",
    );

    final body = {
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text":
              "Generate only a direct image link in this format: https://image.pollinations.ai/prompt/{description}. The description is: $prompt"
            }
          ]
        }
      ],
      "generationConfig": {
        "temperature": 0.7,
        "topK": 40,
        "topP": 0.95,
        "maxOutputTokens": 100,
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
      print("❌ Gemini Error: ${response.body}");
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
    print("📥 Loading from: chat_history_$_chatId");
  }

  Future<void> _saveChatPreviewIfNeeded(String prompt) async {
    final prefs = await SharedPreferences.getInstance();
    final historyRaw = prefs.getString("local_chats_preview");
    Map<String, dynamic> allPreviews = historyRaw != null ? jsonDecode(historyRaw) : {};

    if (!allPreviews.containsKey(_chatId)) {
      allPreviews[_chatId!] = {
        "preview": prompt.split(' ').take(10).join(' '),
        "timestamp": DateTime.now().toIso8601String(),
        "type": "image" // مهم علشان نستخدمه لاحقًا
      };
      await prefs.setString("local_chats_preview", jsonEncode(allPreviews));
      print("📝 Saved image preview: $prompt");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: History(),
      endDrawer: OtherModels(),
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
              onPressed: (){},
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
                text: "Let's turn imagination into visuals",
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
                    text: "Let's turn imagination into visuals",
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
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color(0xff0047AB)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 5)
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _messages[index]['text']!.startsWith("https://image.pollinations.ai")
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(_messages[index]['text']!),
                        )
                            : MarkdownBody(
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
                              icon: const Icon(Icons.copy,
                                  size: 18, color: Colors.grey),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(
                                    text: _messages[index]['text']!));
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "Copied to clipboard!")),
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
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 5)
                ],
              ),
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: "Describe what you want to see...",
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
