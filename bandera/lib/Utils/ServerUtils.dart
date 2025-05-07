import 'dart:convert';
import 'dart:async';
import 'package:bandera/Providers/FlagProvider.dart';
import 'package:bandera/Providers/PlayerProvider.dart';
import 'package:bandera/Providers/KeyProvider.dart';
import 'package:bandera/Providers/TimerProvider.dart';
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
 static const int port = 8081;
 // static const int port = 443;

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
    FlagProvider flagProvider = getIt<FlagProvider>();
    TimerProvider timerProvider = getIt<TimerProvider>();
    
    // Make sure the key provider is initialized
    keyProvider.initialize();
    
    switch (message.type) {
      case 'update':
        Map<String, dynamic> data = message.data;
        List<Map<String, dynamic>> players = [];
        List<Map<String, dynamic>> keys = [];
        List<Map<String, dynamic>> flags = [];
        String? timer;
        
        if (data['players'] is List) {
          try {
            print(data['players']);
            players = List<Map<String, dynamic>>.from(data['players']);
          } catch (e) {
            print('Error parsing players data: $e');
          }
        }

        if (data['flags'] is List) {
          try {
            flags = List<Map<String, dynamic>>.from(data['flags']);
          } catch (e) {
            print('Error parsing flags data: $e');
          }
        }
        
        // Process keys data
        if (data.containsKey('keys')) {
          try {
            if (data['keys'] is List) {
              keys = List<Map<String, dynamic>>.from(data['keys']);
              // Update key provider with new data
              keyProvider.update(keys);
            } else {
              print('Keys data is not a list: ${data['keys']}');
            }
          } catch (e) {
            print('Error processing keys data: $e');
          }
        } else {
        }
        
        // Check for timer data (from room.timer)
        if (data['room'] != null && data['room']['timer'] != null) {
          try {
            timer = data['room']['timer'] as String;
          } catch (e) {
            print('Error parsing timer data: $e');
          }
        }
        print('players: $players');
        // Update other providers with data
        playerProvider.update(players);
        flagProvider.update(flags);
        if (timer != null) {
          timerProvider.updateTimer(timer);
        }
        break;
    }
  }
}