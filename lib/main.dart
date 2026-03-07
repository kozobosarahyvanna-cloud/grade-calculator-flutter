import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class Student {
  final String name;
  final String subject;
  final int? score;
  const Student({required this.name, required this.subject, this.score});
}

class GradeResult {
  final Student student;
  final String? grade;
  final String? appreciation;
  const GradeResult({required this.student, this.grade, this.appreciation});
}

String getGrade(int score) {
  if (score >= 90) return 'A';
  if (score >= 80) return 'B';
  if (score >= 70) return 'C';
  if (score >= 60) return 'D';
  return 'F';
}

String getAppreciation(String grade) {
  switch (grade) {
    case 'A': return 'Excellent !';
    case 'B': return 'Très bien';
    case 'C': return 'Bien';
    case 'D': return 'Passable';
    default:  return 'Échec';
  }
}

List<GradeResult> processGrades(List<Student> students) {
  return students.map((student) {
    final grade = student.score != null ? getGrade(student.score!) : null;
    final appreciation = grade != null ? getAppreciation(grade) : null;
    return GradeResult(student: student, grade: grade, appreciation: appreciation);
  }).toList();
}

void main() {
  runApp(const GradeCalculatorApp());
}

class GradeCalculatorApp extends StatelessWidget {
  const GradeCalculatorApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grade Calculator — ICT University',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D1B2A), primary: const Color(0xFF0D1B2A)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _students   = <Student>[];
  var _results    = <GradeResult>[];
  var _isLoading  = false;
  var _fileName   = '';
  var _calculated = false;

  static const navy  = Color(0xFF0D1B2A);
  static const gold  = Color(0xFFC9A84C);
  static const cream = Color(0xFFF5F0E8);

  final _nameCtrl    = TextEditingController();
  final _subjectCtrl = TextEditingController(text: 'Android Application Development');
  final _scoreCtrl   = TextEditingController();

  void _calculate() {
    if (_students.isEmpty) {
      _showSnack('Importez un fichier ou ajoutez des étudiants', Colors.orange);
      return;
    }
    setState(() {
      _results    = processGrades(_students);
      _calculated = true;
    });
    _showSnack('✓ ${_results.length} grades calculés !', Colors.green);
  }

