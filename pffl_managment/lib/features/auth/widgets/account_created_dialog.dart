import 'package:flutter/material.dart';
import 'package:pffl_managment/core/constants/app_colors.dart';
import 'package:pffl_managment/routes/app_routes.dart';

class AccountCreatedDialog extends StatelessWidget {
  const AccountCreatedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 375,
      padding: const EdgeInsets.only(top: 24),
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 32,
        children: [
          Container(
            width: 41,
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 3,
                  strokeAlign: BorderSide.strokeAlignCenter,
                  color: const Color(0xFFDFDFDF),
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 8,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Account Created!',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontFamily: 'Serotiva',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Let\'s set up your player profile to get started.',
                      style: TextStyle(
                        color: Color(0x992E2E2E),
                        fontSize: 14,
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w500,
                        height: 1.57,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              // Navigate to complete profile screen
              Navigator.pushNamed(context, AppRoutes.completeProfile);
            },
            child: Container(
              width: 343,
              height: 58,
              decoration: ShapeDecoration(
                color: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(200),
                ),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 16,
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        'Continue',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w400,
                          height: 1.25,
                          letterSpacing: 0.32,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
       SizedBox(
        height: 20,
       )
        ],
      ),
    );
  }
}