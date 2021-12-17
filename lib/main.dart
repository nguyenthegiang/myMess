import 'package:flutter/material.dart';
import 'package:my_mess/providers/message_provider.dart';
import 'package:my_mess/screens/new_message_screen.dart';
import 'package:provider/provider.dart';

import './screens/auth_screen.dart';
import './providers/auth.dart';
import './screens/splash_screen.dart';
import './screens/home-screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        /* Provider cho auth */
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        /* Provider cho Message */
        ChangeNotifierProxyProvider<Auth, MessageProvider>(
          create: (_) => MessageProvider('', '', []),
          update: (ctx, auth, previousMessageProvider) => MessageProvider(
            auth.token,
            auth.userId,
            previousMessageProvider == null
                ? []
                : previousMessageProvider.friends,
          ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'MyMess',
          theme: ThemeData(
            primarySwatch: Colors.green,
            fontFamily: 'Lato',
          ),
          home: auth.isAuth
              ? HomeScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            NewMessageScreen.routeName: (ctx) => NewMessageScreen(),
          },
        ),
      ),
    );
  }
}
