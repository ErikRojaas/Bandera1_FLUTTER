import 'package:bandera/Models/Player.dart';
import 'package:flutter/material.dart';
import 'package:bandera/Models/ServerMessage.dart';

class PlayerProvider extends ChangeNotifier {
  
  Map<String, Player> players = {};
  
  void addPlayer(Player player) {
    players.addAll({player.id: player});
    notifyListeners();
  }

  void removePlayer(Player player) {
    players.remove(player.id);
    notifyListeners();
  }

  void updatePlayer(String id, Player player) {
    Player? oldPlayer = players[id];
    if (oldPlayer != null) {
      players[id]!.x = player.x;
      players[id]!.y = player.y;
    }
    notifyListeners();
  }

  void update(List<Map<String, dynamic>> players) {
    // Remove players no longer in the list
    players.forEach((player) {
      if (!this.players.containsKey(player['id'])) {
        this.removePlayer(Player(player['id'], player['x'], player['y']));
      }
    });

    // Add new players
    players.forEach((player) {
      if (!this.players.containsKey(player['id'])) {
        this.addPlayer(Player(player['id'], player['x'], player['y']));
      }
    });

    // Update existing players
    players.forEach((player) {
      if (this.players.containsKey(player['id'])) {
        this.updatePlayer(player['id'], Player(player['id'], player['x'], player['y']));
      }
    });
  }
 
}