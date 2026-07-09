import 'package:workload_tracker_app/core/constants/api_client.dart';
import 'package:workload_tracker_app/core/constants/api_constants.dart';


class ModulesService {
  static Future<Map<String, dynamic>> getMyRemainingHours() async {
    return await ApiClient.get(ApiConstants.myRemainingHours);
  }

  static Future<List<dynamic>> getMyModules() async {
    return await ApiClient.get(ApiConstants.modules);
  }

  static Future<Map<String, dynamic>> createModule({
    required String name,
    required int hours,
    required String startDate,
    required String endDate,
    String? lecturerId, // only sent when HOD is assigning to someone else
  }) async {
    final data = {
      'name': name,
      'hours': hours,
      'startDate': startDate,
      'endDate': endDate,
    };
    if (lecturerId != null) {
      data['lecturerId'] = lecturerId;
    }
    return await ApiClient.post(ApiConstants.modules, data);
  }

  static Future<Map<String, dynamic>> getDepartmentSummary() async {
    return await ApiClient.get(ApiConstants.departmentSummary);
  }

  static Future<void> deleteModule(String id) async {
    await ApiClient.delete('${ApiConstants.modules}/$id');
  }

  // HOD fetching one specific lecturer's remaining hours —
// calls the endpoint we built earlier: GET /modules/lecturer/:id/remaining-hours
static Future<Map<String, dynamic>> getLecturerRemainingHours(String lecturerId) async {
  return await ApiClient.get('/modules/lecturer/$lecturerId/remaining-hours');
}

// Gets ALL modules HOD can see (whole department), which we'll then
// filter down to just one lecturer's modules on the Flutter side —
// avoids needing a brand new backend endpoint just for this.
static Future<List<dynamic>> getAllDepartmentModules() async {
  return await ApiClient.get(ApiConstants.modules); // GET /modules — HOD sees whole department
}
}