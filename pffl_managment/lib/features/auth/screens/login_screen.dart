import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/providers/auth_provider.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';
import 'package:pffl_managment/core/widgets/custom_text_field.dart';
import 'package:pffl_managment/core/widgets/left_alaign_button.dart';
import 'package:pffl_managment/routes/app_routes.dart';
import 'package:pffl_managment/core/utils/svg_icons.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ArrowBackButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text(
                "Welcome Back\nto PFFL",
                style: theme.textTheme.headlineLarge,
              ),

              const SizedBox(height: 8),

              Text(
                "Log in to access your teams and games",
                style: theme.textTheme.bodyMedium,
              ),

              const SizedBox(height: 26),

              Text("Email Address", style: theme.textTheme.bodyMedium),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _emailController,
                hintText: "e.g admin@gmail.com",
                onChanged: (value) {
                  authProvider.clearLoginErrors();
                },
              ),
              if (authProvider.loginEmailError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Row(
                    children: [
                      SvgIcons.infoFill(size: 16, color: Colors.red),
                      const SizedBox(width: 4),
                      Text(
                        authProvider.loginEmailError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                      Spacer(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                          ),
                          child: Text(
                            "Forgot Password",
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              Text("Password", style: theme.textTheme.bodyMedium),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _passwordController,
                hintText: "Enter your password",
                obscureText: !authProvider.isLoginPasswordVisible,
                onChanged: (value) {
                  authProvider.clearLoginErrors();
                },
                suffixIcon: IconButton(
                  icon: Icon(
                    authProvider.isLoginPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.grey,
                  ),
                  onPressed: authProvider.toggleLoginPasswordVisibility,
                ),
              ),
              if (authProvider.loginPasswordError != null)
                Row(
                  children: [
                    SvgIcons.infoFill(size: 16, color: Colors.red),
                    const SizedBox(width: 4),
                    Text(
                      authProvider.loginPasswordError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                    Spacer(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                        ),
                        child: Text(
                          "Forgot Password",
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 30),

              RightAlignedButton(
                text: "Next",
                onTap: () async {
                  final success = await authProvider.login(
                    _emailController.text,
                    _passwordController.text,
                    context,
                  );

                  if (success) {
                    if (authProvider.isLoggedIn) {
                      String route;
                      // Map backend roles to Flutter route names
                      switch (authProvider.userRole) {
                        case 'superadmin':
                          route = AppRoutes.adminDashboard;
                          break;
                        case 'referee':
                          route = AppRoutes.refereeDashboard;
                          break;
                        case 'captain':
                          route = AppRoutes.captainDashboard;
                          break;
                        case 'player':
                          route = AppRoutes.playerDashboard;
                          break;
                        case 'stat-keeper':
                          route = AppRoutes.statKeeperDashboard;
                          break;
                        case 'free-agent':
                          route = AppRoutes.freeAgentDashboard;
                          break;
                        default:
                          route = AppRoutes.playerDashboard;
                      }
                      
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        route,
                        (route) => false,
                      );
                    }
                  }
                },
              ),

              const SizedBox(height: 20),
              // Center(
              //   child: GestureDetector(
              //     onTap: () {
              //       Navigator.pushNamed(context, AppRoutes.signup);
              //     },
              //     child: RichText(
              //       text: TextSpan(
              //         style: theme.textTheme.bodyMedium,
              //         children: [
              //           TextSpan(
              //             text: "Don't have an account? ",
              //             style: TextStyle(
              //               color: theme.brightness == Brightness.dark
              //                   ? Colors.white70
              //                   : Colors.black87,
              //             ),
              //           ),
              //           TextSpan(
              //             text: "Sign Up",
              //             style: TextStyle(
              //               color: theme.primaryColor,
              //               fontWeight: FontWeight.bold,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}