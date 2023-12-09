
enum MediaType{
  IMAGE,
  VIDEO,
}

class MediaObject {
  final String link;
  final MediaType type;

  MediaObject({required this.link, required this.type});
}
