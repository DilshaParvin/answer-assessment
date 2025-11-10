import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  String? extractedText;
  String? evaluationFeedback;
  int? evaluationScore;
  bool isLoading = false;
  final TextEditingController questionController = TextEditingController();

  Future<void> uploadImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null) return;

    setState(() => isLoading = true);

    try {
      final bytes = result.files.single.bytes;
      final fileName = result.files.single.name;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://127.0.0.1:8000/extract-text'),
      );
      request.files.add(http.MultipartFile.fromBytes('file', bytes!, filename: fileName));
      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(respStr);
        setState(() => extractedText = data['extracted_text']);
      } else {
        setState(() => extractedText = "Error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => extractedText = "Failed: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> evaluateAnswer() async {
    if (questionController.text.isEmpty || extractedText == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a question and upload an answer image.")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/evaluate-answer/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "question": questionController.text,
          "student_answer": extractedText,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['evaluation'] != null) {
        final eval = data['evaluation'];
        setState(() {
          evaluationScore = eval['score'] is num
              ? eval['score']
              : int.tryParse(eval['score'].toString().replaceAll(RegExp(r'[^0-9]'), ''));
          evaluationFeedback = eval['feedback'];
        });
      } else {
        setState(() => evaluationFeedback = "Error: ${data['detail'] ?? 'Unknown error'}");
      }
    } catch (e) {
      setState(() => evaluationFeedback = "Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> saveEvaluation() async {
    if (evaluationScore == null || evaluationFeedback == null) return;

    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('evaluations') ?? [];
    final newEval = {
      "score": evaluationScore,
      "feedback": evaluationFeedback,
      "question": questionController.text,
      "answer": extractedText,
      "date": DateTime.now().toString(),
    };
    saved.add(jsonEncode(newEval));
    await prefs.setStringList('evaluations', saved);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Evaluation saved to dashboard")),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload & Evaluate')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: questionController,
              decoration: const InputDecoration(
                labelText: "Enter Question",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: isLoading ? null : uploadImage,
              icon: const Icon(Icons.upload_file),
              label: const Text("Upload Answer Image"),
            ),
            const SizedBox(height: 12),
            if (extractedText != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      extractedText!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: isLoading ? null : evaluateAnswer,
              icon: const Icon(Icons.auto_graph),
              label: const Text("Evaluate Answer"),
            ),
            const SizedBox(height: 12),
            if (evaluationFeedback != null)
              Card(
                color: Colors.green.shade50,
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Score: ${evaluationScore ?? 'N/A'} / 10",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        evaluationFeedback!,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
            if (evaluationScore != null)
              ElevatedButton.icon(
                onPressed: saveEvaluation,
                icon: const Icon(Icons.save_alt),
                label: const Text("Save to Dashboard"),
              ),
          ],
        ),
      ),
    );
  }
}
