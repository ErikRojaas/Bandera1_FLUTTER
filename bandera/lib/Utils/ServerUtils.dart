import 'dart:convert';
import 'dart:async';
import 'package:bandera/Providers/PlayerProvider.dart';
import 'package:bandera/Providers/KeyProvider.dart';
import 'package:get_it/get_it.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/html.dart' as html;
import 'package:web_socket_channel/io.dart' as io;
import 'package:bandera/Models/ServerMessage.dart';
import 'package:flutter/foundation.dart';


class ServerUtils {
  // Use the same domain as the web app is being served from
  // This avoids CORS issues when running in the browser
  static String get host {
    // In web, we need to use dart:html to get the current hostname
    if (kIsWeb) {
      // Import this at the top: import 'dart:html' as html;
      return Uri.base.host; // Gets current hostname without importing dart:html directly
    } else {
      return "bandera1.ieti.site"; // Use specific domain on mobile
    }
  }
  // static const String host = "localhost";
  // static const int port = 8080;
  static const int port = 8081;

  static WebSocketChannel? _channel;
  static StreamSubscription<dynamic>? _subscription;
  static Function? _onDisconnect;
  
  // Connect to the WebSocket server
  static Future<void> connectToServer({Function? onDisconnect}) async {
    try {
      _onDisconnect = onDisconnect;
      
      // Create a proper WebSocket URI
      // Note: In web, it uses the same domain but with wss:// protocol
      final secure = port == 443;
      final protocol = secure ? 'wss' : 'ws';
      final uri = Uri.parse('$protocol://$host${port == 443 || port == 80 ? '' : ':$port'}');
      
      // Choose the appropriate WebSocket implementation
     if (kIsWeb) {
        _channel = html.HtmlWebSocketChannel.connect(uri.toString());
        print('Web: Connected to server at $uri');
      } else {
        _channel = io.IOWebSocketChannel.connect(uri);
        print('Mobile: Connected to server at $uri');
      }
      
      // Set up the listener for incoming messages
      _subscription = _channel!.stream.listen(
        _handleRawMessage,
        onDone: _handleDisconnect,
        onError: (error) {
          print('WebSocket error: $error');
          _handleDisconnect();
        },
      );
    } catch (e) {
      print('Error connecting to server: $e');
      throw Exception('Failed to connect to server: $e');
    }
  }

  static void _handleDisconnect() {
    print('Connection to server closed');
    if (_channel != null) {
      _channel = null;
      if (_onDisconnect != null) {
        _onDisconnect!();
      }
    }
  }

  static void disconnectFromServer() {
    _subscription?.cancel();
    _channel?.sink.close();
    _channel = null;
    print('Disconnected from server');
    _onDisconnect?.call();
  }

  static Future<String> sendMessage(ServerMessage message) async {
    if (_channel == null) {
      throw Exception('Not connected to server');
    }
    
    final String json = jsonEncode(message.toJson());
    _channel!.sink.add(json);
    return json;
  }

  static void _handleRawMessage(dynamic data) {
    print("data: " + data.toString());
    try {
      final String stringData = data.toString();
      final Map<String, dynamic> jsonData = jsonDecode(stringData);
      final ServerMessage message = ServerMessage.fromJson(jsonData);
      _handleServerMessage(message);
    } catch (e) {
      print('Error parsing message: $e, data: $data');
    }
  }

  static void _handleServerMessage(ServerMessage message) {
    final getIt = GetIt.instance;
    PlayerProvider playerProvider = getIt<PlayerProvider>();
    KeyProvider keyProvider = getIt<KeyProvider>();
    
    switch (message.type) {
      case 'update':
        Map<String, dynamic> data = message.data;
        List<Map<String, dynamic>> allObjects = [];
        
        // Process players data
        if (data['players'] is List) {
          try {
            List<Map<String, dynamic>> players = List<Map<String, dynamic>>.from(data['players']);
            allObjects.addAll(players);
          } catch (e) {
            print('Error parsing players data: $e');
          }
        }
        
        // Process keys data
        if (data['keys'] is List) {
          try {
            List<Map<String, dynamic>> keys = List<Map<String, dynamic>>.from(data['keys']);
            // Convert keys to player format with special ID prefix
            List<Map<String, dynamic>> keyPlayers = keys.map((key) {
              return {
                'id': 'key_${key['id']}',
                'x': key['x'],
                'y': key['y']
              };
            }).toList();
            allObjects.addAll(keyPlayers);
          } catch (e) {
            print('Error parsing keys data: $e');
          }
        }
        
        // Update both providers with all objects
        playerProvider.update(allObjects);
        keyProvider.update(allObjects);
        break;
    }
  }
}