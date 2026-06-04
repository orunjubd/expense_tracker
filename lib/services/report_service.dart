import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../models/expense.dart'; // Links to your pure data blueprint structure

class ReportService {
  // 1. GENERATE AND EXPORT TO CSV
  Future<void> exportToCSV(List<Expense> expenses) async {
    List<List<dynamic>> data = [
      ['ID', 'Title', 'Amount', 'Date', 'Category'], // Header row
    ];

    for (var expense in expenses) {
      data.add([
        expense.id,
        expense.title,
        expense.amount,
        expense.date.toString().split(' ')[0], // Keeps date format clean
        expense.category.name,
      ]);
    }

    String csvString = const ListToCsvConverter().convert(data);
    final directory = await getTemporaryDirectory();
    final file = File(
      '${directory.path}/Expense_Report_${DateTime.now().millisecondsSinceEpoch}.csv',
    );

    await file.writeAsString(csvString);
    await Share.shareXFiles([XFile(file.path)], text: 'TrackFlow CSV Export');
  }

  // 2. GENERATE AND EXPORT TO PDF
  Future<void> exportToPDF(List<Expense> expenses) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            //cross: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'TrackFlow Expense Summary',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text('Generated on: ${DateTime.now().toLocal()}'),
              pw.Divider(),
              pw.SizedBox(height: 15),
              pw.TableHelper.fromTextArray(
                headers: ['Title', 'Amount', 'Date', 'Category'],
                data: expenses
                    .map(
                      (e) => [
                        e.title,
                        'Tk ${e.amount.toStringAsFixed(2)}',
                        e.date.toString().split(' ')[0],
                        e.category.name,
                      ],
                    )
                    .toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                cellAlignment: pw.Alignment.centerLeft,
              ),
            ],
          );
        },
      ),
    );

    final directory = await getTemporaryDirectory();
    final file = File(
      '${directory.path}/Expense_Report_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );

    await file.writeAsBytes(await pdf.save());
    await Share.shareXFiles([XFile(file.path)], text: 'TrackFlow PDF Export');
  }
}
