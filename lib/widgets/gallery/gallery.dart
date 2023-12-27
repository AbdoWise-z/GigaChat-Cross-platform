import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/loading-page.dart';
import 'package:gigachat/widgets/gallery/sub-pages/request-permissions-page.dart';
import 'package:gigachat/widgets/gallery/widgets/ImageGridItem.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

/// providers a utility to pick media from phone Gallery for from
/// desktop files
class Gallery{
  ///
  /// selects files from the phone gallery or from windows local storage
  /// [selectMax] defines the maximum files to select
  /// [canSkip] defines if this dialog is skip able
  /// [selected] a list of already selected files
  ///
  static Future<List<TypedEntity>> selectFromGallery(
      BuildContext context ,
      { int selectMax = MEDIA_UPLOAD_LIMIT ,
        cameraEnabled = true ,
        canSkip = false ,
        List<File> selected = const []
      }) async {

    List<TypedEntity> paths = [];
    if (Platform.isAndroid) {
      paths =
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              _GalleryWidget(
                canSkip: canSkip,
                selectMax: selectMax,
                cameraEnabled: cameraEnabled,
                selected: selected,
              ),
        ),
      );
    } else {
      for (var i in selected){
        paths.add(
            TypedEntity(
              path: i,
              type: i.path.endsWith(".mp4") || i.path.endsWith(".m4a") ? AssetType.video : AssetType.image,
            )
        );
      }
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: "Select file to add",
        type: FileType.media,
        allowedExtensions: [".mp4", ".jpg" , ".jpeg" , ".png" , ".gif" , ".m4a"],
        lockParentWindow: true,
        allowMultiple: true,
      );
      if (result != null){
        for (var i in result.paths){
          paths.add(
              TypedEntity(
                  path: File(i!),
                  type: i.endsWith(".mp4") || i.endsWith(".m4a") ? AssetType.video : AssetType.image,
              )
          );
          if (paths.length == selectMax){
            break;
          }
        }
      }
    }

    return paths;
  }
}


/// the media pick up gallery widget
/// it loads a gallery using the internal phone storage
class _GalleryWidget extends StatefulWidget {
  final bool canSkip;
  final int selectMax;
  final bool cameraEnabled;
  final List<File> selected;

  const _GalleryWidget({
    required this.canSkip,
    required this.selectMax,
    required this.cameraEnabled,
    required this.selected
  }) : assert(selectMax >= selected.length);

  @override
  State<_GalleryWidget> createState() => _GalleryWidgetState();
}

class _GalleryWidgetState extends State<_GalleryWidget> {
  bool _perms = false;
  bool _loading = false;
  bool _loadingMore = false;

  List<AssetPathEntity> _paths = [];
  int _currentPath = 0;
  AssetPathEntity? _path;
  List<MediaEntity>? _entities;
  int _page = 0;
  final int _sizePerPage = 30;
  int _totalCount = 0;

  List<TypedEntity> _selectedPaths = [];

  void _exit(){
    Navigator.pop(context , _selectedPaths);
  }

  void _loadGallery() async{
    setState(() {
      _loading = true;
    });


    //check for permissions
    if (! await Permission.manageExternalStorage.isGranted){
      var k = await Permission.manageExternalStorage.request();
      print("manageExternalStorage: $k");
      if (k != PermissionStatus.granted){
        setState(() {
          _loading = false;
        });
        return;
      }
    }

    if (! await Permission.accessMediaLocation.isGranted){
      var k = await Permission.accessMediaLocation.request();
      print("accessMediaLocation: $k");
      if (k != PermissionStatus.granted){
        setState(() {
          _loading = false;
        });
        return;
      }
    }

    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (!ps.hasAccess) {
      await PhotoManager.openSetting();
      if (!ps.hasAccess) {
        setState(() {
          _loading = false;
        });
        return;
      }
    }

    _paths = await PhotoManager.getAssetPathList();
    //print("paths: $_paths");
    if (_paths.isEmpty){
      setState(() {
        _loading = false;
        _perms = true;
      });
      return;
    }

    _perms = true;
    _loadPath(0);
  }

