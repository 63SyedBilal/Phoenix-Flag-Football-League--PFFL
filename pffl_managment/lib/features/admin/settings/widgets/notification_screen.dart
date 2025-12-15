import 'package:flutter/material.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: ArrowBackButton(
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
          

              const SizedBox(height: 20),

              /// TITLE
              const Text(
                "Notifications",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 6),

              /// SUBTEXT
              Text(
                "Stay updated with important alerts and reminders.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 20),

              /// NOTIFICATIONS LIST
              Expanded(
                child: ListView(
                  children: const [
                    NotificationCard(
                      title: "Payment Received",
                      date: "09 Dec 2025",
                      msg:
                          "A player has successfully paid the League Fee. Please review the payment details.",
                    ),
                    NotificationCard(
                      title: "Payment Refunded",
                      date: "09 Dec 2025",
                      msg:
                          "The player's League Fee has been successfully refunded. Please review the refund details if needed.",
                    ),
                    NotificationCard(
                      title: "Payment Processed",
                      date: "10 Dec 2025",
                      msg:
                          "The player's League Fee has been successfully processed. Please check your account for the updated balance.",
                    ),
                    NotificationCard(
                      title: "Payment Pending",
                      date: "11 Dec 2025",
                      msg:
                          "The player's League Fee is currently pending. We are awaiting confirmation from the payment provider.",
                    ),
                    NotificationCard(
                      title: "League Created Successfully",
                      date: "09 Dec 2025",
                      msg:
                          "Your new league has been created successfully.\nYou can now manage teams, and schedules from your league dashboard.",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String title;
  final String msg;
  final String date;

  const NotificationCard({
    super.key,
    required this.title,
    required this.msg,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
       
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TITLE + DATE BADGE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C2A4B),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  date,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          /// MESSAGE
          Text(
            msg,
            style: TextStyle(
              fontSize: 13.5,
              color: Colors.grey.shade700,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
