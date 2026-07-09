import 'package:flutter/material.dart';
import 'package:workload_tracker_app/core/constants/api_client.dart';
import 'package:workload_tracker_app/core/constants/modules_service.dart';
import 'package:workload_tracker_app/core/theme/app_theme.dart';
import 'package:workload_tracker_app/screens/hod/lecturer_detail_screen.dart';
import 'package:workload_tracker_app/services/modules_service.dart';

class HodDashboardScreen extends StatefulWidget {
  const HodDashboardScreen({super.key});

  @override
  State<HodDashboardScreen> createState() => _HodDashboardScreenState();
}

class _HodDashboardScreenState extends State<HodDashboardScreen> {
  // These three replace the dummy variables — they hold the REAL response
  // once it comes back from the backend.
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>?
  _summaryData; // will hold {academicYear, totalHours, lecturers: [...]}

  @override
  void initState() {
    super.initState();
    // initState runs once when this screen first appears — perfect place
    // to kick off the API call, same idea as the splash screen's timer.
    _loadDepartmentSummary();
  }

  Future<void> _loadDepartmentSummary() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await ModulesService.getDepartmentSummary();
      setState(() {
        _summaryData = data;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Something went wrong. Please try again.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        // RefreshIndicator lets the user pull-down-to-refresh — nice touch
        // for a dashboard, since new modules might get added by other people
        child: RefreshIndicator(
          onRefresh: _loadDepartmentSummary,
          child: _buildBody(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.pushNamed(context, '/assign-module');
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Assign module",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  // Splitting this out keeps build() clean — decides which of the three
  // states to show: loading spinner, error message, or the real content.
  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.primaryLight),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: AppColors.textSecondary,
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadDepartmentSummary,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text(
                  "Retry",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // At this point, _summaryData is guaranteed non-null since loading
    // finished and there was no error — safe to read from it directly.
    final lecturers = _summaryData!['lecturers'] as List<dynamic>;
    final totalHours = _summaryData!['totalHours'] as int;
    final academicYear = _summaryData!['academicYear'] as String;

    return SingleChildScrollView(
      // ALWAYS scrollable, even when content is short — required for
      // RefreshIndicator's pull gesture to work properly
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Department overview",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 2),
          Text(
            academicYear,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 20),

          // ---- SUMMARY CARD ----
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _SummaryStat(
                    label: "Lecturers",
                    value: "${lecturers.length}",
                  ),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: AppColors.textSecondary.withOpacity(0.15),
                ),
                Expanded(
                  child: _SummaryStat(
                    label: "In overtime",
                    // Each "lecturer" here is a Map from real JSON, so we
                    // read lecturer['overtimeHours'] — matching exactly
                    // what your NestJS getDepartmentSummary() returns
                    value:
                        "${lecturers.where((l) => l['overtimeHours'] > 0).length}",
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Lecturers",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/add-lecturer');
                },
                child: Text(
                  "+ Add lecturer",
                  style: TextStyle(color: AppColors.primaryLight, fontSize: 13),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (lecturers.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  "No lecturers yet — add one to get started",
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            ...lecturers.map((lecturer) {
              // lecturer is a Map matching your backend's shape:
              // { lecturer: { id, names, email }, regularHoursUsed,
              //   remainingHours, overtimeHours }
              final id =
                  lecturer['lecturer']['id']; // grab the real id too, not just name

              final name = lecturer['lecturer']['names'];
              final remaining = lecturer['remainingHours'];
              final used = lecturer['regularHoursUsed'];
              final overtime = lecturer['overtimeHours'];
              final progress = (used / totalHours).clamp(0.0, 1.0);

              return _LecturerRow(
                name: name,
                remaining: remaining,
                totalHours: totalHours,
                progress: progress,
                hasOvertime: overtime > 0,
                onTap: () {
                  // Later: navigate to a lecturer detail screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LecturerDetailScreen(
                        lecturerId: id,
                        lecturerName: name,
                      ),
                    ),
                  );
                },
              );
            }),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}

class _LecturerRow extends StatelessWidget {
  final String name;
  final int remaining;
  final int totalHours;
  final double progress;
  final bool hasOvertime;
  final VoidCallback onTap;

  const _LecturerRow({
    required this.name,
    required this.remaining,
    required this.totalHours,
    required this.progress,
    required this.hasOvertime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
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
                Row(
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (hasOvertime) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.orangeAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  "$remaining / $totalHours h",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
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
          ],
        ),
      ),
    );
  }
}
