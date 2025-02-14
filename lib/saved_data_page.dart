import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:share_plus/share_plus.dart';
import 'database_helper.dart';

class SavedDataPage extends StatefulWidget {
  const SavedDataPage({super.key});

  @override
  SavedDataPageState createState() => SavedDataPageState();
}

class SavedDataPageState extends State<SavedDataPage> {
  late Future<List<Map<String, dynamic>>> _savedColors;

  @override
  void initState() {
    super.initState();
    _fetchSavedColors();
  }

  void _fetchSavedColors() {
    setState(() {
      _savedColors = DatabaseHelper().fetchExtractedColors();
    });
  }

  Future<void> _clearDatabase() async {
    bool confirmDelete = await _showDeleteConfirmation();
    if (!confirmDelete || !mounted) return;

    await DatabaseHelper().clearDatabase();

    if (!mounted) return;
    _fetchSavedColors();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("All saved data cleared!")),
    );
  }

  Future<bool> _showDeleteConfirmation() async {
    if (!mounted) return false;
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Confirm Deletion"),
              content:
                  const Text("Are you sure you want to delete all saved data?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child:
                      const Text("Delete", style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _exportToExcel() async {
    List<Map<String, dynamic>> data =
        await DatabaseHelper().fetchExtractedColors();
    if (data.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No data available for export.")),
      );
      return;
    }

    final xlsio.Workbook workbook = xlsio.Workbook();
    final xlsio.Worksheet sheet = workbook.worksheets[0];

    final List<String> headers = [
      'Entry',
      'R',
      'G',
      'B',
      'L',
      'a',
      'b',
      'H',
      'S',
      'V'
    ];
    for (int i = 0; i < headers.length; i++) {
      sheet.getRangeByIndex(1, i + 1).setText(headers[i]);
    }

    for (int rowIndex = 0; rowIndex < data.length; rowIndex++) {
      Map<String, dynamic> colorData = data[rowIndex];

      List<String> extractedValues = colorData['extractedData']
          .replaceAll(RegExp(r'[\{\}]'), '')
          .split(', ');

      List<String> colorValues =
          extractedValues.map((e) => e.split(': ')[1]).toList();

      sheet.getRangeByIndex(rowIndex + 2, 1).setText((rowIndex + 1).toString());
      for (int colIndex = 0; colIndex < colorValues.length; colIndex++) {
        sheet
            .getRangeByIndex(rowIndex + 2, colIndex + 2)
            .setText(colorValues[colIndex]);
      }
    }

    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = "${directory.path}/Extracted_Colors.xlsx";
    final File file = File(filePath);
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();
    await file.writeAsBytes(bytes);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Excel file saved at: $filePath")),
    );

    Share.shareXFiles([XFile(filePath)],
        text: "Here is the extracted color data.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Saved Colors")),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical, // Enable vertical scrolling
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal, // Enable horizontal scrolling
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _savedColors,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("No saved colors yet"));
                    }

                    List<Map<String, dynamic>> data = snapshot.data!;

                    return DataTable(
                      columnSpacing: 12,
                      border: TableBorder.all(width: 1.0, color: Colors.grey),
                      columns: const [
                        DataColumn(
                            label: Center(
                                child: Text("Entry",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold)))),
                        DataColumn(
                            label: Center(
                                child: Text("R",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold)))),
                        DataColumn(
                            label: Center(
                                child: Text("G",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold)))),
                        DataColumn(
                            label: Center(
                                child: Text("B",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold)))),
                        DataColumn(
                            label: Center(
                                child: Text("L",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold)))),
                        DataColumn(
                            label: Center(
                                child: Text("a",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold)))),
                        DataColumn(
                            label: Center(
                                child: Text("b",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold)))),
                        DataColumn(
                            label: Center(
                                child: Text("H",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold)))),
                        DataColumn(
                            label: Center(
                                child: Text("S",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold)))),
                        DataColumn(
                            label: Center(
                                child: Text("V",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold)))),
                      ],
                      rows: data.asMap().entries.map((entry) {
                        int index = entry.key + 1;
                        Map<String, dynamic> colorData = entry.value;

                        List<String> extractedValues =
                            colorData['extractedData']
                                .replaceAll(RegExp(r'[\{\}]'), '')
                                .split(', ');

                        List<String> colorValues = extractedValues
                            .map((e) => e.split(': ')[1])
                            .toList();

                        return DataRow(
                          cells: [
                            DataCell(Center(child: Text(index.toString()))),
                            ...colorValues.map((value) =>
                                DataCell(Center(child: Text(value)))),
                          ],
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ),
          ),
          // Buttons at the bottom
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.delete),
                  label: const Text("Clear All Data"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: _clearDatabase,
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.file_download),
                  label: const Text("Export"),
                  onPressed: _exportToExcel,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
