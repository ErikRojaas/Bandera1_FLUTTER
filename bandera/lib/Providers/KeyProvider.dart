import 'package:bandera/Models/Key.dart' as KeyModel;
import 'package:flutter/material.dart';

class KeyProvider extends ChangeNotifier {
  
  Map<String, KeyModel.Key> keys = {};
  
  void addKey(KeyModel.Key key) {
    print('Adding key: ${key.id} at (${key.x}, ${key.y})');
    keys[key.id] = key;
    notifyListeners();
  }

  void removeKey(String id) {
    print('Removing key: $id');
    keys.remove(id);
    notifyListeners();
  }

  void updateKey(String id, KeyModel.Key key) {
    if (keys.containsKey(id)) {
      keys[id]!.x = key.x;
      keys[id]!.y = key.y;
      notifyListeners();
    }
  }

  void update(List<Map<String, dynamic>> entities) {
    
    // Filter only keys
    final keyEntities = entities.where((entity) => 
      entity['id'].toString().startsWith('key_')).toList();
    
    // Create sets of current and incoming IDs
    Set<String> currentKeyIds = keys.keys.toSet();
    Set<String> incomingKeyIds = keyEntities.map((e) => e['id'].toString()).toSet();
    
    // Remove keys no longer in the list
    currentKeyIds.difference(incomingKeyIds).forEach((id) {
      removeKey(id);
    });

    // Add or update entities
    for (var entity in keyEntities) {
      String id = entity['id'].toString();
      double x = (entity['x'] as num).toDouble();
      double y = (entity['y'] as num).toDouble();
      
      
      KeyModel.Key key = KeyModel.Key(id, x, y);
      if (keys.containsKey(id)) {
        updateKey(id, key);
      } else {
        addKey(key);
      }
    }
    notifyListeners();
  }
} 