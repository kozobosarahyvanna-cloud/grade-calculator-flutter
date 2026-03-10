// ═══════════════════════════════════════════════════════════════
//  Milestone 3 — Object-Oriented Domain Model
//  SE 3242 — Android Application Development
//  Kozobo Sarah — ICT University Yaoundé
// ═══════════════════════════════════════════════════════════════

// ── Interface Evaluable (cours page 11) ───────────────────────
abstract class Evaluable {
  String evaluate();      // méthode abstraite
  double get average;     // propriété abstraite
}

// ── Interface Printable ───────────────────────────────────────
abstract class Printable {
  void printDetails();
}

// ── Abstract class Person (cours page 10) ─────────────────────
abstract class Person {
  final String name;      // val name: String
  final String id;        // val id: String

  Person(this.name, this.id);

  // méthode abstraite
  String getRole();

  @override
  String toString() => '$getRole(): $name (ID: $id)';
}

// ── data class Grade (cours page 13) ──────────────────────────
// En Dart, on simule data class avec propriétés finales
class Grade {
  final String subject;
  final double score;
  final String semester;

  const Grade({
    required this.subject,
    required this.score,
    required this.semester,
  });

  // toString() — auto-généré dans data class Kotlin
  @override
  String toString() =>
      'Grade(subject: $subject, score: $score, semester: $semester)';

  // copy() — data class Kotlin
  Grade copyWith({String? subject, double? score, String? semester}) {
    return Grade(
      subject:  subject  ?? this.subject,
      score:    score    ?? this.score,
      semester: semester ?? this.semester,
    );
  }
}

// ── Classe Student extends Person implements Evaluable ─────────
class Student extends Person implements Evaluable, Printable {
  final String program;
  final List<Grade> grades;

  Student({
    required String name,
    required String id,
    required this.program,
    required this.grades,
  }) : super(name, id);

  @override
  String getRole() => 'Student';

  // average — propriété calculée
  @override
  double get average {
    if (grades.isEmpty) return 0.0;
    final total = grades.fold(0.0, (sum, g) => sum + g.score);
    return total / grades.length;
  }

  // evaluate() — interface Evaluable
  @override
  String evaluate() {
    final avg = average;
    if (avg >= 90) return 'Excellent !';
    if (avg >= 80) return 'Très bien';
    if (avg >= 70) return 'Bien';
    if (avg >= 60) return 'Passable';
    return 'Échec';
  }

  // printDetails() — interface Printable
  @override
  void printDetails() {
    print('┌─────────────────────────────────────┐');
    print('│ Étudiant  : $name');
    print('│ ID        : $id');
    print('│ Programme : $program');
    print('│ Moyenne   : ${average.toStringAsFixed(1)}/100');
    print('│ Évaluation: ${evaluate()}');
    print('│ Matières  :');
    for (final grade in grades) {
      print('│   - ${grade.subject}: ${grade.score}/100 (${grade.semester})');
    }
    print('└─────────────────────────────────────┘');
  }
}

// ── Classe Professor extends Person ───────────────────────────
class Professor extends Person implements Printable {
  final String department;
  final List<String> courses;

  Professor({
    required String name,
    required String id,
    required this.department,
    required this.courses,
  }) : super(name, id);

  @override
  String getRole() => 'Professor';

  @override
  void printDetails() {
    print('┌─────────────────────────────────────┐');
    print('│ Professeur  : $name');
    print('│ ID          : $id');
    print('│ Département : $department');
    print('│ Cours       :');
    for (final course in courses) {
      print('│   - $course');
    }
    print('└─────────────────────────────────────┘');
  }
}

// ── Sealed class AcademicStatus (cours page 14) ───────────────
sealed class AcademicStatus {}

class Enrolled extends AcademicStatus {
  final String semester;
  Enrolled(this.semester);
}

class Graduated extends AcademicStatus {
  final int year;
  Graduated(this.year);
}

class Suspended extends AcademicStatus {
  final String reason;
  Suspended(this.reason);
}

// ── fun handleStatus() — switch = when Kotlin ─────────────────
void handleStatus(String name, AcademicStatus status) {
  switch (status) {
    case Enrolled(semester: final s):
      print('$name est inscrit(e) en $s');
    case Graduated(year: final y):
      print('$name a obtenu son diplôme en $y');
    case Suspended(reason: final r):
      print('$name est suspendu(e) : $r');
  }
}

// ── main() ────────────────────────────────────────────────────
void main() {
  print('╔══════════════════════════════════════════╗');
  print('║   SYSTÈME DE GESTION UNIVERSITAIRE       ║');
  print('║   SE 3242 — Milestone 3 — Kozobo Sarah   ║');
  print('╚══════════════════════════════════════════╝');
  print('');

  // ── Créer des étudiants ──────────────────────────────────
  final students = [
    Student(
      name: 'Alice Mvondo',
      id: 'STU001',
      program: 'Android Application Development',
      grades: [
        const Grade(subject: 'SE 3242', score: 92, semester: 'S1'),
        const Grade(subject: 'SE 3101', score: 85, semester: 'S1'),
        const Grade(subject: 'SE 3050', score: 78, semester: 'S1'),
      ],
    ),
    Student(
      name: 'Bob Essomba',
      id: 'STU002',
      program: 'Software Engineering',
      grades: [
        const Grade(subject: 'SE 3242', score: 65, semester: 'S1'),
        const Grade(subject: 'SE 3101', score: 70, semester: 'S1'),
      ],
    ),
    Student(
      name: 'Charlie Nkomo',
      id: 'STU003',
      program: 'Android Application Development',
      grades: [],  // null safety — pas de notes
    ),
  ];

  // ── Créer un professeur ──────────────────────────────────
  final professor = Professor(
    name: 'Daniel MOUNE',
    id: 'PROF001',
    department: 'Computer Science',
    courses: ['SE 3242 — Android App Dev', 'SE 3101 — OOP'],
  );

  // ── Afficher le professeur ───────────────────────────────
  print('── PROFESSEUR ──');
  professor.printDetails();
  print('');

  // ── Polymorphisme : List<Person> ─────────────────────────
  print('── LISTE DES PERSONNES (Polymorphisme) ──');
  final List<Person> people = [...students, professor];
  for (final person in people) {
    print('${person.getRole()} : ${person.name}');
  }
  print('');

  // ── Afficher les étudiants ───────────────────────────────
  print('── DÉTAILS ÉTUDIANTS ──');
  for (final student in students) {
    student.printDetails();
    print('');
  }

  // ── Sealed class — Statuts académiques ──────────────────
  print('── STATUTS ACADÉMIQUES (Sealed Class) ──');
  final statuses = {
    'Alice Mvondo': Enrolled('Semestre 1 2026'),
    'Bob Essomba':  Suspended('Frais de scolarité impayés'),
    'Charlie Nkomo': Graduated(2025),
  };

  statuses.forEach((name, status) => handleStatus(name, status));
  print('');

  // ── Statistiques ─────────────────────────────────────────
  print('── STATISTIQUES DE LA CLASSE ──');
  final withGrades = students.where((s) => s.grades.isNotEmpty).toList();
  final avg = withGrades.isEmpty
      ? 0.0
      : withGrades.fold(0.0, (sum, s) => sum + s.average) / withGrades.length;

  print('Nombre d\'étudiants : ${students.length}');
  print('Moyenne générale   : ${avg.toStringAsFixed(1)}/100');
  print('Admis              : ${withGrades.where((s) => s.average >= 50).length}');
  print('Échecs             : ${withGrades.where((s) => s.average < 50).length}');
}
