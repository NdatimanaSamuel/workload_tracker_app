import 'package:flutter/material.dart';
import 'package:workload_tracker_app/core/theme/app_theme.dart';

class AddModuleScreen extends StatefulWidget {
  const AddModuleScreen({super.key});

  @override
  State<AddModuleScreen> createState() => _AddModuleScreenState();
}

class _AddModuleScreenState extends State<AddModuleScreen> {
  // Same pattern as the login screen: a form key to trigger validation,
  // and controllers to read what the user typed.
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _hoursController = TextEditingController();

  // Dates aren't typed as text — they're picked from a calendar widget,
  // so we store them as DateTime objects instead of controllers.
  // They start as "null" because nothing is picked yet.
  DateTime? _startDate;
  DateTime? _endDate;

  bool _isLoading = false;

  @override
  void dispose() {
    // Always dispose controllers when the screen is removed,
    // otherwise they stay in memory even after the screen closes.
    _nameController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  // Opens Flutter's built-in calendar picker. "context" is required because
  // the picker needs to know WHERE on screen to appear, and which app
  // theme/colors to borrow.
  Future<void> _pickDate({required bool isStartDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020), // earliest selectable date
      lastDate: DateTime(2035), // latest selectable date
    );

    // showDatePicker returns null if the user cancels/taps outside it —
    // so we only update state if they actually picked something.
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

  // Small helper to turn a DateTime into a readable string like "07 Sep 2026"
  // instead of the raw DateTime format, which looks messy on screen.
  String _formatDate(DateTime? date) {
    if (date == null) return "Select date";
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  void _handleSave() async {
    // First check: normal text field validation (name/hours not empty, etc.)
    if (!_formKey.currentState!.validate()) return;

    // Second check: dates are picked separately from TextFormField, so
    // they need their OWN validation here — validator() doesn't cover them.
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select both start and end dates")),
      );
      return;
    }

    // Third check: end date must be after start date — same rule your
    // backend enforces, good to catch it on the frontend too so the user
    // doesn't waste a network request on an invalid entry.
    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("End date must be after start date")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // TODO: replace with real POST /modules call once API layer is built.
    // The payload will look like:
    // {
    //   "name": _nameController.text,
    //   "hours": int.parse(_hoursController.text),
    //   "startDate": _startDate.toIso8601String(),
    //   "endDate": _endDate.toIso8601String(),
    // }
    await Future.delayed(const Duration(seconds: 2)); // fake delay for now

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pop(context); // closes this screen, returns to dashboard
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0, // removes the default shadow under the app bar
        title: Text(
          "Add module",
          style: TextStyle(color: AppColors.textPrimary, fontSize: 17),
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary), // back arrow color
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---- MODULE NAME ----
                Text(
                  "Module name",
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: _inputDecoration("e.g. Database Systems"),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Module name is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // ---- HOURS ----
                Text(
                  "Hours",
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _hoursController,
                  style: TextStyle(color: AppColors.textPrimary),
                  // Restricts the keyboard to numbers only — better mobile UX
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration("e.g. 60"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Hours is required';
                    }
                    // tryParse returns null if the text isn't a valid number,
                    // e.g. if someone typed letters instead of digits
                    final hours = int.tryParse(value);
                    if (hours == null || hours <= 0) {
                      return 'Enter a valid number of hours';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // ---- START DATE ----
                Text(
                  "Start date",
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 6),
                // GestureDetector makes a non-button widget (like Container)
                // tappable — we use this instead of a TextFormField because
                // we don't want the user typing a date manually, only picking one.
                GestureDetector(
                  onTap: () => _pickDate(isStartDate: true),
                  child: _DateBox(label: _formatDate(_startDate)),
                ),

                const SizedBox(height: 18),

                // ---- END DATE ----
                Text(
                  "End date",
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => _pickDate(isStartDate: false),
                  child: _DateBox(label: _formatDate(_endDate)),
                ),

                const SizedBox(height: 32),

                // ---- SAVE BUTTON ----
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Text(
                            "Save module",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Shared styling for the two text fields, same idea as the login screen —
  // avoids repeating this decoration code twice.
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5)),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.primaryLight, width: 1.5),
      ),
    );
  }
}

// A small reusable widget styled to LOOK like a text field, but it's
// actually just a Container — because tapping it opens a date picker
// instead of letting the user type directly.
class _DateBox extends StatelessWidget {
  final String label;

  const _DateBox({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today_outlined,
              size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}