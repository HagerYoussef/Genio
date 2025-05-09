import 'package:flutter/material.dart';
import 'package:genio_ai/features/account/account_settings.dart';
import 'package:genio_ai/features/login/presentation/widgets/text_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class CustomerSupportScreen extends StatefulWidget {
  const CustomerSupportScreen({super.key});
  static String routeName = 'Customer support';

  @override
  State<CustomerSupportScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<CustomerSupportScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, String>> _messages = [];

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"text": text, "sender": "user"});
      _messages.add({"text": _getAutoResponse(text), "sender": "bot"});
      _controller.clear();
    });

    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  String _getAutoResponse(String userInput) {
    final input = userInput.toLowerCase();

    if (input.contains("plan") && input.contains("change")) {
      return 'You can change your plan from your Account settings > View plans from upgrade section.';
    } else if (input.contains("payment") || input.contains("pay")) {
      return "We accept Visa.";
    } else if (input.contains("reset") && input.contains("password")) {
      return "Please check our FAQ section.";
    } else if (input.contains("ai") && input.contains("not responding")) {
      return "Please check your internet connection or try refreshing the app.";
    } else if (input.contains("chat") || input.contains("history") || input.contains("save")) {
      return "Your chats are securely stored. You can manage saved chats in your History section.";
    } else if (input.contains("multiple devices") || input.contains("more than one device")) {
      return "Yes, your account can be accessed from any device.";
    } else if (input.contains("data") && (input.contains("privacy") || input.contains("secure"))) {
      return "Absolutely. We follow strict data privacy protocols.";
    } else if (input.contains("email") && input.contains("change")) {
      return "Please check our FAQ section.";
    } else if (input.contains("theme") || input.contains("language")) {
      return "You can change app theme from your account settings.";
    } else if (input.contains("delete") && input.contains("account")) {
      return "To delete your account, go to Account Settings > Security > Delete Account.";
    } else if (input.contains("ai model") || input.contains("which model")) {
      return "We use our AI models to generate intelligent and safe responses.";
    } else if (input.contains("limit") || input.contains("usage")) {
      return "Each user has a daily usage limit. You can check yours under Subscription Details.";
    } else if (input.contains("bug") || input.contains("report")) {
      return "You can report any issue via making call to our support team.";
    } else if (input.contains("suggest") && input.contains("plan")) {
      return "Depends on your times to visit our application, you can choose Plus plan.";
    } else {
      return "Please check your question with our support team via making call.";
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF0F8FF),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(240, 248, 255, 1),
        elevation: 0,
        leading: InkWell(
          onTap: () {
             Navigator.pushNamed(context, AccountSettings.routeName);
          },
          child: Icon(Icons.arrow_back_ios, color: Color(0xff0047AB)),
        ),
        title: TextAuth(
          text: 'Customer Support',
          size: 19,
          fontWeight: FontWeight.w600,
          color: Color(0xff0047AB),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (_messages.isNotEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 16, bottom: 8),
              child: TextAuth(
                text: 'Need help?',
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
                    text: 'Need help?',
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
                final msg = _messages[index];
                final isUser = msg['sender'] == 'user';
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
                          data: msg['text']!,
                          styleSheet: MarkdownStyleSheet(
                            p: GoogleFonts.poppins(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: isUser ? Colors.white : Colors.black,
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
                  hintText: "Type your issue...",
                  hintStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
