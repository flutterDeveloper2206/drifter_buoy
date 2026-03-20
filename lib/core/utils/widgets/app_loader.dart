import 'package:flutter/cupertino.dart';

class AppLoader extends StatelessWidget {
  final String message;

  const AppLoader({super.key, this.message = 'Please wait...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CupertinoActivityIndicator(radius: 14),
          const SizedBox(height: 12),
          Text(message),
        ],
      ),
    );
  }
}
