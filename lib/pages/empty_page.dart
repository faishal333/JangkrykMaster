import 'package:flutter/material.dart';

class EmptyPage extends StatefulWidget {
  const EmptyPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EmptyPageeState createState() => _EmptyPageeState();
}

class _EmptyPageeState extends State<EmptyPage> {

  @override
  Widget build(BuildContext context) {
    return const Scaffold(appBar: null,
    body: null
    );
  }
}