  void _loadPath(int p) async {
    setState(() {
      _loading = true;
    });

    //print("Loading Path : $p");

    _currentPath = p;
    _path = _paths[p];
    _page = -1;
    _entities = [];
    _totalCount = await _path!.assetCountAsync;

    //print("Loading Path : {#: $p , path_name: ${_path!.name} , total: $_totalCount}");

    _loadMore();

    setState(() {
      _loading = false;
    });
  }

  void _loadMore() async{
    _loadingMore = true;

    final List<AssetEntity> entities = await _path!.getAssetListPaged(
      page: _page + 1,
      size: _sizePerPage,
    );

    //print("Loaded: $entities");
    //print((await entities[0].file)?.path);
    List<MediaEntity> media = [];
    for (AssetEntity e in entities){
      media.add(
        MediaEntity(
          entity: e,
          path: (await e.file)!,
        )
      );
    }

    setState(() {
      _entities!.addAll(media);
      _page++;
      _loadingMore = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadGallery();
    _selectedPaths.addAll(widget.selected.map((e) => TypedEntity(path: e, type: AssetType.other)));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: _content(context),
      onWillPop: () async {
        if (widget.canSkip){
          _exit();
          return true;
        }
        return false;
      },
    );
  }

  Widget _content(BuildContext context){
    if (_loading){
      return const LoadingPage();
    }

    if (!_perms){
      return Scaffold(
        appBar: AppBar(
          leading: widget.canSkip ? IconButton(onPressed: _exit, icon: const Icon(Icons.close)) : const SizedBox(),
        ),
        body: RequestPermissions(onClick: () => _loadGallery()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: widget.canSkip ? IconButton(onPressed: _exit, icon: const Icon(Icons.close)) : const SizedBox(),
        title: _paths.isNotEmpty ? DropdownButton<int>(
          value: _currentPath,
          items: _paths.map(
                  (e) => DropdownMenuItem(
                value: _paths.indexOf(e),
                child: Text(e.name),
              )
          ).toList(),
          underline: const SizedBox.shrink(),
          selectedItemBuilder: (context) => _paths.map(
                (e) => DropdownMenuItem(
              value: _paths.indexOf(e),
              child: Text(e.name),
            ),
          ).toList(),
          onChanged: (t) => _loadPath(t!), ) : const SizedBox(),
        actions: [
          Stack(
            children: [
              Visibility(
                visible: _selectedPaths.isNotEmpty,
                child: Positioned(
                  right: 5,
                  bottom: 15,
                  child: Container(
                    width: 15,
                    height: 15,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      color: Colors.blueAccent,
                    ),
                    child: Center(
                      child: Text(
                        "${_selectedPaths.length}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: _selectedPaths.isEmpty ? null : () {
                  _exit();
                },
                icon: const Icon(Icons.check),
              ),
            ],
          ),
        ],
      ),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context){
    if(_entities == null || _entities!.isEmpty){
      return const Center(
        child: Text("No Media found.",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
      );
    }

    return GridView.custom(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      childrenDelegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
          if (index == _entities!.length - _sizePerPage &&
              !_loadingMore && _entities!.length < _totalCount) {
            _loadMore();
          }
          final MediaEntity entity = _entities![index];
          return GalleryGridItem(
            key: ValueKey<int>(index),
            entity: entity,
            onTap: () {
              setState(() {
                int i = _selectedPaths.indexWhere((e) => e.path.path == entity.path.path);
                if (i < 0) {
                  if (_selectedPaths.length < widget.selectMax) {
                    _selectedPaths.add(TypedEntity(path: entity.path, type: entity.entity.type));
                    if (widget.selectMax == 1){
                      //TODO: should I implement another behavior ?
                    }
                  }
                }else{
                  _selectedPaths.removeAt(i);
                }
              });
            },
            selected: _selectedPaths.indexWhere((e) => e.path.path == entity.path.path) >= 0,
            enabled: _selectedPaths.length < widget.selectMax || _selectedPaths.indexWhere((e) => e.path.path == entity.path.path) >= 0,
          );
        },
        childCount: _entities!.length,
        findChildIndexCallback: (Key key) {
          // Re-use elements.
          if (key is ValueKey<int>) {
            return key.value;
          }
          return null;
        },
      ),
    );
  }
}

class MediaEntity {
  final AssetEntity entity;
  final File path;

  MediaEntity({required this.entity, required this.path});
}

class TypedEntity {
  final File path;
  final AssetType type;

  TypedEntity({required this.path, required this.type});
}
