import 'package:flutter/material.dart';
import 'package:workload_tracker_app/core/constants/api_client.dart';
import 'package:workload_tracker_app/core/constants/auth_service.dart';
import 'package:workload_tracker_app/core/constants/departments_service.dart';
import 'package:workload_tracker_app/core/theme/app_theme.dart';
import 'package:workload_tracker_app/services/departments_service.dart';
import 'package:workload_tracker_app/services/auth_service.dart';

class AddLecturerScreen extends StatefulWidget {
  const AddLecturerScreen({super.key});

  @override
  State<AddLecturerScreen> createState() => _AddLecturerScreenState();
}

class _AddLecturerScreenState extends State<AddLecturerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namesController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedRole = "LECTURER";

  // These two replace the hardcoded dummy list — real departments come
  // from the backend now, loaded once when the screen opens.
  List<dynamic> _departments = [];
  bool _loadingDepartments = true;
  String? _selectedDepartmentId; // now stores the real UUID, not just a name

  bool _obscurePassword = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    try {
      final data = await DepartmentsService.getAll();
      setState(() {
        _departments = data;
        _loadingDepartments = false;
      });
    } catch (e) {
      setState(() => _loadingDepartments = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load departments")),
        );
      }
    }
  }

  @override
  void dispose() {
    _namesController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDepartmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a department")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Calls the real POST /users endpoint — same one you tested
      // in Postman earlier when creating your first lecturer.
      await AuthService.createUser(
        names: _namesController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
        departmentId: _selectedDepartmentId!,
      );

      setState(() => _isSaving = false);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account created successfully")),
      );
      Navigator.pop(context); // go back to HOD dashboard
    } on ApiException catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)), // shows real backend errors, e.g. "Email already exists"
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
        title: Text("Add lecturer", style: TextStyle(color: AppColors.textPrimary, fontSize: 17)),
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
                _FieldLabel("Full name"),
                TextFormField(
                  controller: _namesController,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: _inputDecoration("e.g. Jean Bosco"),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? 'Full name is required' : null,
                ),

                const SizedBox(height: 18),

                _FieldLabel("Email"),
                TextFormField(
                  controller: _emailController,
                  style: TextStyle(color: AppColors.textPrimary),
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration("e.g. jean@ulk.ac.rw"),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Email is required';
                    if (!value.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                _FieldLabel("Phone"),
                TextFormField(
                  controller: _phoneController,
                  style: TextStyle(color: AppColors.textPrimary),
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration("e.g. +250788123456"),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? 'Phone number is required' : null,
                ),

                const SizedBox(height: 18),

                _FieldLabel("Temporary password"),
                TextFormField(
                  controller: _passwordController,
                  style: TextStyle(color: AppColors.textPrimary),
                  obscureText: _obscurePassword,
                  decoration: _inputDecoration("Min. 6 characters").copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Password is required';
                    if (value.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                _FieldLabel("Role"),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _RoleChip(
                        label: "Lecturer",
                        selected: _selectedRole == "LECTURER",
                        onTap: () => setState(() => _selectedRole = "LECTURER"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _RoleChip(
                        label: "HOD",
                        selected: _selectedRole == "HOD",
                        onTap: () => setState(() => _selectedRole = "HOD"),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                _FieldLabel("Department"),
                const SizedBox(height: 6),

                // Show a small loading row while departments are being fetched,
                // instead of an empty/broken-looking dropdown
                _loadingDepartments
                    ? Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryLight),
                            ),
                            const SizedBox(width: 10),
                            Text("Loading departments...", style: TextStyle(color: AppColors.textSecondary)),
                          ],
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedDepartmentId,
                            isExpanded: true,
                            dropdownColor: AppColors.surface,
                            hint: Text("Select department", style: TextStyle(color: AppColors.textSecondary.withOpacity(0.5))),
                            style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                            icon: Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                            // Each department from the API is a Map like { id, name },
                            // so we map its real "id" as the dropdown value,
                            // and show its "name" as the visible label.
                            items: _departments.map((dept) {
                              return DropdownMenuItem<String>(
                                value: dept['id'],
                                child: Text(dept['name']),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => _selectedDepartmentId = value),
                          ),
                        ),
                      ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _handleCreate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                          )
                        : const Text("Create account",
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

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RoleChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? AppColors.primary : AppColors.textSecondary.withOpacity(0.2)),
        ),
        child: Text(label, style: TextStyle(color: selected ? Colors.white : AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
      ),
    );
  }
}