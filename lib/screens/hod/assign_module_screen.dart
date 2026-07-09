import 'package:flutter/material.dart';
import 'package:workload_tracker_app/core/constants/api_client.dart';
import 'package:workload_tracker_app/core/constants/modules_service.dart';
import 'package:workload_tracker_app/core/theme/app_theme.dart';
import 'package:workload_tracker_app/services/modules_service.dart';

class AssignModuleScreen extends StatefulWidget {
  const AssignModuleScreen({super.key});

  @override
  State<AssignModuleScreen> createState() => _AssignModuleScreenState();
}

class _AssignModuleScreenState extends State<AssignModuleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _hoursController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSaving = false;

  // Replaces the dummy list — now holds real lecturers pulled from
  // the backend, loaded once when this screen opens.
  List<dynamic> _lecturers = [];
  bool _loadingLecturers = true;
  String? _selectedLecturerId;

  @override
  void initState() {
    super.initState();
    _loadLecturers();
  }

  Future<void> _loadLecturers() async {
    try {
      // We reuse the department summary endpoint — it already returns
      // every lecturer in the HOD's department, just nested inside
      // a "lecturers" array alongside their hours. We only need the
      // id/name part here, so we pull just that out.
      final data = await ModulesService.getDepartmentSummary();
      final lecturersData = data['lecturers'] as List<dynamic>;

      setState(() {
        // Each item looks like { lecturer: {id, names, email}, ... } —
        // we map it down to just the lecturer info we actually need
        // for this dropdown.
        _lecturers = lecturersData.map((entry) => entry['lecturer']).toList();
        _loadingLecturers = false;
      });
    } catch (e) {
      setState(() => _loadingLecturers = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load lecturers")),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStartDate}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "Select date";
    const months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  void _handleAssign() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedLecturerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a lecturer")),
      );
      return;
    }
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select both dates")),
      );
      return;
    }
    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("End date must be after start date")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Real call now — lecturerId is included, which is exactly what
      // tells your backend "this is HOD assigning to someone else"
      // (the logic we built in ModulesService.create() on the backend).
      await ModulesService.createModule(
        name: _nameController.text.trim(),
        hours: int.parse(_hoursController.text),
        startDate: _startDate!.toIso8601String(),
        endDate: _endDate!.toIso8601String(),
        lecturerId: _selectedLecturerId,
      );

      setState(() => _isSaving = false);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Module assigned successfully")),
      );
      Navigator.pop(context);
    } on ApiException catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)), // shows real backend error, e.g. active year not found
      );
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text("Assign module", style: TextStyle(color: AppColors.textPrimary, fontSize: 17)),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Assign to", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 6),

                // Same loading-row pattern as the department dropdown in
                // Add Lecturer — avoids showing an empty/broken dropdown
                // while the real data is still being fetched.
                _loadingLecturers
                    ? Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryLight),
                            ),
                            const SizedBox(width: 10),
                            Text("Loading lecturers...", style: TextStyle(color: AppColors.textSecondary)),
                          ],
                        ),
                      )
                    : _lecturers.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)),
                            child: Text(
                              "No lecturers in your department yet",
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedLecturerId,
                                isExpanded: true,
                                dropdownColor: AppColors.surface,
                                hint: Text("Select lecturer", style: TextStyle(color: AppColors.textSecondary.withOpacity(0.5))),
                                style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                                icon: Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                                items: _lecturers.map((lecturer) {
                                  return DropdownMenuItem<String>(
                                    value: lecturer['id'],
                                    child: Text(lecturer['names']),
                                  );
                                }).toList(),
                                onChanged: (value) => setState(() => _selectedLecturerId = value),
                              ),
                            ),
                          ),

                const SizedBox(height: 18),

                Text("Module name", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: _inputDecoration("e.g. Networking Fundamentals"),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? 'Module name is required' : null,
                ),

                const SizedBox(height: 18),

                Text("Hours", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _hoursController,
                  style: TextStyle(color: AppColors.textPrimary),
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration("e.g. 45"),
                  validator: (value) {
                    final hours = int.tryParse(value ?? '');
                    if (hours == null || hours <= 0) return 'Enter a valid number of hours';
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                Text("Start date", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => _pickDate(isStartDate: true),
                  child: _DateBox(label: _formatDate(_startDate)),
                ),

                const SizedBox(height: 18),

                Text("End date", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => _pickDate(isStartDate: false),
                  child: _DateBox(label: _formatDate(_endDate)),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _handleAssign,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                          )
                        : const Text("Assign module",
                            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5)),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.primaryLight, width: 1.5),
      ),
    );
  }
}

class _DateBox extends StatelessWidget {
  final String label;
  const _DateBox({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
        ],
      ),
    );
  }
}