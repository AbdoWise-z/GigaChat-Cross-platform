import 'package:flutter_test/flutter_test.dart';
import 'package:gigachat/services/input-validations.dart';

void main() {
  late List<List> usernameTestVector;

  usernameTestVector = [
    ["iMoA", InputValidations.usernameShortInputError],
    ["immmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm"
        "mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm"
        "mmmmmmmmmmmmmmmmmmMoA", InputValidations.usernameLongInputError],
    ["i'mMoA", InputValidations.invalidInput],
    ["im MoA", InputValidations.invalidInput],
    ["StarBoy96", null],
  ];
  int numberOfPasswords = usernameTestVector.length;

  for (int i = 0; i < numberOfPasswords; i++) {
    test("username validation: test number #${i + 1}", () {
      expect(InputValidations.isValidUsername(usernameTestVector[i][0]),
          usernameTestVector[i][1]);
    });
  }
}
