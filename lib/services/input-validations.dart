

import 'package:string_validator/string_validator.dart';

const MIN_USERNAME_LENGTH = 5;
const MAX_USERNAME_LENGTH = 15;

const MIN_PASSWORD_LENGTH = 6;
const MAX_PASSWORD_LENGTH = 64;

class InputValidations
{
     static String emptyErrorMessage = "this field cannot be empty";

     static String usernameLongInputError = "Your username must be 15 characters or less and contain only letters, numbers, and underscores and no spaces";
     static String usernameShortInputError = "Username should be more than 4 characters.";

     static String passwordLongInputError = "password is too long";
     static String passwordShortInputError = "password is too short";
     static String passwordWeakError = "weak password!";
     static String invalidInput = "invalid input";

     static String? isUniqueUsername(String? username)
     {
          // TODO: call the api to check if it's a unique username
          // should return a meaningful string of already used username
          // if it's new return null
          return null;
     }

     /// Takes a username string as an input and checks whether it is a proper username
     /// or not according to the valid username rules
     static String? isValidUsername(String? username)
     {
          final RegExp validCharacters = RegExp("[a-zA-Z0-9_]");

          if (username == null || username.isEmpty) {
            return null;
          }

          if (username.length < MIN_USERNAME_LENGTH) {
            return usernameShortInputError;
          }

          if (username.length > MAX_USERNAME_LENGTH) {
            return usernameLongInputError;
          }

          if (validCharacters.allMatches(username).length != username.length){
               return invalidInput;
          }

          return isUniqueUsername(username);
     }

     /// Takes a password string as an input and checks whether it is a proper password
     /// or not according to the given rules
     /// 1- isn't empty or null
     /// 2- has at lease [lowercase latin - uppercase latin - number - special char]
     /// 3- it's length is bounded by some min and max
     static String? isValidPassword(String? password)
     {
          RegExp passwordValidCharacters = RegExp("[a-zA-Z0-9!@£\$#_.]");

          if (password == null || password.isEmpty) {
            return emptyErrorMessage;
          }
          if (password.length < MIN_PASSWORD_LENGTH){
               return passwordShortInputError;
          }
          if (password.length > MAX_PASSWORD_LENGTH){
               return passwordLongInputError;
          }

          bool satisfyRegex = passwordValidCharacters.allMatches(password).length == password.length;
          if (!satisfyRegex)
          {
               return invalidInput;
          }

          RegExp specialChars = RegExp("[@!\$#_\-]");
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

     /// Checks if the given string is in email format
     static String? isValidEmail(String? email)
     {
          RegExp emailValidCharacters = RegExp("[a-zA-Z0-9@._\-]");
          if (email == null || email.isEmpty) {
            return emptyErrorMessage;
          }
          
          if (emailValidCharacters.allMatches(email).length != email.length){
               return invalidInput;
          }

          RegExp emailRegex = RegExp("@[a-zA-Z0-9]+[.][a-z]+\$");
          
          if (!emailRegex.hasMatch(email))
          {
               return invalidInput;
          }
          
          return null;
     }

     static String? isValidCode(String? code)
     {
          //TODO: validate code format
          return null;
     }
}