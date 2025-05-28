import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:genio_ai/features/account/account_settings.dart';
import 'package:genio_ai/features/home_screen/homescreen.dart';
import 'package:genio_ai/features/login/presentation/widgets/text_auth.dart';
import 'package:genio_ai/features/payment/payment_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class UpgradeScreen extends StatefulWidget {
  static String routeName = 'upgrade screen';

  UpgradeScreen({super.key});

  @override
  State<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  String? _from;
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken') ?? prefs.getString('token');
  }


  Future<Map<String, dynamic>?> fetchUserProfile() async {
    final token = await getAccessToken();
    print("Token before request: $token");

    final response = await http.get(
      Uri.parse("https://back-end-api.genio.ae/api/user/profile"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
    );

    print("Profile fetch status: ${response.statusCode}");
    print(response.body);

    if (response.statusCode == 200) {
      setState(() {
        userData = jsonDecode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }

    return userData;
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _from = args['from'];
    }
  }

  Future<Map<String, dynamic>> makePaymentRequest({
    required String plan,
    required String userId,
    required String email,
    required String firstName,
    required String lastName,
    required String countryCode,
    required String phone,
    required String currency,
    String? voucher,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("accessToken") ?? prefs.getString("token") ?? "";

    final uri = Uri.parse('https://back-end-api.genio.ae/api/payment');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = {
      "plan": plan,
      "userId": userId,
      "email": email,
      "firstname": firstName,
      "lastname": lastName,
      "countrycode": countryCode,
      "phone": phone,
      "currency": currency,
      if (voucher != null) "voucher": voucher,
    };

    print("Request Headers: $headers");

    final response = await http.post(uri, headers: headers, body: jsonEncode(body));
    print("Payment API status: ${response.statusCode}");
    print("Payment API body: ${response.body}");

    final jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200) return jsonResponse;
    return {"error": jsonResponse["error"] ?? response.body};
  }

  Future<Map<String, String?>> getAuthInfo() async {
    final prefs = await SharedPreferences.getInstance();

    final accessToken = prefs.getString('accessToken');
    final googleToken = prefs.getString('token');
    final userIdFromPrefs = prefs.getString('userId');

    String? token = accessToken ?? googleToken;
    String? userId;

    if (googleToken != null) {
      try {
        final parts = googleToken.split('.');
        if (parts.length == 3) {
          final payload = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
          userId = payload['uid'];
        }
      } catch (e) {
        print("❌ Failed to decode Google JWT: $e");
      }
    }
    userId ??= userIdFromPrefs;
    return {
      'token': token,
      'userId': userId,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(240, 248, 255, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(240, 248, 255, 1),
        elevation: 0,
        leading: InkWell(
          onTap: () {
            if (_from == "home") {
              Navigator.pushReplacementNamed(context, HomeScreen.routeName);
            } else if (_from == "account") {
              Navigator.pushReplacementNamed(context, AccountSettings.routeName);
            } else {
              Navigator.pushReplacementNamed(context, HomeScreen.routeName);
            }
            //Navigator.pushNamed(context, HomeScreen.routeName);
          },
          child: Icon(Icons.arrow_back_ios, color: Color(0xff0047AB)),
        ),
        title: TextAuth(
          text: 'Upgrade',
          size: 19,
          fontWeight: FontWeight.w600,
          color: Color(0xff0047AB),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              PricingCard(
                title: "Free",
                price: "0",
                planTitle: "Try Genio AI with limited access to tools",
                planBtnText: 'Get Free',
                text1: '2 AI chat messages per month',
                text2: '2 image generations',
                text3:
                    'Essay Writer: Generate up to 2 essays/day (max 800 words each)',
                text4:
                    "Code Generator: 2 code generations/day (basic level only)",
                text5:
                    "Email Writer: Write up to 2 emails/day (no templates)",
                text6: "Basic summarization (up to 200 words)",
                btnColor: Color(0xff4D7EC4),
                onPressed: () async {
                  /*final token = await getAccessToken();
                  print(token);

                  final prefs = await SharedPreferences.getInstance();
                  final userId = prefs.getString("userId") ?? "";
                  if (userId.isEmpty) {
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.error,
                      title: "Error",
                      text: "User info missing. Please log in again.",
                    );
                    return;
                  }

                  userData ??= await fetchUserProfile();
                  if (userData == null) {
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.error,
                      title: "Error",
                      text: "Could not load user profile.",
                    );
                    print("Could not load user profile.");
                    return;
                  }
                  final response = await makePaymentRequest(
                    plan: "free",
                    userId: userId,
                    voucher: null,
                    email: userData!["email"],
                    firstName: userData!["name"].split(" ").first,
                    lastName: userData!["name"].split(" ").last,
                    countryCode: userData!["countrycode"],
                    phone: userData!["phone"],
                    currency: "EGP",
                  );

                  if (response["redirectUrl"] != null) {
                    launchUrl(Uri.parse(response["redirectUrl"]), mode: LaunchMode.externalApplication);
                  } else {
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.error,
                      title: "Error",
                      text: response["error"] ?? "Unknown error",
                    );
                  }
                   */
                },
              ),
              SizedBox(height: 20),
              PricingCard(
                title: "Plus",
                price: "20",
                planTitle: "Enhanced access to all AI tools",
                planBtnText: 'Get Plus',
                text1: '500 AI chat messages per month',
                text2: '50 image generations',
                text3: 'Essay Writer: 20 essays/month (up to 1200 words)',
                text4: "Code Generator: 30 code generations (standard level)",
                text5: "Email Writer: 50 emails/month with access to smart templates",
                text6: "Advanced summarization (up to 2000 words)",
                btnColor: Color(0xff40047AB),
                onPressed: () async {

                  final authInfo = await getAuthInfo();
                  final token = authInfo['token'];
                  final userId = authInfo['userId'] ?? "";

                  if (userId.isEmpty) {
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.error,
                      title: "Error",
                      text: "User ID not found. Please log in again.",
                    );
                    return;
                  }

                  userData ??= await fetchUserProfile();
                  if (userData == null) {
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.error,
                      title: "Error",
                      text: "Could not load user profile.",
                    );
                    return;
                  }

                  final phone = userData!["phone"] ?? "0000000000";
                  final countryCode = userData!["countrycode"] ?? "+20";
                  final email = userData!["email"] ?? "example@email.com";
                  final fullName = userData!["name"] ?? "User Name";

                  final firstName = fullName.split(" ").first;
                  final lastName = fullName.split(" ").length > 1
                      ? fullName.split(" ").sublist(1).join(" ")
                      : "User";

                  print("📤 Sending payment request with:");
                  print("📞 $phone | 🌍 $countryCode | 👤 $firstName $lastName");


                  final response = await makePaymentRequest(
                    plan: "plus",
                    userId: userId,
                    voucher: null,
                    email: email,
                    firstName: firstName,
                    lastName: lastName,
                    countryCode: countryCode,
                    phone: phone,
                    currency: "EGP",
                  );

                  if (response["redirectUrl"] != null) {
                    launchUrl(Uri.parse(response["redirectUrl"]),
                        mode: LaunchMode.externalApplication);
                  } else {
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.error,
                      title: "Error",
                      text: response["error"] ?? "Unknown error",
                    );
                  }
                },
              ),
              SizedBox(height: 20),
              PricingCard(
                title: "Super Plus",
                price: "200",
                planTitle: "Full power of Genio AI without limits",
                planBtnText: 'Get Pro',
                text1: 'Unlimited AI chat messages',
                text2: 'Unlimited image generations',
                text3: 'Essay Writer: Unlimited essays (up to 3000 words)',
                text4: "Code Generator: Unlimited with smart debugging & suggestions",
                text5: "Email Writer: Unlimited with tone & formatting control",
                text6: "Summarizer: Pro-level (up to 10,000 words, structured output)",
                btnColor: Color(0xff4DC4BE),
                onPressed: () async {
                  final token = await getAccessToken();
                  print(token);
                  final prefs = await SharedPreferences.getInstance();
                  final userId = prefs.getString("userId") ?? "";
                  if (userId.isEmpty) {
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.error,
                      title: "Error",
                      text: "User info missing. Please log in again.",
                    );
                    return;
                  }

                  userData ??= await fetchUserProfile();
                  if (userData == null) {
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.error,
                      title: "Error",
                      text: "Could not load user profile.",
                    );
                    print("Could not load user profile.");
                    return;
                  }

                  final response = await makePaymentRequest(
                    plan: "superplus",
                    userId: userId, // ✅ استخدم القيمة الفعلية
                    voucher: null,
                    email: userData!["email"],
                    firstName: userData!["name"].split(" ").first,
                    lastName: userData!["name"].split(" ").last,
                    countryCode: userData!["countrycode"],
                    phone: userData!["phone"],
                    currency: "EGP",
                  );

                  if (response["redirectUrl"] != null) {
                    launchUrl(Uri.parse(response["redirectUrl"]), mode: LaunchMode.externalApplication);
                  } else {
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.error,
                      title: "Error",
                      text: response["error"] ?? "Unknown error",
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PricingCard extends StatelessWidget {
  final String title;
  final String price;
  final String planTitle;
  final String planBtnText;
  final String text1;
  final String text2;
  final String text3;
  final String text4;
  final String text5;
  final String text6;
  final Color btnColor;
  final VoidCallback onPressed;

  PricingCard({
    required this.title,
    required this.price,
    required this.planTitle,
    required this.planBtnText,
    required this.text1,
    required this.text2,
    required this.text3,
    required this.text4,
    required this.text5,
    required this.text6,
    required this.btnColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 0),
            ),
          ],
        color: Color(0xFFE6F0FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color.fromRGBO(149, 186, 230, 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextAuth(
            text: title,
            size: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextAuth(
                text: '\$',
                size: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xff80A3D5),
              ),
              TextAuth(
                text: price,
                size: 32,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextAuth(
                      text: 'USD/',
                      size: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff80A3D5),
                    ),
                    TextAuth(
                      text: 'Month',
                      size: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff80A3D5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          TextAuth(
            text: planTitle,
            size: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xff80A3D5),
          ),
          SizedBox(height: 15),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: btnColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: Size(double.infinity, 45),
            ),
            child: TextAuth(
              text: planBtnText,
              size: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    ImageIcon(
                      AssetImage('assets/images/right.png'),
                      color: Color(0xff344054),
                      size: 18,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextAuth(
                        text: text1,
                        size: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff344054),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    ImageIcon(
                      AssetImage('assets/images/right.png'),
                      color: Color(0xff344054),
                      size: 18,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextAuth(
                        text: text2,
                        size: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff344054),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    ImageIcon(
                      AssetImage('assets/images/right.png'),
                      color: Color(0xff344054),
                      size: 18,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextAuth(
                        text: text3,
                        size: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff344054),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    ImageIcon(
                      AssetImage('assets/images/right.png'),
                      color: Color(0xff344054),
                      size: 18,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextAuth(
                        text: text4,
                        size: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff344054),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    ImageIcon(
                      AssetImage('assets/images/right.png'),
                      color: Color(0xff344054),
                      size: 18,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextAuth(
                        text: text5,
                        size: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff344054),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    ImageIcon(
                      AssetImage('assets/images/right.png'),
                      color: Color(0xff344054),
                      size: 18,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextAuth(
                        text: text6,
                        size: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff344054),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          GestureDetector(
            onTap: () async {
              try {
                final prefs = await SharedPreferences.getInstance();
                final token = prefs.getString("accessToken") ?? "";


                final response = await http.get(
                  Uri.parse("https://back-end-api.genio.ae/api/user/currentplan"),
                  headers: {
                    "Authorization": "Bearer $token",
                    "Content-Type": "application/json"
                  },
                );

                if (response.statusCode == 200) {
                  final data = jsonDecode(response.body);
                  final plan = data["plan"];
                  print(plan);
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.info,
                    title: "Current Plan",
                    text: "Your current plan is: $plan",
                  );
                } else {
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.error,
                    title: "Error",
                    text: "Failed to fetch current plan",
                  );
                }
              } catch (e) {
                QuickAlert.show(
                  context: context,
                  type: QuickAlertType.error,
                  title: "Exception",
                  text: e.toString(),
                );
              }
            },
            child: Text(
              'Have an existing plan? See billing here',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w400,
                fontSize: 14.4,
                color: Color(0xff6691CD),
              ),
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
