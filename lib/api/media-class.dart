

/// represents the media types supported by the API
enum MediaType{
  IMAGE,
  VIDEO,
  NONE
}

/// represents a media file stored in the API server
/// [link] the API link for the file
/// [type] the [MediaType] of this file
class MediaObject {
  final String link;
  final MediaType type;

  MediaObject({required this.link, required this.type});
}
