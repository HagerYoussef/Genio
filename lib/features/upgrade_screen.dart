import 'package:flutter/material.dart';

class UpgradeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Color.fromRGBO(240, 248, 255, 1),
      appBar: AppBar(
        backgroundColor:  Color.fromRGBO(240, 248, 255, 1),
        elevation: 0,
        leading: InkWell(
            onTap: (){
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back_ios,color: Color(0xff0047AB),)),
        title: Text(
          "Upgrade",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color:  Color(0xff0047AB)),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              PricingCard(title: "Free", price: "0"),
              SizedBox(height: 20),
              PricingCard(title: "Pro", price: "9.99"),
              SizedBox(height: 20),
              PricingCard(title: "Premium", price: "19.99"),
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

  PricingCard({required this.title, required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFFE6F0FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xff0047AB),),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "\$",
                style: TextStyle(fontSize: 16, color: Color(0xff6691CD)),
              ),
              Text(
                price,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "USD/",
                      style: TextStyle(fontSize: 12, color: Color(0xff6691CD)),
                    ),
                    Text(
                      "Month",
                      style: TextStyle(fontSize: 12,color: Color(0xff6691CD)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            "Lorem ipsum dolor sit amet consectetur.",
            style: TextStyle(fontSize: 14, color: Color(0xff6691CD)),
          ),
          SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4A73C4),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: Size(double.infinity, 45),
            ),
            child: Text("Enter limited code"),
          ),
          SizedBox(height: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(5, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Icon(Icons.check, color: Colors.black, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Lorem ipsum dolor sit amet.",
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          SizedBox(height: 15),
          Center(
            child: TextButton(
              onPressed: () {},
              child: Text(
                "Have an existing plan? See billing here",
                style: TextStyle(color: Color(0xff6691CD), fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
