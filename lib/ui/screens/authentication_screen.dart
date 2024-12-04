import 'package:flutter/material.dart' as flutter;
import 'package:appwrite/appwrite.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/phone_input.dart';
import '../components/otp_input.dart';
import '../components/name_input.dart';
import '../../config/config.dart';
import '../../data/data_sources/auth_data_source.dart';
import '../../data/repositories/auth_repository.dart';

class AuthenticationScreen extends flutter.StatefulWidget {
  final Account account;
  final Databases databases;
  final Functions functions;

  const AuthenticationScreen({
    flutter.Key? key,
    required this.account,
    required this.databases,
    required this.functions,
  }) : super(key: key);

  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends flutter.State<AuthenticationScreen> {
  late AuthRepository _authRepository;
  String? _userId;
  String? _phoneNumber;

  @override
  void initState() {
    super.initState();
    final authDataSource =
        AuthDataSource(widget.account, widget.databases, widget.functions);
    _authRepository = AuthRepository(authDataSource);
  }

  bool isNameScreen = false;
  bool isOtpScreen = false;

  void _changeLanguage(String languageCode) async {
    await context.setLocale(flutter.Locale(languageCode));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', languageCode);
  }

  @override
  flutter.Widget build(flutter.BuildContext context) {
    final screenHeight = flutter.MediaQuery.of(context).size.height;
    final screenWidth = flutter.MediaQuery.of(context).size.width;

    return flutter.Scaffold(
      body: flutter.Container(
        decoration: flutter.BoxDecoration(
          image: flutter.DecorationImage(
            image: flutter.AssetImage('assets/images/bg.png'),
            fit: flutter.BoxFit.cover,
          ),
        ),
        child: flutter.SafeArea(
          child: flutter.SingleChildScrollView(
            child: flutter.Container(
              height: screenHeight,
              width: screenWidth,
              child: flutter.Stack(
                children: [
                  flutter.PopupMenuButton<String>(
                    onSelected: _changeLanguage,
                    itemBuilder: (flutter.BuildContext context) {
                      return [
                        flutter.PopupMenuItem<String>(
                          value: 'en',
                          child: flutter.Text('English'),
                        ),
                        flutter.PopupMenuItem<String>(
                          value: 'fr',
                          child: flutter.Text('Français'),
                        ),
                        flutter.PopupMenuItem<String>(
                          value: 'ar',
                          child: flutter.Text('العربية'),
                        ),
                        flutter.PopupMenuItem<String>(
                          value: 'es',
                          child: flutter.Text('Español'),
                        ),
                      ];
                    },
                  ),
                  flutter.Positioned(
                    top: screenHeight * 0.10,
                    left: 0,
                    right: 0,
                    child: Config.buildLogo(),
                  ),
                  flutter.Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: screenHeight * 0.6,
                    child: flutter.Container(
                      decoration: flutter.BoxDecoration(
                        color: flutter.Colors.white,
                        borderRadius: flutter.BorderRadius.only(
                          topLeft: flutter.Radius.circular(30),
                          topRight: flutter.Radius.circular(30),
                        ),
                      ),
                      child: isNameScreen
                          ? NameInput(
                              onBack: () => setState(() {
                                isNameScreen = false;
                                isOtpScreen = true;
                              }),
                              onSubmit: () {
                                // Handle name submit
                              },
                              userId: _userId!,
                              phoneNumber: _phoneNumber!,
                              authRepository: _authRepository,
                            )
                          : isOtpScreen
                              ? OtpInput(
                                  onBack: () => setState(() {
                                    isOtpScreen = false;
                                  }),
                                  onVerify: () {
                                    setState(() {
                                      isNameScreen = true;
                                    });
                                  },
                                  phoneNumber: _phoneNumber!,
                                  userId: _userId!,
                                  authRepository: _authRepository,
                                )
                              : PhoneInput(
                                  onSubmit:
                                      (String userId, String phoneNumber) {
                                    setState(() {
                                      _userId = userId;
                                      _phoneNumber = phoneNumber;
                                      isOtpScreen = true;
                                    });
                                  },
                                  authRepository: _authRepository,
                                ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}