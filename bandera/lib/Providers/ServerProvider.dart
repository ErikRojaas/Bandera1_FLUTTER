import 'package:flutter/material.dart';
import 'package:bandera/Models/ServerMessage.dart';

class ServerProvider with ChangeNotifier {
  final List<ServerMessage> _messages = [];

  List<ServerMessage> get messages => List.unmodifiable(_messages);

  void addMessage(ServerMessage message) {
    _messages.add(message);
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
}