import 'package:flutter_test/flutter_test.dart';
import 'package:gigachat/services/input-validations.dart';

void main() {
  late List<List> emailTestVector;

  emailTestVector = [
    ["not an email bruh", InputValidations.invalidInput],
    ["notanemailbruh", InputValidations.invalidInput],
    ["notanemail@bruh", InputValidations.invalidInput],
    ["notanemail@bruh.", InputValidations.invalidInput],
    ["anemail@bruh.com", null],
    ["anemailSSS548@bruh.com", null],
  ];
  int numberOfTests = emailTestVector.length;

  for (int i = 0; i < numberOfTests; i++) {
    test("email validation: test number #${i + 1}", () {
      expect(InputValidations.isValidEmail(emailTestVector[i][0]),
          emailTestVector[i][1]);
    });
  }
}
