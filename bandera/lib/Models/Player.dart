
enum Direction { up, down, left, right }

enum PlayerAction { idle, walk }

class Player {
  String id;
  int skinId;
  double x;
  double y;
  Direction? direction;
  PlayerAction? action;
  
  Player(
    this.id,
    this.skinId,
    this.x,
    this.y,
    this.direction,
    this.action
  );
  //{dx: float, dy: float}
  static Direction? getDirectionFromJson(Map<String, dynamic> json) {
    double dx = json['dx'];
    double dy = json['dy'];
    
    if (dx == 0 && dy == 0) {
      return null;
    } else if (dx.abs() > dy.abs()) {
      return dx > 0 ? Direction.right : Direction.left;
    } else {
      return dy > 0 ? Direction.up : Direction.down;
    }
  }

  getAnimation() {
    String actionString = '';
  String directionString = '';
  
  // Convert action enum to string
  if (action == PlayerAction.idle) {
    actionString = 'idle';
  } else if (action == PlayerAction.walk) {
    actionString = 'walk';
  }
  
  // Convert direction enum to string
  if (direction == Direction.up) {
    directionString = 'up';
  } else if (direction == Direction.down) {
    directionString = 'down';
  } else if (direction == Direction.left) {
    directionString = 'left';
  } else if (direction == Direction.right) {
    directionString = 'right';
  }
  
  // Combine with underscore format
  return '${actionString}_${directionString}';
  }
}