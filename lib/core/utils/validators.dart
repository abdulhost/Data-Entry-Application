// lib/core/utils/validators.dart

class Validators {
  static String? notEmpty(String? val) {
    if (val == null || val.isEmpty) return "Required";
    return null;
  }
}