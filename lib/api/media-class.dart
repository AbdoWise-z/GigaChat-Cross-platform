
enum MediaType{
  IMAGE,
  VIDEO,
  NONE
}

class MediaObject {
  final String link;
  final MediaType type;

  MediaObject({required this.link, required this.type});
}
