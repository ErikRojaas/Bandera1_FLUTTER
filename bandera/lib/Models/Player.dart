
enum Direction { up, down, left, right }

enum Action { idle, move}

class Player {
  String id;
  double x;
  double y;
  Direction direction;
  Action action;
  
  Player(
    this.id,
    this.x, this.y,
    {
      this.direction = Direction.down,
      this.action = Action.idle
    });
  
}