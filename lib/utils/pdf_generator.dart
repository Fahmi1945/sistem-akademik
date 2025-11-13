// ========================================
// FILE: utils/pdf_generator.dart
// ========================================

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/siswa.dart';
import '../models/nilai.dart';

class PDFGenerator {
  Future<void> generateRaporPDF(Siswa siswa, List<Nilai> nilaiList) async {
    final pdf = pw.Document();

    // Calculate statistics
    double totalNilai = 0;
    double nilaiTertinggi = 0;
    double nilaiTerendah = 100;
    int jumlahA = 0, jumlahB = 0, jumlahC = 0, jumlahD = 0;

    for (var nilai in nilaiList) {
      totalNilai += nilai.nilaiAkhir;
      if (nilai.nilaiAkhir > nilaiTertinggi) nilaiTertinggi = nilai.nilaiAkhir;
      if (nilai.nilaiAkhir < nilaiTerendah) nilaiTerendah = nilai.nilaiAkhir;

      switch (nilai.predikat) {
        case 'A':
          jumlahA++;
          break;
        case 'B':
          jumlahB++;
          break;
        case 'C':
          jumlahC++;
          break;
        case 'D':
          jumlahD++;
          break;
      }
    }

    final rataRata = nilaiList.isNotEmpty ? totalNilai / nilaiList.length : 0;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          // Header
          pw.Center(
            child: pw.Column(
              children: [
                pw.Text(
                  'SEKOLAH XYZ',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'RAPOR SISWA',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Tahun Ajaran 2024/2025',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Student Info
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(border: pw.Border.all()),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Nama', siswa.nama),
                _buildInfoRow('NIS', siswa.nis),
                _buildInfoRow('Kelas', siswa.kelas),
                _buildInfoRow('Jurusan', siswa.jurusan),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Statistics
          pw.Text(
            'RINGKASAN NILAI',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              border: pw.Border.all(),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn('Rata-rata', rataRata.toStringAsFixed(2)),
                _buildStatColumn(
                  'Tertinggi',
                  nilaiTertinggi.toStringAsFixed(2),
                ),
                _buildStatColumn('Terendah', nilaiTerendah.toStringAsFixed(2)),
                _buildStatColumn('Total Mapel', nilaiList.length.toString()),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Nilai Table
          pw.Text(
            'DAFTAR NILAI',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              // Header
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  _buildTableCell('No', isHeader: true),
                  _buildTableCell('Mata Pelajaran', isHeader: true),
                  _buildTableCell('Tugas\n(30%)', isHeader: true),
                  _buildTableCell('UTS\n(30%)', isHeader: true),
                  _buildTableCell('UAS\n(40%)', isHeader: true),
                  _buildTableCell('Nilai\nAkhir', isHeader: true),
                  _buildTableCell('Predikat', isHeader: true),
                ],
              ),
              // Data rows
              ...List.generate(nilaiList.length, (index) {
                final nilai = nilaiList[index];
                return pw.TableRow(
                  children: [
                    _buildTableCell('${index + 1}'),
                    _buildTableCell(nilai.mataPelajaran),
                    _buildTableCell(nilai.nilaiTugas.toStringAsFixed(0)),
                    _buildTableCell(nilai.nilaiUTS.toStringAsFixed(0)),
                    _buildTableCell(nilai.nilaiUAS.toStringAsFixed(0)),
                    _buildTableCell(
                      nilai.nilaiAkhir.toStringAsFixed(2),
                      isBold: true,
                    ),
                    _buildTableCell(nilai.predikat, isBold: true),
                  ],
                );
              }),
            ],
          ),
          pw.SizedBox(height: 20),

          // Legend
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(border: pw.Border.all()),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'KETERANGAN PREDIKAT:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 8),
                pw.Text('A = Sangat Baik (≥ 85)'),
                pw.Text('B = Baik (75 - 84)'),
                pw.Text('C = Cukup (65 - 74)'),
                pw.Text('D = Kurang (< 65)'),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Distribution
          pw.Text(
            'DISTRIBUSI PREDIKAT',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildPredikatBox('A', jumlahA),
              _buildPredikatBox('B', jumlahB),
              _buildPredikatBox('C', jumlahC),
              _buildPredikatBox('D', jumlahD),
            ],
          ),
          pw.SizedBox(height: 40),

          // Footer
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text('Bojonegoro, ${_getCurrentDate()}'),
                  pw.SizedBox(height: 4),
                  pw.Text('Wali Kelas'),
                  pw.SizedBox(height: 40),
                  pw.Container(
                    width: 150,
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(bottom: pw.BorderSide()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    // Save and share PDF
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text(': $value'),
        ],
      ),
    );
  }

  pw.Widget _buildStatColumn(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
      ],
    );
  }

  pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    bool isBold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Center(
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontWeight: isHeader || isBold
                ? pw.FontWeight.bold
                : pw.FontWeight.normal,
            fontSize: isHeader ? 10 : 9,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ),
    );
  }

  pw.Widget _buildPredikatBox(String predikat, int count) {
    return pw.Container(
      width: 60,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(border: pw.Border.all()),
      child: pw.Column(
        children: [
          pw.Text(
            predikat,
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text('$count'),
        ],
      ),
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }
}
