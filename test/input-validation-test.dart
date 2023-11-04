import 'package:flutter_test/flutter_test.dart';
import 'package:gigachat/services/input-validations.dart';



void main() {
  late List<List> passwordTestVectors;
  int numberOfPasswords = 9;

  setUp(() {
    passwordTestVectors = [
      ["allsmallcase",InputValidations.passwordWeakError],
      ["ALLCAPITAL",InputValidations.passwordWeakError],
      ["123456789",InputValidations.passwordWeakError],
      ["@###!@@##@!@!#!@",InputValidations.passwordWeakError],
      ["smol",InputValidations.passwordShortInputError],
      ["tooooO@10oooooooooooooooooooooooooooooooolaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaarge",InputValidations.passwordLongInputError],
      ["with space",InputValidations.passwordInvalidInput],
      ["wowThatsPrettyGood@100",null],
      ["",InputValidations.emptyErrorMessage],
      [null,InputValidations.emptyErrorMessage]
    ];
  });

  group("password verification tests", () {
    for (int i = 0; i < numberOfPasswords; i++) {
      test("password verfication: test number #" + (i+1).toString(), () {
        expect(InputValidations.verifyPassword(passwordTestVectors[i][0]), passwordTestVectors[i][1]);
      });
    }
  });



}
