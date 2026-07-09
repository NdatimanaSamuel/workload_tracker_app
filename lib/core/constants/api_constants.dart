// Central place for your API's base URL. If you ever change domains
// (custom domain, staging environment, etc.), you edit ONE line here —
// not every file that makes an API call.
class ApiConstants {
  static const String baseUrl = "https://workload-tracker-api.fly.dev";

  // Grouping endpoint paths here too, so nothing is hardcoded
  // as a raw string scattered across your services
  static const String login = "/auth/signin";
  static const String users = "/users";
  static const String departments = "/departments";
  static const String modules = "/modules";
  static const String myRemainingHours = "/modules/my-remaining-hours";
  static const String departmentSummary = "/modules/department-summary";
}