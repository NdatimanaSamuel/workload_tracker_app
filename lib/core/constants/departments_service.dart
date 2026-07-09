import 'package:workload_tracker_app/core/constants/api_client.dart';
import 'package:workload_tracker_app/core/constants/api_constants.dart';



class DepartmentsService {
  static Future<List<dynamic>> getAll() async {
    // withAuth: false because your backend's GET /departments has
    // no guard — it needs to be visible before login too (for the
    // Add Lecturer form's dropdown)
    return await ApiClient.get(ApiConstants.departments, withAuth: false);
  }
}