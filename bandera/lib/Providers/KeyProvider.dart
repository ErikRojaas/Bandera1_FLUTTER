import 'package:bandera/Models/Key.dart' as KeyModel;
import 'package:flutter/material.dart';

class KeyProvider extends ChangeNotifier {
  
  Map<String, KeyModel.Key> keys = {};
  bool _initialized = false;
  
  // Initialize with a default key if needed
  void initialize() {
    if (!_initialized && keys.isEmpty) {
      print('Initializing with default key');
      // Add a default key at the center
      KeyModel.Key defaultKey = KeyModel.Key('default_key', 0, 0);
      addKey(defaultKey);
      _initialized = true;
    }
  }
  
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

  void update(List<Map<String, dynamic>> keyEntities) {
    // Make sure we have at least one key
    initialize();
    
    // If the update list is empty but we previously had server-sent keys
    // (not just our default key), preserve the existing keys
    if (keyEntities.isEmpty) {
      print('Received empty keys list - preserving existing keys');
      return;
    }

    Set<String> currentKeyIds = keys.keys.toSet();
    Set<String> incomingKeyIds = keyEntities.map((e) => e['id'].toString()).toSet();
    
    // Debug information
    print('Current keys: $currentKeyIds');
    print('Incoming keys: $incomingKeyIds');
    
    // Remove keys no longer in the list
    currentKeyIds.difference(incomingKeyIds).forEach((id) {
      removeKey(id);
    });

    // Add or update entities
    for (var entity in keyEntities) {
      String id = entity['id'].toString();
      double x = entity['x'].toDouble();
      double y = entity['y'].toDouble();
      
      KeyModel.Key key = KeyModel.Key(id, x, y);
      if (keys.containsKey(id)) {
        updateKey(id, key);
      } else {
        addKey(key);
      }
    }
    
    // If we somehow ended up with no keys, add the default key back
    if (keys.isEmpty) {
      print('No keys after update, adding default key');
      initialize();
    }
    
    notifyListeners();
  }
} 