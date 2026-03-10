// ── Interface Drawable (cours page 11) ────────────────────────
// En Dart, abstract class = interface Kotlin
abstract class Drawable {
  void draw();           // méthode abstraite
  String get shapeName; // propriété abstraite
}

// ── Classe Circle ──────────────────────────────────────────────
class Circle implements Drawable {
  final int radius;

  Circle(this.radius);

  @override
  String get shapeName => 'Circle';

  @override
  void draw() {
    print('  ***  ');
    print(' *   * ');
    print('*     *');
    print(' *   * ');
    print('  ***  ');
    print('Rayon : $radius');
  }
}

// ── Classe Square ──────────────────────────────────────────────
class Square implements Drawable {
  final int side;

  Square(this.side);

  @override
  String get shapeName => 'Square';

  @override
  void draw() {
    print('*****');
    print('*   *');
    print('*   *');
    print('*****');
    print('Côté : $side');
  }
}

// ── Classe Triangle (bonus) ────────────────────────────────────
class Triangle implements Drawable {
  final int base;

  Triangle(this.base);

  @override
  String get shapeName => 'Triangle';

  @override
  void draw() {
    print('  *  ');
    print(' * * ');
    print('*****');
    print('Base : $base');
  }
}

// ── main() ────────────────────────────────────────────────────
void main() {
  // List<Drawable> — polymorphisme
  final List<Drawable> shapes = [
    Circle(5),
    Square(4),
    Triangle(6),
  ];

  print('╔══════════════════════════════════╗');
  print('║         DRAWABLE SHAPES          ║');
  print('╚══════════════════════════════════╝');

  // for loop — polymorphisme
  for (final shape in shapes) {
    print('\n── ${shape.shapeName} ──');
    shape.draw();
  }
}
