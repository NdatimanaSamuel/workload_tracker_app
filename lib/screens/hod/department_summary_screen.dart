import 'package:flutter/material.dart';
import 'package:workload_tracker_app/core/theme/app_theme.dart';

class DepartmentSummaryScreen extends StatefulWidget {
  const DepartmentSummaryScreen({super.key});

  @override
  State<DepartmentSummaryScreen> createState() => _DepartmentSummaryScreenState();
}

class _DepartmentSummaryScreenState extends State<DepartmentSummaryScreen> {
  final int totalHours = 600;

  // Later this comes from GET /modules/department-summary
  final List<Map<String, dynamic>> lecturers = [
    {"name": "Jean Bosco", "used": 60, "overtime": 0},
    {"name": "Marie Claire", "used": 540, "overtime": 30},
    {"name": "Eric Niyonzima", "used": 300, "overtime": 0},
    {"name": "Alice Uwase", "used": 600, "overtime": 45},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text("Department summary", style: TextStyle(color: AppColors.textPrimary, fontSize: 17)),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: lecturers.length,
          itemBuilder: (context, index) {
            final lecturer = lecturers[index];
            final int used = lecturer["used"];
            final int overtime = lecturer["overtime"];
            final int remaining = totalHours - used;
            final double progress = (used / totalHours).clamp(0.0, 1.0);

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        lecturer["name"],
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "$remaining / $totalHours h",
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: AppColors.textSecondary.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation(AppColors.primaryLight),
                    ),
                  ),
                  // Only shown when this lecturer has overtime hours —
                  // gives HOD a clear extra detail without cluttering
                  // the row for lecturers who are within budget
                  if (overtime > 0) ...[
                    const SizedBox(height: 6),
                    Text(
                      "$overtime h overtime",
                      style: const TextStyle(color: Colors.orangeAccent, fontSize: 11),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}