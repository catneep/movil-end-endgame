import 'package:flutter/material.dart';

class LoadingSpinner extends StatelessWidget {
  const LoadingSpinner({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        CircularProgressIndicator(
          color: Colors.blueAccent,
        ),
        Text('Please Wait...')
      ],
    );
  }
}