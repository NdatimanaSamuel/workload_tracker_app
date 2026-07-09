import 'package:flutter/material.dart';
import 'package:workload_tracker_app/core/constants/api_client.dart';
import 'package:workload_tracker_app/core/constants/modules_service.dart';
import 'package:workload_tracker_app/core/theme/app_theme.dart';
import 'package:workload_tracker_app/services/modules_service.dart';

class LecturerDetailScreen extends StatefulWidget {
  // We pass in the lecturer's id and name when navigating here,
  // so this screen knows WHO to fetch data for.
  final String lecturerId;
  final String lecturerName;

  const LecturerDetailScreen({
    super.key,
    required this.lecturerId,
    required this.lecturerName,
  });

  @override
  State<LecturerDetailScreen> createState() => _LecturerDetailScreenState();
}

class _LecturerDetailScreenState extends State<LecturerDetailScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _hoursData;
  List<dynamic> _modules = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Two requests running in parallel with Future.wait — faster than
      // awaiting them one after another, since neither depends on the other.
      final results = await Future.wait([
        ModulesService.getLecturerRemainingHours(widget.lecturerId),
        ModulesService.getAllDepartmentModules(),
      ]);

      final hours = results[0] as Map<String, dynamic>;
      final allModules = results[1] as List<dynamic>;

      // Filter the full department module list down to just this
      // lecturer's modules — matching by lecturerId on each module.
      final theirModules = allModules
          .where((m) => m['lecturerId'] == widget.lecturerId)
          .toList();

      setState(() {
        _hoursData = hours;
        _modules = theirModules;
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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(widget.lecturerName, style: TextStyle(color: AppColors.textPrimary, fontSize: 17)),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: AppColors.primaryLight));
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text("Retry", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    final totalHours = _hoursData!['totalHours'] as int;
    final used = _hoursData!['regularHoursUsed'] as int;
    final remaining = _hoursData!['remainingHours'] as int;
    final overtime = _hoursData!['overtimeHours'] as int;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- Same hero-card style as the lecturer's own dashboard,
          // so HOD sees exactly what the lecturer sees ----
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                Text("$remaining", style: TextStyle(color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.w600)),
                Text("of $totalHours hrs remaining", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(child: _StatBox(label: "Used", value: "${used}h")),
              const SizedBox(width: 10),
              Expanded(child: _StatBox(label: "Overtime", value: "${overtime}h")),
            ],
          ),

          const SizedBox(height: 24),

          Text("Modules", style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),

          if (_modules.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text("No modules assigned yet", style: TextStyle(color: AppColors.textSecondary)),
              ),
            )
          else
            ..._modules.map((module) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(module['name'], style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text("${module['hours']}h", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                )),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}