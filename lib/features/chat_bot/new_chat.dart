import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:genio_ai/features/account/account_settings.dart';
import 'package:genio_ai/features/history/history_screen.dart';
import 'package:genio_ai/features/home_screen/homescreen.dart';
import 'package:genio_ai/features/other_models/other_models.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:uuid/uuid.dart';
import 'dart:convert';
import '../login/presentation/widgets/text_auth.dart';
import '../upgrade_screen.dart';

class NewChatBot extends StatefulWidget {
  static String routeName = 'NewChatBot';
  final bool startNewChat;
  const NewChatBot({Key? key, this.startNewChat = false}) : super(key: key);

  @override
  _ChatBotState createState() => _ChatBotState();
}

class _ChatBotState extends State<NewChatBot> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  late IO.Socket _socket;
  String? _userId;
  String? _chatId;
  final ScrollController _scrollController = ScrollController();
  int _chatbotCount = 0;
  final int _chatbotLimit = 5;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString("userId");

      if (_userId == null) {
        print("❌ userId is null");
        return;
      }

      _chatId = prefs.getString("chatId_chatbot");

      if (_chatId == null) {
        _chatId = const Uuid().v4();
        await prefs.setString("chatId_chatbot", _chatId!);

        final raw = prefs.getString('local_chats');
        Map<String, dynamic> allChats = raw != null ? json.decode(raw) : {};
        allChats[_chatId!] = []; // ✅ حفظ محادثة فاضية
        await prefs.setString('local_chats', json.encode(allChats));

        print("🆕 Created new chatId: $_chatId");
      } else {
        print("📦 Loaded existing chatId: $_chatId");
      }

      await _loadChatMessages();
      _connectToServer();
    });
  }

  Future<void> _handleArgumentsAndInitChat() async {
    final prefs = await SharedPreferences.getInstance();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final from = args?['from'];
    final passedChatId = args?['chatId'];
    _userId = prefs.getString("userId");

    if (_userId == null) {
      print("❌ userId is null");
      return;
    }

    if (from == "home") {
      final raw = prefs.getString('local_chats');
      if (raw != null) {
        final Map<String, dynamic> allChats = json.decode(raw);
        if (allChats.isNotEmpty) {
          _chatId = allChats.keys.last;
          print("📦 Resuming last chat: $_chatId");
        }
      }
      if (_chatId == null) {
        _chatId = const Uuid().v4();
        await prefs.setString("chatId_chatbot", _chatId!);
        print("🆕 Started new chat because no previous chat found: $_chatId");

        // ✅ ضيف السطر ده عشان يحفظ الشات الجديد فورا
        final raw = prefs.getString('local_chats');
        Map<String, dynamic> allChats = raw != null ? json.decode(raw) : {};
        allChats[_chatId!] = []; // محادثة فاضية
        await prefs.setString('local_chats', json.encode(allChats));
      }
    } else {
      // فتح من مكان تاني → استخدم chatId اللي اتبعت
      if (passedChatId != null) {
        _chatId = passedChatId;
        prefs.getString('chatId_chatbot');
        print("🆕 Started new chat from other screen: $_chatId");
      } else {
        // احتياطي لو مفيش chatId
        _chatId = const Uuid().v4();
        await prefs.setString("chatId", _chatId!);
        print("🆕 Started new fallback chat: $_chatId");
      }
    }

    await _loadChatMessages();
    _connectToServer();
  }

  /*Future<void> _initOrResumeChat() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString("userId");

    if (_userId == null) {
      print("❌ userId is null");
      return;
    }

    _chatId = prefs.getString("chatId");

    if (_chatId == null) {
      _chatId = const Uuid().v4();
      await prefs.setString("chatId", _chatId!);
      print("🆕 Started new chat with ID: $_chatId");
    } else {
      print("📦 Resuming chat: $_chatId");
    }

    _connectToServer();
    _loadChatMessages();
  }
   */
  Future<void> _initOrResumeChat() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString("userId");

    if (_userId == null) {
      print("❌ userId is null");
      return;
    }

    final raw = prefs.getString('local_chats');
    if (raw != null) {
      final Map<String, dynamic> allChats = json.decode(raw);
      if (allChats.isNotEmpty) {
        // لو فيه محادثات محفوظة
        _chatId = allChats.keys.last; // آخر شات محفوظ
        print("📦 Resuming last chat: $_chatId");
      }
    }

    if (_chatId == null) {
      // لو مفيش أي محادثة سابقة
      _chatId = const Uuid().v4();
      await prefs.setString("chatId", _chatId!);
      print("🆕 Started new chat with ID: $_chatId");
    }

    await _loadChatMessages();
    _connectToServer();
  }


  Future<void> _setupUserSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString("userId");

    if (_userId == null) {
      print("❌ userId is null");
      return;
    }

    _chatId = prefs.getString("chatId");
    if (_chatId == null) {
      _chatId = const Uuid().v4();
      await prefs.setString("chatId", _chatId!);
      print("🆕 Generated chatId: $_chatId");
    } else {
      print("📦 Loaded chatId: $_chatId");
    }

    _connectToServer();
    _loadChatMessages();
  }

  Future<void> _createNewChat() async {
    final prefs = await SharedPreferences.getInstance();
    _chatId = const Uuid().v4();

    final raw = prefs.getString('local_chats');
    Map<String, dynamic> allChats = raw != null ? json.decode(raw) : {};
    allChats[_chatId!] = [];
    await prefs.setString('local_chats', json.encode(allChats));
    await prefs.setString('chatId_chatbot', _chatId!);

    _messages.clear();
    setState(() {});
  }

  Future<void> _saveMessagesLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString("local_chats");
    Map<String, dynamic> allChats = raw != null ? json.decode(raw) : {};

    if (_chatId != null) {
      allChats[_chatId!] = _messages;
      await prefs.setString("local_chats", json.encode(allChats));
    }
  }

  Future<void> _loadChatMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('local_chats');
      if (raw != null && _chatId != null) {
        final Map<String, dynamic> allChats = json.decode(raw);
        final List<dynamic>? chatMessages = allChats[_chatId];
        if (chatMessages != null) {
          for (var msg in chatMessages) {
            _messages.add({
              'text': msg['text'],
              'sender': msg['sender'],
            });
          }
          setState(() {});
          Future.delayed(Duration.zero, _scrollToBottom);
        }
      } else {
        print("📭 No messages found for chatId: $_chatId");
      }
    } catch (e) {
      print('❌ Error loading messages: $e');
    }
  }

  Future<bool> checkChatLimit(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final isProUser = prefs.getBool('is_pro_user') ?? false;
    final usage = prefs.getInt('chat_ai_usage') ?? 0;

    print("📊 ChatBot Usage: $usage | isProUser: $isProUser");

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

    await prefs.setInt('chat_ai_usage', usage + 1);
    return true;
  }


  void _connectToServer() {
    _socket = IO.io(
      'wss://back-end-api.genio.ae',
      <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      },
    );

    _socket.connect();

    _socket.onConnect((_) {
      print('✅ Connected to server');
    });

    _socket.on("aiMessage", (data) {
      print('🤖 AI Response: $data');
      String message;

      if (data is String) {
        message = data;
      } else if (data is Map && data.containsKey('error')) {
        message = "⚠️ ${data['error']}";
      } else {
        message = json.encode(data);
      }

      setState(() {
        _messages.add({
          "text": message,
          "sender": "ai",
          "timestamp": DateTime.now().toIso8601String(), // ✅ تاريخ الرد
        });
      });

      _saveMessagesLocally();
      Future.delayed(Duration.zero, _scrollToBottom);
    });

    _socket.on("disconnect", (_) {
      print("🔴 Disconnected from WebSocket server");
    });

    _socket.on("connect_error", (err) {
      print("⚠️ Connection Error: $err");
    });
  }

  void _sendMessage() async{
    final allowed = await checkChatLimit(context);
    if (!allowed) return;

    if (_controller.text.trim().isEmpty || _userId == null || _chatId == null) {
      print("⚠️ Cannot send message: Missing data");
      return;
    }

    final message = _controller.text.trim();
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('_preview_$_chatId')) {
      final preview = message.split(' ').take(10).join(' ');
      final timestamp = DateTime.now().toIso8601String();
      await prefs.setString('_preview_$_chatId', preview);
      await prefs.setString('_preview_time_$_chatId', timestamp);
    }

    _socket.emit("userMessage", [message, _userId, _chatId]);


    setState(() {
      _messages.add({
        "text": message,
        "sender": "user",
        "timestamp": DateTime.now().toIso8601String()
      });
      _controller.clear();
      _scrollToBottom();
    });

    _saveMessagesLocally();
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
          Navigator.pushReplacementNamed(context, HomeScreen.routeName); // أو '/main'
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
                onPressed: () => _createNewChat(),
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
                  AssetImage('assets/images/menu_vector.png')
                  ,color: Color(0xff0047AB),size: 24,),
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
                  text: 'What can I help with?',
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
                          MarkdownBody(
                            data: _messages[index]['text']!,
                            styleSheet: MarkdownStyleSheet(
                              p: GoogleFonts.poppins(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color:
                                isUser ? Colors.white : Colors.black,
                              ),
                              strong: const TextStyle(
                                  fontWeight: FontWeight.bold),
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
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: "Message Genio AI",
                  hintStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
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