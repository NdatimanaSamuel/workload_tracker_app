import 'package:flutter/material.dart';
import 'package:workload_tracker_app/core/theme/app_theme.dart';

class MyModulesScreen extends StatefulWidget {
  const MyModulesScreen({super.key});

  @override
  State<MyModulesScreen> createState() => _MyModulesScreenState();
}

class _MyModulesScreenState extends State<MyModulesScreen> {
  // Dummy data for now — later this comes from GET /modules
  final List<Map<String, dynamic>> modules = [
    {"name": "Computer Programming with C++", "hours": 60, "start": "May 1", "end": "Jun 15"},
    {"name": "Database Systems", "hours": 45, "start": "Sep 1", "end": "Dec 15"},
    {"name": "Data Structures", "hours": 50, "start": "Jan 10", "end": "Mar 20"},
  ];

  // Shows a confirmation popup before actually deleting — this protects
  // against accidental taps removing real data.
  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text("Delete module?", style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          "This will remove \"${modules[index]["name"]}\" permanently.",
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // just closes the dialog
            child: Text("Cancel", style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              // TODO: call DELETE /modules/:id here later
              setState(() => modules.removeAt(index)); // remove from local list
              Navigator.pop(context); // close the dialog
            },
            child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text("My modules", style: TextStyle(color: AppColors.textPrimary, fontSize: 17)),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        // ListView.builder is more efficient than a plain Column + .map()
        // for long lists — it only builds the items currently visible on
        // screen, instead of building all of them at once upfront.
        child: modules.isEmpty
            ? Center(
                child: Text(
                  "No modules added yet",
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: modules.length, // how many items to build
                itemBuilder: (context, index) {
                  // itemBuilder runs once per item — "index" tells us WHICH
                  // one we're currently building (0, 1, 2, ...)
                  final module = modules[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
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
                              Text(
                                "${module["hours"]}h · ${module["start"]} - ${module["end"]}",
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        // PopupMenuButton gives a small "..." menu with
                        // Edit/Delete options, instead of cluttering the
                        // row with two separate icon buttons
                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, color: AppColors.textSecondary, size: 20),
                          color: AppColors.surface,
                          onSelected: (value) {
                            if (value == "delete") {
                              _confirmDelete(index);
                            } else if (value == "edit") {
                              // Later: navigate to AddModuleScreen pre-filled
                              // with this module's data for editing
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: "edit",
                              child: Text("Edit", style: TextStyle(color: AppColors.textPrimary)),
                            ),
                            PopupMenuItem(
                              value: "delete",
                              child: Text("Delete", style: TextStyle(color: Colors.redAccent)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}