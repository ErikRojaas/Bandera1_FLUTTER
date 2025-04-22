import 'package:bandera/Models/Player.dart';
import 'package:flutter/material.dart';

class PlayerProvider extends ChangeNotifier {
  
  Map<String, Player> players = {};
  
  void addPlayer(Player player) {
    players[player.id] = player;
    notifyListeners();
  }

  void removePlayer(String id) {
    players.remove(id);
    notifyListeners();
  }

  void updatePlayer(String id, Player player) {
    players[id]!.x = player.x;
    players[id]!.y = player.y;
    players[id]!.skinId = player.skinId;
    players[id]!.action = player.action;
    if (player.direction != null) {
      players[id]!.direction = player.direction;
    }
    notifyListeners();
  }

  void update(List<Map<String, dynamic>> playerEntities) {

    Set<String> currentPlayerIds = players.keys.toSet();
    Set<String> incomingPlayerIds = playerEntities.map((e) => e['id'].toString()).toSet();

    currentPlayerIds.difference(incomingPlayerIds).forEach((id) {
      removePlayer(id);
    });

    for (var entity in playerEntities) {
      String id = entity['id'].toString();
      double x = entity['x'].toDouble();
      double y = entity['y'].toDouble();
      int skinId = entity['skinId'];
      Map<String, dynamic> moveVector = entity['moveVector'];
      Direction? direction = Player.getDirectionFromJson(moveVector);
      if (currentPlayerIds.contains(id)) {
        Player player = Player(id, skinId, x, y, direction, direction == null ? PlayerAction.idle : PlayerAction.walk);
        updatePlayer(id, player);
      } else {

        Player player = Player(id, skinId, x, y, direction ?? Direction.down, direction == null ? PlayerAction.idle : PlayerAction.walk);
        addPlayer(player);
      }
    }
    
    notifyListeners();
  }
}