  Future<void> _importExcel() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      withData: true,
    );
    if (result == null) return;

    setState(() => _isLoading = true);
    _fileName = result.files.first.name;

    try {
      final bytes = result.files.first.bytes!;
      final excel = Excel.decodeBytes(bytes);

      String? firstSheet = excel.sheets.keys.first;
      final sheet = excel.sheets[firstSheet]!;

      final newStudents = <Student>[];

      for (var i = 1; i < sheet.rows.length; i++) {
        final row = sheet.rows[i];
        if (row.isEmpty) continue;

         final name    = row[0]?.value != null ? row[0]!.value.toString().trim() : '';
final subject = row[1]?.value != null ? row[1]!.value.toString().trim() : 'Android Application Development';
final scoreRaw = row[2]?.value != null ? row[2]!.value.toString().trim() : '';

        final int? score = (scoreRaw == null || scoreRaw.isEmpty)
            ? null
            : int.tryParse(scoreRaw);

        if (name.isNotEmpty) {
          newStudents.add(Student(
            name: name,
            subject: subject,
            score: score,
          ));
        }
      }

      setState(() {
        _students  = newStudents;
        _isLoading = false;
      });

      _showSnack('✓ ${newStudents.length} étudiant(s) importé(s)', Colors.green);
      if (newStudents.isNotEmpty) _calculate();

    } catch (e, stackTrace) {
      setState(() => _isLoading = false);
      print('ERREUR: $e');
      print('STACK: $stackTrace');
      _showSnack('Erreur : $e', Colors.red);
    
    }
  }


  void _addStudent() {
    final name     = _nameCtrl.text.trim();
    final subject  = _subjectCtrl.text.trim();
    final scoreRaw = _scoreCtrl.text.trim();
    if (name.isEmpty) { _showSnack('Entrez le nom', Colors.orange); return; }
    final int? score = scoreRaw.isEmpty ? null : int.tryParse(scoreRaw);
    setState(() {
      _students.add(Student(name: name, subject: subject.isEmpty ? 'Android Application Development' : subject, score: score));
      _calculated = false;
    });
    _nameCtrl.clear(); _scoreCtrl.clear();
    _showSnack('✓ Étudiant ajouté', Colors.green);
  }

  Future<void> _exportPDF() async {
    if (!_calculated) { _showSnack('Calculez d\'abord les grades', Colors.orange); return; }
    final pdf = pw.Document();
    final withScores = _results.where((r) => r.student.score != null).toList();
    final scores = withScores.map((r) => r.student.score!).toList();
    final avg = scores.isEmpty ? 'N/A' : (scores.reduce((a, b) => a + b) / scores.length).toStringAsFixed(1);
    final passed = withScores.where((r) => r.student.score! >= 50).length;
    final failed  = withScores.length - passed;
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(30),
      build: (context) => [
        pw.Container(
          color: const PdfColor.fromInt(0xFF0D1B2A),
          padding: const pw.EdgeInsets.all(20),
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
            pw.Text('RAPPORT DES GRADES', style: pw.TextStyle(color: const PdfColor.fromInt(0xFFC9A84C), fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            pw.Text('SE 3242 — Android Application Development — ICT University', style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
            pw.Text('Généré le : ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}', style: const pw.TextStyle(color: PdfColors.white, fontSize: 9)),
          ]),
        ),
        pw.SizedBox(height: 16),
        pw.Text('STATISTIQUES', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13, color: const PdfColor.fromInt(0xFF0D1B2A))),
        pw.SizedBox(height: 8),
        pw.Row(children: [_pdfStat('Étudiants', '${_results.length}'), _pdfStat('Moyenne', '$avg/100'), _pdfStat('Admis', '$passed'), _pdfStat('Échecs', '$failed')]),
        pw.SizedBox(height: 16),
        pw.Text('RÉSULTATS DÉTAILLÉS', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13, color: const PdfColor.fromInt(0xFF0D1B2A))),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF0D1B2A)),
              children: ['Nom', 'Matière', 'Note', 'Grade', 'Appréciation'].map((h) => pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(h, style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 9)))).toList(),
            ),
            ..._results.asMap().entries.map((entry) {
              final i = entry.key; final r = entry.value;
              return pw.TableRow(
                decoration: pw.BoxDecoration(color: i.isEven ? PdfColors.grey50 : PdfColors.white),
                children: [r.student.name, r.student.subject, r.student.score != null ? '${r.student.score}/100' : 'N/A', r.grade ?? '—', r.appreciation ?? 'Aucune donnée']
                    .map((cell) => pw.Padding(padding: const pw.EdgeInsets.all(7), child: pw.Text(cell, style: const pw.TextStyle(fontSize: 9)))).toList(),
              );
            }),
          ],
        ),
      ],
    ));
    await Printing.layoutPdf(onLayout: (format) => pdf.save());
    _showSnack('✓ PDF généré !', Colors.green);
  }

  pw.Widget _pdfStat(String label, String value) {
    return pw.Expanded(child: pw.Container(
      margin: const pw.EdgeInsets.only(right: 8),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(color: const PdfColor.fromInt(0xFFF5F0E8), border: pw.Border.all(color: PdfColors.grey300), borderRadius: pw.BorderRadius.circular(6)),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
        pw.Text(value, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF0D1B2A))),
        pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
      ]),
    ));
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color, duration: const Duration(seconds: 2)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: navy,
        title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Grade Calculator Pro', style: TextStyle(color: gold, fontWeight: FontWeight.bold, fontSize: 18)),
          Text('SE 3242 — ICT University', style: TextStyle(color: Colors.white54, fontSize: 11)),
        ]),
        actions: [Container(
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(20)),
          child: const Text('Dart • Flutter', style: TextStyle(color: navy, fontSize: 11, fontWeight: FontWeight.bold)),
        )],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                _buildImportCard(),
                const SizedBox(height: 16),
                _buildManualCard(),
                const SizedBox(height: 16),
                if (_students.isNotEmpty) _buildStudentsList(),
                const SizedBox(height: 16),
                if (_calculated) _buildResultsCard(),
              ]),
            ),
    );
  }

  Widget _buildImportCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: navy, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.table_chart, color: gold, size: 20)),
            const SizedBox(width: 12),
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Importer un fichier Excel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('Format : Nom | Matière | Note', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ]),
          ]),
          const SizedBox(height: 16),
          if (_fileName.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green.shade200)),
              child: Row(children: [const Icon(Icons.check_circle, color: Colors.green, size: 18), const SizedBox(width: 8), Text(_fileName, style: const TextStyle(color: Colors.green))]),
            ),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: _importExcel,
            icon: const Icon(Icons.upload_file),
            label: const Text('Choisir fichier Excel'),
            style: ElevatedButton.styleFrom(backgroundColor: navy, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          )),
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: _calculate,
            icon: const Icon(Icons.calculate),
            label: const Text('Calculer les Grades'),
            style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: navy, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          )),
        ]),
      ),
    );
  }

  Widget _buildManualCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: navy, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.edit, color: gold, size: 20)),
            const SizedBox(width: 12),
            const Text('Saisie manuelle', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ]),
          const SizedBox(height: 16),
          TextField(controller: _nameCtrl, decoration: _inputDeco('Nom de l\'étudiant', Icons.person)),
          const SizedBox(height: 10),
          TextField(controller: _subjectCtrl, decoration: _inputDeco('Matière', Icons.book)),
          const SizedBox(height: 10),
          TextField(controller: _scoreCtrl, keyboardType: TextInputType.number, decoration: _inputDeco('Note (0-100) — laisser vide si absente', Icons.grade)),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: ElevatedButton.icon(onPressed: _addStudent, icon: const Icon(Icons.add), label: const Text('Ajouter'), style: ElevatedButton.styleFrom(backgroundColor: navy, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton.icon(onPressed: _calculate, icon: const Icon(Icons.calculate), label: const Text('Calculer'), style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: navy, padding: const EdgeInsets.symmetric(vertical: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))),
          ]),
        ]),
      ),
    );
  }

  InputDecoration _inputDeco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: navy),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: navy, width: 2)),
      filled: true, fillColor: cream,
    );
  }

  Widget _buildStudentsList() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${_students.length} étudiant(s)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Row(children: [
              TextButton.icon(onPressed: _calculate, icon: const Icon(Icons.calculate, size: 18), label: const Text('Calculer'), style: TextButton.styleFrom(foregroundColor: navy)),
              TextButton.icon(onPressed: () => setState(() { _students = []; _results = []; _calculated = false; _fileName = ''; }), icon: const Icon(Icons.delete, size: 18), label: const Text('Effacer'), style: TextButton.styleFrom(foregroundColor: Colors.red)),
            ]),
          ]),
          const Divider(),
          ..._students.asMap().entries.map((entry) {
            final i = entry.key; final s = entry.value;
            return ListTile(
              leading: CircleAvatar(backgroundColor: navy, child: Text('${i + 1}', style: const TextStyle(color: gold, fontSize: 12))),
              title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text(s.subject, style: const TextStyle(fontSize: 12)),
              trailing: Text(s.score != null ? '${s.score}/100' : 'N/A', style: TextStyle(fontWeight: FontWeight.bold, color: s.score != null ? navy : Colors.grey)),
              dense: true,
            );
          }),
        ]),
      ),
    );
  }

  Widget _buildResultsCard() {
    final withScores = _results.where((r) => r.student.score != null).toList();
    final scores = withScores.map((r) => r.student.score!).toList();
    final avg = scores.isEmpty ? 'N/A' : (scores.reduce((a, b) => a + b) / scores.length).toStringAsFixed(1);
    final passed = withScores.where((r) => r.student.score! >= 50).length;
    final failed  = withScores.length - passed;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: navy, borderRadius: BorderRadius.circular(10)),
            child: const Text('RÉSULTATS DES GRADES', textAlign: TextAlign.center, style: TextStyle(color: gold, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
          ),
          const SizedBox(height: 16),
          Row(children: [_statWidget('${_results.length}', 'Étudiants'), _statWidget(avg, 'Moyenne'), _statWidget('$passed', 'Admis', Colors.green), _statWidget('$failed', 'Échecs', Colors.red)]),
          const SizedBox(height: 16),
          ..._results.asMap().entries.map((entry) {
            final i = entry.key; final r = entry.value;
            final hasScore = r.student.score != null;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: i.isEven ? cream : Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
              child: Row(children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(color: _gradeColor(r.grade), shape: BoxShape.circle), child: Center(child: Text(r.grade ?? '?', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(r.student.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(r.student.subject, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(hasScore ? '${r.student.score}/100' : 'null', style: TextStyle(fontWeight: FontWeight.bold, color: hasScore ? navy : Colors.grey)),
                  Text(r.appreciation ?? 'Aucune donnée', style: TextStyle(fontSize: 11, color: hasScore ? Colors.grey.shade600 : Colors.grey)),
                ]),
              ]),
            );
          }),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: _exportPDF,
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Télécharger le Rapport PDF'),
            style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: navy, padding: const EdgeInsets.symmetric(vertical: 14), textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          )),
        ]),
      ),
    );
  }

  Widget _statWidget(String val, String label, [Color? color]) {
    return Expanded(child: Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: cream, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
      child: Column(children: [
        Text(val, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color ?? navy)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ]),
    ));
  }

  Color _gradeColor(String? grade) {
    switch (grade) {
      case 'A': return Colors.green.shade600;
      case 'B': return Colors.blue.shade600;
      case 'C': return Colors.orange.shade600;
      case 'D': return Colors.deepOrange.shade600;
      case 'F': return Colors.red.shade600;
      default:  return Colors.grey;
    }
  }
}