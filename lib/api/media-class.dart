
enum MediaType{
  IMAGE,
  VIDEO,
}

class MediaObject {
  static MediaType TypeOf(String path){
    return MediaType.IMAGE;
  }
  final String link;
  final MediaType type;

  MediaObject({required this.link, required this.type});
}
