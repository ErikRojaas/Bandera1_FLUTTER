import 'package:bandera/Models/Player.dart';
import 'package:flutter/material.dart';
import 'package:bandera/Models/ServerMessage.dart';

class PlayerProvider extends ChangeNotifier {
  
  Map<String, Player> players = {};
  
  void addPlayer(Player player) {
    // Only add if not a key
    if (!player.id.toString().startsWith('key_')) {
      players[player.id] = player;
      notifyListeners();
    }
  }

  void removePlayer(String id) {
    if (!id.toString().startsWith('key_')) {
      players.remove(id);
      notifyListeners();
    }
  }

  void updatePlayer(String id, Player player) {
    if (!id.toString().startsWith('key_') && players.containsKey(id)) {
      players[id]!.x = player.x;
      players[id]!.y = player.y;
      notifyListeners();
    }
  }

  void update(List<Map<String, dynamic>> entities) {
    // Filter out keys
    final playerEntities = entities.where((entity) => 
      !entity['id'].toString().startsWith('key_')).toList();
    
    // Create sets of current and incoming IDs
    Set<String> currentPlayerIds = players.keys.toSet();
    Set<String> incomingPlayerIds = playerEntities.map((e) => e['id'].toString()).toSet();
    
    // Remove players no longer in the list
    currentPlayerIds.difference(incomingPlayerIds).forEach((id) {
      players.remove(id);
    });

    // Add or update entities
    for (var entity in playerEntities) {
      String id = entity['id'].toString();
      Player player = Player(id, entity['x'], entity['y']);
      players[id] = player;
    }
    
    notifyListeners();
  }
}