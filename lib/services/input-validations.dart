

import 'package:string_validator/string_validator.dart';

const MIN_USERNAME_LENGTH = 6;
const MAX_USERNAME_LENGTH = 20;

const MIN_PASSWORD_LENGTH = 6;
const MAX_PASSWORD_LENGTH = 64;

class InputValidations
{
     static String emptyErrorMessage = "this field cannot be empty";

     static String usernameLongInputError = "username is too long";
     static String usernameShortInputError = "username is too short";

     static String passwordLongInputError = "password is too long";
     static String passwordShortInputError = "password is too short";
     static String passwordWeakError = "weak password!";
     static String passwordInvalidInput = "invalid input";


     static String? verifyUsername(String? username)
     {
          if (username == null || username.isEmpty) {
            return emptyErrorMessage;
          }

          if (username.length < MIN_USERNAME_LENGTH) {
            return usernameShortInputError;
          }

          if (username.length > MAX_USERNAME_LENGTH) {
            return usernameLongInputError;
          }

          return null;
     }

     static String? verifyPassword(String? password)
     {
          if (password == null || password.isEmpty) {
            return emptyErrorMessage;
          }
          if (password.length < MIN_PASSWORD_LENGTH){
               return passwordShortInputError;
          }
          if (password.length > MAX_PASSWORD_LENGTH){
               return passwordLongInputError;
          }

          RegExp validCharacters = RegExp("[a-zA-Z0-9@#!_\$]");
          bool satisfyRegex = validCharacters.allMatches(password).length == password.length;
          if (!satisfyRegex)
          {
               return passwordInvalidInput;
          }

          RegExp specialChars = RegExp("[@!\$#_-]");
          RegExp lowerCase = RegExp("[a-z]");
          RegExp upperCase = RegExp("[A-Z]");
          RegExp numbers = RegExp("[0-9]");

          bool hasLowerCase = lowerCase.hasMatch(password);
          bool hasUpperCase = upperCase.hasMatch(password);
          bool hasNumber = numbers.hasMatch(password);
          bool hasSpecial = specialChars.hasMatch(password);

          return hasSpecial && hasLowerCase && hasUpperCase && hasNumber
              ? null :
          passwordWeakError;

     }

     static String? isValidEmail(String? email)
     {
          // TODO: implement email recognition
          print("EMAIL IS $email");
          if (email == null || email.isEmpty)
               return emptyErrorMessage;
          return null;
     }

     static String? isValidCode(String? code)
     {
          //TODO: validate code format
          return null;
     }
}