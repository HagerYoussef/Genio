import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:genio_ai/features/account/account_settings.dart';
import 'package:genio_ai/features/history/history_screen.dart';
import 'package:genio_ai/features/other_models/other_models.dart';
import 'package:genio_ai/features/upgrade_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:uuid/uuid.dart';
import '../home_screen/homescreen.dart';
import '../login/presentation/widgets/text_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ImageGeneration extends StatefulWidget {
  const ImageGeneration({super.key});
  static String routeName = 'ImageGeneration';

  @override
  State<ImageGeneration> createState() => _ImageGenerationState();
}

class _ImageGenerationState extends State<ImageGeneration> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  late IO.Socket _socket;
  String? _chatId;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadOrCreateChatId();
    _connectToServer();
  }

  Future<void> _loadOrCreateChatId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("userId");
    final token = prefs.getString("Token");
    _chatId = prefs.getString("chatId_image_generation");

    if (_chatId == null || _chatId!.isEmpty) {
      _chatId = const Uuid().v4();
      await prefs.setString("chatId_image_generation", _chatId!);
    }

    if (userId != null && token != null) {
      try {
        final response = await http.get(
          Uri.parse("https://back-end-api.genio.ae/api/user/chat/$_chatId"),
          headers: {"Authorization": "Bearer $token"},
        );
        if (response.statusCode == 200) {
          final List data = jsonDecode(response.body);
          setState(() {
            _messages.clear();
            for (var chat in data) {
              _messages.add({"text": chat['question'], "sender": "user"});
              _messages.add({"text": chat['answer'], "sender": "ai"});
            }
          });
        }
      } catch (e) {
        debugPrint("❌ Error loading chat: $e");
      }
    }
  }

  void _connectToServer() {
    _socket = IO.io(
      'wss://back-end-api.genio.ae',
      <String, dynamic>{'transports': ['websocket'], 'autoConnect': false},
    );
    _socket.connect();

    _socket.onConnect((_) => print('✅ Connected to server'));

    _socket.on("aiMessage", (data) async {
      print('🤖 AI Response: $data');
      String message;
      if (data is List && data.isNotEmpty) {
        message = data[0].toString();
      } else if (data is String) {
        message = data;
      } else if (data is Map && data.containsKey('error')) {
        message = "⚠️ ${data['error']}";
      } else {
        message = data.toString();
      }
      final parsed = await _handleAiMessage(message);
      setState(() => _messages.add({"text": parsed, "sender": "ai"}));
      _scrollToBottom();
    });

    _socket.onDisconnect((_) => print("🔴 Disconnected from WebSocket server"));
    _socket.on("connect_error", (err) => print("⚠️ Connection Error: $err"));
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty || _chatId == null) return;
    final message = _controller.text.trim();
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? "flutter_user";
    _socket.emit("userMessage", [message, userId, _chatId]);
    setState(() {
      _messages.add({"text": message, "sender": "user"});
      _controller.clear();
    });
    _scrollToBottom();
  }

  Future<String> _handleAiMessage(String message) async {
    final markdownImageRegex = RegExp(r'!\[.*?\]\((.*?)\)');
    final match = markdownImageRegex.firstMatch(message);
    if (match != null) {
      return match.group(1)!;
    }

    final imageNameRegex = RegExp(r'(\d+\.png)');
    final imageMatch = imageNameRegex.firstMatch(message);
    if (imageMatch != null) {
      final fileName = imageMatch.group(1)!;
      return 'https://back-end-api.genio.ae/chatImage/$fileName';
    }

    return message;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.pushReplacementNamed(context, HomeScreen.routeName);
        }
      },
      child: Scaffold(
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
                  text: 'Describe what you want to see...',
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
                      text: 'What can I help with?',
                      size: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff0047AB),
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(),
                  ],
                ),
              )
                  :ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isImage = msg["text"] != null &&
                      Uri.tryParse(msg["text"]!)?.isAbsolute == true &&
                      (msg["text"]!.endsWith(".png") ||
                          msg["text"]!.endsWith(".jpg") ||
                          msg["text"]!.endsWith(".jpeg"));

                  return Align(
                    alignment: msg["sender"] == "user"
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: msg["sender"] == "user" ? const Color(0xff0047AB) : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          isImage
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              msg["text"]!,
                              errorBuilder: (context, error, stackTrace) => const Text("❌ Image not found"),
                            ),
                          )
                              : MarkdownBody(
                            data: msg["text"] ?? "",
                            styleSheet: MarkdownStyleSheet(
                              p: GoogleFonts.poppins(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: msg["sender"] == "user" ? Colors.white : Colors.black,
                              ),
                              strong: const TextStyle(fontWeight: FontWeight.bold),
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
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 5)
                ],
              ),
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _sendMessage(),
                minLines: 1,
                maxLines: null,
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
