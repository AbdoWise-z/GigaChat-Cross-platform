import 'package:flutter_test/flutter_test.dart';
import 'package:gigachat/services/input-validations.dart';

void main() {
  late List<List> passwordTestVectors;

  passwordTestVectors = [
    ["mohamed456",null],
    ["moh",InputValidations.passwordShortInputError],
    ["mohhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh",
      InputValidations.passwordLongInputError],
  ];
  int numberOfPasswords = passwordTestVectors.length;

  for (int i = 0; i < numberOfPasswords; i++) {
    test("password validation: test number #${i + 1}", () {
      expect(InputValidations.isValidPassword(passwordTestVectors[i][0]),
          passwordTestVectors[i][1]);
    });
  }
}
