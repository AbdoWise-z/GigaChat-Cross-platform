import 'package:flutter_test/flutter_test.dart';
import 'package:gigachat/services/input-validations.dart';



void main() {
  late List<List> passwordTestVectors;
  int numberOfPasswords = 9;

  setUp(() {
    passwordTestVectors = const [
      ["allsmallcase",false],
      ["ALLCAPITAL",false],
      ["123456789",false],
      ["@###!@@##@!@!#!@",false],
      ["smol",false],
      ["tooooO@10oooooooooooooooooooooooooooooooolaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaarge",false],
      ["with space",false],
      ["wowThatsPrettyGood@100",true],
      ["",false],
      [null,false]
    ];
  });

  group("password verification tests", () {
    for (int i = 0; i < numberOfPasswords; i++) {
      test("password verfication: test number #" + i.toString(), () {
        expect(InputValidations.verifyPassword(passwordTestVectors[i][0]), passwordTestVectors[i][1]);
      });
    }
  });



}
