// ── Classe abstraite Animal (abstract class du cours) ─────────
abstract class Animal {
  final String name;  // val name: String

  Animal(this.name); // constructeur primaire

  int get legs;                // propriété abstraite
  String makeSound();          // méthode abstraite

  @override
  String toString() => '$name (pattes: $legs) dit: ${makeSound()}';
}

// ── Sous-classe Dog (héritage — cours page 8) ─────────────────
class Dog extends Animal {
  Dog(String name) : super(name); // appel constructeur parent

  @override
  int get legs => 4;

  @override
  String makeSound() => 'Woof!';
}

// ── Sous-classe Cat (héritage) ────────────────────────────────
class Cat extends Animal {
  Cat(String name) : super(name);

  @override
  int get legs => 4;

  @override
  String makeSound() => 'Meow!';
}

// ── main() ────────────────────────────────────────────────────
void main() {
  // List<Animal> — polymorphisme
  final List<Animal> animals = [
    Dog('Buddy'),
    Cat('Whiskers'),
    Dog('Rex'),
    Cat('Luna'),
  ];

  print('╔══════════════════════════════╗');
  print('║         ZOO ANIMALS          ║');
  print('╚══════════════════════════════╝');

  // for loop — iteration
  for (final animal in animals) {
    print('${animal.name} says ${animal.makeSound()}');
  }
}
