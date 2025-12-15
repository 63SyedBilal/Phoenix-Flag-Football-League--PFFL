import 'package:flutter/material.dart';
import 'package:pffl_managment/core/widgets/custombottomsheet/custom_bottom_sheet.dart';
import 'package:pffl_managment/core/widgets/custom_text_field.dart';

class CustomBottomSheetExample extends StatelessWidget {
  const CustomBottomSheetExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Bottom Sheet Example'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => CustomBottomSheet(
                title: 'Create Account',
                subtitle: 'Enter your information to create a new account',
                buttonText: 'Submit',
                onButtonPressed: () {
                  Navigator.of(context).pop();
                  // Handle submit action
                },
                content: Column(
                  children: [
                    CustomTextField(
                      hintText: 'First Name',
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      hintText: 'Last Name',
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      hintText: 'Email',
                    ),
                  ],
                ),
              ),
            );
          },
          child: const Text('Show Custom Bottom Sheet'),
        ),
      ),
    );
  }
}