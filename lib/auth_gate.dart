import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

import 'dog_list.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen(
            providerConfigs: const [
              EmailProviderConfiguration(),
              GoogleProviderConfiguration(clientId: '542283688369-2f7uk5h76pefhbo4v80ue195nmp42t91.apps.googleusercontent.com')
            ],
            headerBuilder: (context, constraints, _) {
              return Container(
                padding: const EdgeInsets.fromLTRB(0, 10, 15, 0),
                color: Theme.of(context).colorScheme.primaryContainer,

                child: Image.asset('assets/Achieve_Agility_Logo_dark_green.png')
              );
            },
          );
        }
        return DogList();
      },
    );
  }
}