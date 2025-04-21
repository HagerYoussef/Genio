import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class PhoneNumber extends StatelessWidget {
  TextEditingController phoneController;
  PhoneNumber({super.key, required this.phoneController});


  @override
  Widget build(BuildContext context) {
    return IntlPhoneField(
      controller: phoneController,
      flagsButtonMargin : const EdgeInsets.symmetric(horizontal: 5),
      initialCountryCode: 'US',
      showDropdownIcon: true,
      disableLengthCheck: true,
      pickerDialogStyle: PickerDialogStyle(
        padding: const EdgeInsets.symmetric(horizontal: 25,vertical: 15),
        backgroundColor: const Color(0xffF0F8FF),
        searchFieldCursorColor : const Color(0xFF0047AB),
        searchFieldInputDecoration: InputDecoration(
          suffixIcon: const Icon(Icons.search,color: Colors.black54,),
          hintText: "Search country...",
          hintStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: Colors.black54,
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: const Color(0x800047AB)), // Default underline color
          ),
          border: const UnderlineInputBorder(
            borderSide: BorderSide(color: const Color(0x800047AB)), // Default underline color
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: const Color(0xFF0047AB), width: 2), // Underline color when focused
          ),
        ),
        listTileDivider: Divider(color: Colors.grey.shade300), // Divider between countries
        countryNameStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black
        ),
        countryCodeStyle: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF0047AB)
        ),
      ),
      decoration: InputDecoration(
        hintText: "+1 (555) 000-0000",
        hintStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w400,
          fontSize: 13,
          color: Colors.black54,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xff99B5DD), width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xff99B5DF), width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onChanged: (phone) {
        print(phone.completeNumber); // طباعة الرقم مع كود الدولة
      },
      keyboardType: TextInputType.phone,
      cursorColor: const Color(0xff99B5DD),
    );
  }
}
