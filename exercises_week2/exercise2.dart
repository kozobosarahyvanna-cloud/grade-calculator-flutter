// ── Sealed class NetworkState (cours page 14) ─────────────────
// En Dart, on utilise sealed class (Dart 3.0+)
sealed class NetworkState {}

// ── Sous-classes ───────────────────────────────────────────────
class Loading extends NetworkState {}

class Success extends NetworkState {
  final String data;
  Success(this.data);
}

class Error extends NetworkState {
  final String message;
  Error(this.message);
}

// ── fun handleState() — when expression ───────────────────────
void handleState(NetworkState state) {
  // switch expression = when en Kotlin
  switch (state) {
    case Loading():
      print('⏳ Chargement en cours...');
    case Success(data: final d):
      print('✅ Succès : $d');
    case Error(message: final m):
      print('❌ Erreur : $m');
  }
}

// ── main() ────────────────────────────────────────────────────
void main() {
  // val states = listOf(...) — type inference
  final states = [
    Loading(),
    Success('User data loaded'),
    Error('Network timeout'),
    Success('Grades loaded'),
  ];

  print('╔══════════════════════════════════╗');
  print('║      NETWORK STATE HANDLER       ║');
  print('╚══════════════════════════════════╝');

  // for loop
  for (final state in states) {
    handleState(state);
  }
}
