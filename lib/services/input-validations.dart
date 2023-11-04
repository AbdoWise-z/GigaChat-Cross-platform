

import 'package:string_validator/string_validator.dart';

const MIN_USERNAME_LENGTH = 6;
const MAX_USERNAME_LENGTH = 20;

class InputValidations
{

     static String? verifyUsername(String? username)
     {
          if (username == null || username.isEmpty) {
            return "empty username!";
          }

          if (username.length < MIN_USERNAME_LENGTH) {
            return "username must be at least $MIN_USERNAME_LENGTH characters.";
          }

          if (username.length > MAX_USERNAME_LENGTH) {
            return "username must be at most $MAX_USERNAME_LENGTH characters.";
          }

          return null;
     }

     static String? verifyPassword(String? password)
     {
          if (password == null || password.isEmpty) {
            return "password cannot be empty.";
          }

          RegExp regex = RegExp("[a-zA-Z0-9@#_\$]");
          RegExp specialChars = RegExp("[@!\$#_-]");
          bool acceptedLength = password.length >= 10 && password.length <= 64;
          bool satisfyRegex = regex.hasMatch(password);
          bool hasLowerCase = false;
          bool hasUpperCase = false;
          bool hasNumber = false;
          bool hasSpecial = false;

          for (int i = 0; i < password.length; i++)
          {
               hasLowerCase |= isLowercase(password[i]);
               hasUpperCase |= isUppercase(password[i]);
               hasNumber |= isInt(password[i]);
               hasSpecial |= specialChars.hasMatch(password[i]);
          }

          if(acceptedLength && satisfyRegex && hasSpecial && hasLowerCase && hasUpperCase && hasNumber)
          {
               return null;
          }
          else
          {
               return "invalid password";
          }
     }

     static String? isValidEmail(String? email)
     {
          // TODO: implement email recognition
          if (email == null || email.isEmpty) return "email is empty.";
          return null;
     }

     static String? isValidCode(String? code)
     {
          //TODO: validate code format
          return null;
     }
}