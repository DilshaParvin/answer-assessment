import 'package:flutter/material.dart';

class EvaluationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> evaluation;

  const EvaluationDetailScreen({super.key, required this.evaluation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Evaluation Details"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 2,
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Text(
                  evaluation['date'] ?? 'Unknown Date',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                const Text("Question:", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(evaluation['question'] ?? '—', style: const TextStyle(fontSize: 15)),
                const SizedBox(height: 12),
                const Text("Student Answer:", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(evaluation['answer'] ?? '—', style: const TextStyle(fontSize: 15)),
                const SizedBox(height: 12),
                const Text("Score:", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("${evaluation['score']} / 10", style: const TextStyle(fontSize: 15, color: Colors.deepPurple)),
                const SizedBox(height: 12),
                const Text("Feedback:", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(evaluation['feedback'] ?? '—', style: const TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
