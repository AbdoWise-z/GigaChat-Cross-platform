

class InputFormatting{

  static String calculateDateSincePost(DateTime postDate)
  {
    DateTime now = DateTime.now();
    Duration difference = now.difference(postDate);
    String formattedDifference = "${difference.inDays}d";

    if (difference.inDays > 360) {
      formattedDifference = "${difference.inDays ~/ 360}y";
    }
    else if (difference.inDays != 0) {
      formattedDifference = "${difference.inDays}d";
    }
    else if (difference.inHours != 0) {
      formattedDifference = "${difference.inHours}h";
    }
    else if (difference.inMinutes != 0) {
      formattedDifference = "${difference.inMinutes}m";
    }
    else {
      formattedDifference = "just now";
    }
    return formattedDifference;
  }

}