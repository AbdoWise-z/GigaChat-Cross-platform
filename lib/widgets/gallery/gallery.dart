import 'package:flutter/material.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/loading-page.dart';
import 'package:gigachat/widgets/gallery/sub-pages/request-permissions-page.dart';
import 'package:gigachat/widgets/gallery/widgets/ImageGridItem.dart';
import 'package:photo_manager/photo_manager.dart';

class Gallery{

  static Future<List<String>> selectFromGallery(
      BuildContext context ,
      { int selectMax = MEDIA_UPLOAD_LIMIT ,
        cameraEnabled = true ,
        canSkip = false ,
        List<String> selected = const []
      }) async {

    List<String> paths =
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _GalleryWidget(
          canSkip: canSkip,
          selectMax: selectMax,
          cameraEnabled: cameraEnabled,
          selected: selected,
        ),
      ),
    );

    return paths;
  }
}

class _GalleryWidget extends StatefulWidget {
  final bool canSkip;
  final int selectMax;
  final bool cameraEnabled;
  final List<String> selected;

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
  List<AssetEntity>? _entities;
  int _page = 0;
  final int _sizePerPage = 30;
  int _totalCount = 0;

  List<String> _selectedPaths = [];

  void _exit(){
    Navigator.pop(context , _selectedPaths);
  }

  void _loadGallery() async{
    setState(() {
      _loading = true;
    });

    //check for permissions
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (!ps.hasAccess) {
      PhotoManager.openSetting();
      setState(() {
        _loading = false;
      });
      return;
    }

    _paths = await PhotoManager.getAssetPathList();
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

    _currentPath = p;
    _path = _paths[p];
    _page = -1;
    _entities = [];
    _totalCount = await _path!.assetCountAsync;

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

    setState(() {
      _entities!.addAll(entities);
      _page++;
      _loadingMore = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadGallery();
    _selectedPaths.addAll(widget.selected);
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
    //TODO: maybe test it someday
    if(_entities == null || _entities!.isEmpty){
      return const Center(
        child: Text("No images found.",
          style: TextStyle(
            fontSize: 36,
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
          final AssetEntity entity = _entities![index];
          return ImageGridItem(
            key: ValueKey<int>(index),
            entity: entity,
            option: const ThumbnailOption(
              size: ThumbnailSize.square(200),
              format: ThumbnailFormat.jpeg,
            ),
            onTap: () {
              setState(() {
                int i = _selectedPaths.indexOf("${entity.relativePath}${entity.title}");
                if (i < 0) {
                  if (_selectedPaths.length < widget.selectMax) {
                    _selectedPaths.add("${entity.relativePath}${entity.title}");
                    if (widget.selectMax == 1){
                      //TODO: should I implement another behavior ?
                    }
                  }
                }else{
                  _selectedPaths.removeAt(i);
                }
              });
            },
            selected: _selectedPaths.contains("${entity.relativePath}${entity.title}"),
            enabled: _selectedPaths.length < widget.selectMax || _selectedPaths.contains("${entity.relativePath}${entity.title}"),
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
