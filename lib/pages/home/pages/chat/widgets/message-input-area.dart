import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gigachat/api/chat-class.dart';
import 'package:gigachat/api/media-class.dart';
import 'package:gigachat/widgets/gallery/gallery.dart';
import 'package:gigachat/widgets/local-video-player.dart';
import 'package:photo_manager/photo_manager.dart';



class MessageInputArea extends StatefulWidget {
  final void Function(ChatMessageObject) onMessage;
  final void Function() onSizeChange;
  final void Function() onOpen;
  const MessageInputArea({super.key, required this.onMessage, required this.onSizeChange, required this.onOpen});

  @override
  State<MessageInputArea> createState() => _MessageInputAreaState();
}

class _MessageInputAreaState extends State<MessageInputArea> with SingleTickerProviderStateMixin{
  TypedEntity? _media;
  late final AnimationController _controller = AnimationController(vsync: this , duration: const Duration(milliseconds: 400));
  late final FocusNode _node = FocusNode();

  late Animation _height;
  late Animation _appear;
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _height = Tween<double>(begin: 0.0 , end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: const Interval(0, 0.5))
    );
    _appear = Tween<double>(begin: 0.0 , end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1))
    );

    _controller.addListener(() {
      widget.onSizeChange();

      setState(() {
      });
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed){
        _node.requestFocus();
      }
    });

    _node.addListener(() {
      if (!_node.hasFocus){
        _controller.reverse();
      }else{
        widget.onOpen();
      }
    });

    Future.delayed(Duration.zero , () {
      var ctx = _textFieldKey.currentContext;
      if (ctx == null){
        _dx = 0;
        _mh = 0;
      }else{
        _dx = ctx.size!.width;
        _mh = ctx.size!.height;
      }

      widget.onSizeChange();
    });
  }

  @override
  void dispose() {
    super.dispose();

  }

  final GlobalKey _textFieldKey = GlobalKey();
  double _dx = 0;
  double _mh = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _media != null ? Container(
          width: 80 * (_media!.type == AssetType.video ? 3 : 1) + 30.0 * _appear.value, //these numbers are totally based on my taste
          height: 80 * (_media!.type == AssetType.video ? 3 : 1) + 30.0 * _appear.value,
          alignment: Alignment.topRight,
          margin: const EdgeInsets.only(bottom: 5,right: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18)
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Container(
                color: Theme.of(context).textTheme.bodyLarge!.color,
              ),
              Align(
                alignment: Alignment.center,
                child: _media!.type == AssetType.image ? Image.file(
                  _media!.path,
                  fit: BoxFit.fill,
                ) :SizedBox(
                  width: 80 * (_media!.type == AssetType.video ? 3 : 1) + 30.0 * _appear.value, //these numbers are totally based on my taste
                  height: 80 * (_media!.type == AssetType.video ? 3 : 1) + 30.0 * _appear.value,
                  child: LocalVideoPlayer(
                    file: _media!.path.path,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    iconSize: 18,
                    icon: const Icon(Icons.remove , weight: 2,),
                    onPressed: () {
                      setState(() {
                        _media = null;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ) : const SizedBox.shrink(),

        GestureDetector(
          onTap: () {
            _controller.forward();
          },
          child: Material(
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.circular(25),
            color: Colors.blueGrey.shade100,

            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Opacity(
                  opacity: _appear.value,
                  child: Transform.translate(
                    offset: Offset(-_dx/2 * (1.0 - _appear.value), 0),
                    child: SizedBox(
                      height: _height.value == 1 ? null : _height.value * _mh,
                      child: Padding(
                        padding: const EdgeInsets.symmetric( horizontal: 12.0),
                        child: TextField(
                          controller: _textEditingController,
                          maxLines: null,
                          key: _textFieldKey,
                          focusNode: _node,
                          onChanged: (s) {
                            setState(() {});
                          },
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            enabledBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            hintText: "Start a message",
                            hintStyle: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    IconButton(
                      splashRadius: 25,
                      onPressed: () async {
                        //if you somehow was able to click before the app even builds
                        //then you deserve the app crash in your face :)
                        var m = _media;

                        setState(() {
                          _media = null;
                        });

                        var selected = await Gallery.selectFromGallery(
                          context ,
                          selected: m == null ? [] : [m!.path],
                          canSkip: true,
                          selectMax: 1,
                        );

                        setState(() {
                          if (selected.isNotEmpty){
                            _media = selected[0];
                            print(_media!.path.path);
                          }
                        });

                      },
                      icon: const Icon(Icons.photo_outlined , color: Colors.black,) ,
                    ),

                    Expanded(
                      child: Opacity(
                        opacity: 1.0 - _height.value,
                        child: Text(
                          _textEditingController.text.isEmpty ?
                          "Start a Message" : _textEditingController.text,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _textEditingController.text.isNotEmpty ? 1 : 0,
                      child: SizedBox(
                        width: 35,
                        height: 35,
                        child: Material(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(35/2.0),
                          child: IconButton(
                            splashRadius: 25,
                            onPressed: () async {
                              widget.onMessage(
                                ChatMessageObject(
                                  id: "none",
                                  text: _textEditingController.text,
                                  media: _media == null ? null : MediaObject(link: _media!.path.path, type: _media!.type == AssetType.image ? MediaType.IMAGE : MediaType.VIDEO),
                                  self: true,
                                  time: DateTime.now(),
                                  state: ChatMessageObject.STATE_SENDING,
                                  replyTo: null,
                                ),
                              );
                              setState(() {
                                _media = null;
                                _textEditingController.text = "";
                              });
                            },
                            iconSize: 20,
                            color: Colors.white,
                            icon: const Icon(Icons.send) ,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8,),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

