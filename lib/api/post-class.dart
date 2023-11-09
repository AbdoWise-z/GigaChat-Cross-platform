

class TweetData
{
   final String id;
   final String description;
   final String media;
   final int views;
   final DateTime date;
   final String? type;



   TweetData({
      required this.id,
     required this.description,
     required this.media,
     required this.views,
     required this.date,
     required this.type
   });
}