import 'package:bandera/Models/Flag.dart';
import 'package:flutter/material.dart';

class FlagProvider extends ChangeNotifier {
  
  Map<String, Flag> flags = {};
  
  void addFlag(Flag flag) {
    flags[flag.id] = flag;
    notifyListeners();
  }

  void removeFlag(String id) {
    flags.remove(id);
    notifyListeners();
  }

  void updateFlag(String id, Flag flag) {
    flags[id]!.x = flag.x;
    flags[id]!.y = flag.y;
    notifyListeners();
  }

  void update(List<Map<String, dynamic>> flagEntities) {
    Set<String> currentFlagIds = flags.keys.toSet();
    Set<String> incomingFlagIds = flagEntities.map((e) => e['id'].toString()).toSet();

    currentFlagIds.difference(incomingFlagIds).forEach((id) {
      removeFlag(id);
    });

    for (var entity in flagEntities) {
      String id = entity['id'].toString();
      double x = entity['x'].toDouble();
      double y = entity['y'].toDouble();
      
      if (currentFlagIds.contains(id)) {
        Flag flag = Flag(id, x, y);
        updateFlag(id, flag);
      } else {
        Flag flag = Flag(id, x, y);
        addFlag(flag);
      }
    }
    
    notifyListeners();
  }
} 