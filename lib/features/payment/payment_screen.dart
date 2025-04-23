import 'package:flutter/material.dart';
import 'package:genio_ai/features/home_screen/homescreen.dart';
import 'package:genio_ai/features/login/presentation/widgets/text_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'email_service.dart';

class PaymentScreen extends StatefulWidget {
  static String routeName = 'Payment';
  final String planName;
  final double planPrice;

  const PaymentScreen({
    super.key,
    required this.planName,
    required this.planPrice,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cardholderController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(240, 248, 255, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(240, 248, 255, 1),
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pushNamed(context, HomeScreen.routeName);
          },
          child: Icon(Icons.arrow_back_ios, color: Color(0xff0047AB)),
        ),
        title: Row(
          children: [
            SizedBox(width: 50),
            Image(image: AssetImage('assets/images/Group.png')),
            SizedBox(width: 5),
            TextAuth(
              text: 'Genio AI',
              size: 19,
              fontWeight: FontWeight.w600,
              color: Color(0xff0047AB),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 16),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: TextAuth(
                    text: 'Subscribe to Genio AI ${widget.planName} Subscription',
                    size: widget.planName.toLowerCase().contains('super') ? 14 : 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xffA3A3B5),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextAuth(
                      text: '\$${widget.planPrice.toStringAsFixed(2)}',
                      size: 32,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    TextAuth(
                      text: ' per month',
                      size: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xffA3A3B5),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      print('done');
                      showGenioSubscriptionSummary(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff0047AB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      maximumSize: Size(171, 45),
                    ),
                    child: Row(
                      children: [
                        TextAuth(
                          text: 'View details',
                          size: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        SizedBox(width: 5),
                        ImageIcon(
                          AssetImage('assets/images/arrowdown.png'),
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) => setState(() {}),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  cursorColor: const Color(0xff99B5DD),
                  decoration: InputDecoration(
                    hintText: 'Your email for payment confirmation',
                    hintStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0x800047ab),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0xff99B5DF),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.red, width: 1.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your email';
                    if (!value.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 22),
                TextAuth(
                  text: 'Payment method',
                  size: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                const SizedBox(height: 20),
                TextAuth(
                  text: 'Card information',
                  size: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 110,
                  decoration: BoxDecoration(
                    color: const Color(0xffF0F8FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      width: 1.5,
                      color: const Color(0xff99B5DD),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // الخط الأفقي
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 52, // حسب ارتفاع الحقل الأول
                        child: Container(
                          height: 1.5,
                          color: const Color(0xff99B5DD),
                        ),
                      ),
                      // الخط الرأسي
                      Positioned(
                        top: 52,
                        bottom: 0,
                        left: MediaQuery.of(context).size.width / 2,
                        child: Container(
                          width: 1.5,
                          color: const Color(0xff99B5DD),
                        ),
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 12,
                              right: 12,
                              top: 8,
                            ),
                            child: TextFormField(
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Enter card number';
                                if (value.replaceAll(' ', '').length != 16) return 'Card number must be 16 digits';
                                return null;
                              },
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                hintText: "1234 1234 1234 1234",
                                hintStyle: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                                suffixIcon: ImageIcon(
                                  AssetImage('assets/images/Text.png'),
                                  color: Color(0xff1434CB),
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 50),
                                    child: TextFormField(
                                      keyboardType: TextInputType.phone,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                        color: Colors.black54,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) return 'Enter expiry date';
                                        if (!RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(value)) {
                                          return 'Use MM/YY format';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        hintText: "MM/YY",
                                        hintStyle: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          color: Colors.black54,
                                        ),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 60),
                                    child: TextFormField(
                                      keyboardType: TextInputType.phone,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                        color: Colors.black54,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) return 'Enter CVC';
                                        if (value.length != 3) return 'CVC must be 3 digits';
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        hintText: "CVC",
                                        hintStyle: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          color: Colors.black54,
                                        ),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                TextAuth(
                  text: 'Cardholder name',
                  size: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: cardholderController,
                  keyboardType: TextInputType.text,
                  onChanged: (_) => setState(() {}),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  cursorColor: const Color(0xff99B5DD),
                  decoration: InputDecoration(
                    hintText: 'Cardholder name',
                    hintStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0x800047ab),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0xff99B5DF),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.red, width: 1.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Enter cardholder name';
                    return null;
                  },
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()){
                        final prefs = await SharedPreferences.getInstance();
                        final email = emailController.text.trim();
                        final plan = widget.planName;
                        final amount = widget.planPrice;
                        final userId = prefs.getString('userId') ?? 'anonymous';

                        // ✅ Save payment in Firestore
                        await FirebaseFirestore.instance.collection('payments').add({
                          'email': email,
                          'plan': plan,
                          'amount': amount,
                          'userId': userId,
                          'timestamp': FieldValue.serverTimestamp(),
                        });

                        // ✅ Send confirmation email with EmailJS
                        var status = await sendPaymentConfirmationEmail(
                            email: email,
                            userName: 'Hager Mohammed', // لو عندك اسم حقيقي بدّليه هنا
                            planName: plan,
                            amount: amount,
                            context: context
                        );
                        if (status == true){
                          await prefs.setBool("is_pro_user", true); // ← تفعيل الخطة المدفوعة
                          await prefs.remove("image_generation_count"); // ← تصفير العداد المجاني
                          QuickAlert.show(
                            context: context,
                            type: QuickAlertType.success,
                            title: "You're All Set",
                            text: 'Your payment went through email with the details is waiting for you',
                            confirmBtnText: 'Continue',
                            confirmBtnColor: const Color(0xFF0047AB),
                            confirmBtnTextStyle: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                            onConfirmBtnTap: () {
                              Navigator.of(context).pop();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const HomeScreen()),
                              );
                            },
                          );
                        }else{
                          QuickAlert.show(
                            context: context,
                            type: QuickAlertType.error,
                            title: 'Hold on...',
                            text: 'We couldn’t complete your request',
                            confirmBtnText: 'Try later',
                            confirmBtnColor: const Color(0xFF0047AB),
                            confirmBtnTextStyle: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                            onConfirmBtnTap: () {
                              Navigator.of(context).pop();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const HomeScreen()),
                              );
                            },
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff0047AB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: TextAuth(
                      text: 'Subscribe',
                      size: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, HomeScreen.routeName);
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(240, 248, 255, 1),
                      side: const BorderSide(color: Color(0xff0047AB), width: 1.5), // إطار أزرق
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: TextAuth(
                    text: 'Cancel',
                    size: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff0047AB),
                  ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  void showGenioSubscriptionSummary(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Color(0xffD4EBFF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image(image: AssetImage('assets/images/Group.png')),
                      const SizedBox(width: 6),
                      TextAuth(
                        text: 'Genio AI',
                        size: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff0047AB),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: TextAuth(
                      text: 'Close',
                      size: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff344054),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextAuth(
                    text: '${widget.planName} Subscription',
                    size: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xff344054),
                  ),
                  TextAuth(
                    text: '\$${widget.planPrice.toStringAsFixed(2)}',
                    size: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xff344054),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Align(
                alignment: Alignment.centerLeft,
                child: TextAuth(
                  text: 'Billed monthly',
                  size: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xffA3A3B5),
                ),
              ),
              const Divider(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextAuth(
                    text: 'Subtotal',
                    size: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xff344054),
                  ),
                  TextAuth(
                    text: '\$${widget.planPrice.toStringAsFixed(2)}',
                    size: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xff344054),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Row(
                    children: [
                      TextAuth(
                        text: 'Tax',
                        size: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff344054),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.info_outline, size: 18, color: Colors.grey),
                    ],
                  ),
                  TextAuth(
                    text: '\$0.00',
                    size: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xff344054),
                  ),
                ],
              ),
              const Divider(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextAuth(
                    text: 'Total due today',
                    size: 20,
                    fontWeight: FontWeight.w500,
                    color: Color(0xff344054),
                  ),
                  TextAuth(
                    text: '\$${widget.planPrice.toStringAsFixed(2)}',
                    size: 20,
                    fontWeight: FontWeight.w500,
                    color: Color(0xff344054),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
