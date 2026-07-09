import 'package:flutter/material.dart';
import 'package:workload_tracker_app/core/theme/app_theme.dart';

class LecturerDashboardScreen extends StatefulWidget {
  const LecturerDashboardScreen({super.key});

  @override
  State<LecturerDashboardScreen> createState() =>
      _LecturerDashboardScreenState();
}

class _LecturerDashboardScreenState extends State<LecturerDashboardScreen> {
  // ---- DUMMY DATA FOR NOW ----
  // Once we build the API layer, these values will come from
  // GET /modules/my-remaining-hours and GET /modules instead of
  // being typed here by hand.
  final String lecturerName = "Jean Bosco";
  final int totalHours = 600;
  final int usedHours = 60;
  final int overtimeHours = 0;
  final String academicYearLabel = "2025/2026";

  final List<Map<String, dynamic>> modules = [
    {
      "name": "Computer Programming with C++",
      "hours": 60,
      "start": "May 1",
      "end": "Jun 15",
    },
    {
      "name": "Database Systems",
      "hours": 45,
      "start": "Sep 1",
      "end": "Dec 15",
    },
  ];

  @override
  Widget build(BuildContext context) {
    // remainingHours is calculated from the dummy numbers above.
    // Later, this will just come directly from the API response instead
    // of being computed here.
    final int remainingHours = totalHours - usedHours;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          // ListView/SingleChildScrollView so the screen scrolls if the
          // module list grows longer than the visible screen height
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- GREETING ----
              Text(
                "Welcome back",
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                lecturerName,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 20),

              // ---- HERO CARD: circular remaining-hours indicator ----
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Stack layers the progress ring and the text
                    // ON TOP of each other, instead of side by side
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Background ring (the "empty" track)
                          SizedBox(
                            width: 140,
                            height: 140,
                            child: CircularProgressIndicator(
                              value: 1, // full circle, drawn first as the base track
                              strokeWidth: 10,
                              valueColor: AlwaysStoppedAnimation(
                                AppColors.textSecondary.withOpacity(0.15),
                              ),
                            ),
                          ),
                          // Foreground ring (the actual progress)
                          SizedBox(
                            width: 140,
                            height: 140,
                            child: CircularProgressIndicator(
                              // value must be between 0.0 and 1.0 — this is
                              // WHAT FRACTION of the circle gets filled in
                              value: usedHours / totalHours,
                              strokeWidth: 10,
                              valueColor: AlwaysStoppedAnimation(
                                AppColors.primaryLight,
                              ),
                            ),
                          ),
                          // The number + label sitting in the middle of the ring
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "$remainingHours",
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "of $totalHours hrs",
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "$academicYearLabel academic year",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ---- USED / OVERTIME STAT ROW ----
              Row(
                children: [
                  Expanded(
                    child: _StatBox(label: "Used", value: "${usedHours}h"),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatBox(
                      label: "Overtime",
                      value: "${overtimeHours}h",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ---- "MY MODULES" SECTION HEADER ----
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "My modules",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ---- MODULE LIST ----
              // We use .map() to turn each dummy module into a card widget.
              // Later this will map over real data from GET /modules instead.
              ...modules.map((module) => _ModuleCard(module: module)),

              const SizedBox(height: 80), // space so FAB doesn't cover last card
            ],
          ),
        ),
      ),

      // ---- FLOATING ADD BUTTON ----
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
           Navigator.pushNamed(context, '/add-module');
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// A small reusable widget for the "Used" / "Overtime" boxes.
// Pulling this out into its own class keeps the main build() method
// shorter and easier to read.
class _StatBox extends StatelessWidget {
  final String label;
  final String value;

  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Another reusable widget — one card per module in the list.
// Takes a Map right now (matching our dummy data); once we build the
// real Module model class, this will accept a Module object instead.
class _ModuleCard extends StatelessWidget {
  final Map<String, dynamic> module;

  const _ModuleCard({required this.module});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.textSecondary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            module["name"],
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.access_time, size: 13, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                "${module["hours"]}h · ${module["start"]} - ${module["end"]}",
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}