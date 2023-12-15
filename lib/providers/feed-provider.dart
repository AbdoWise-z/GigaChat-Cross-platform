import 'package:flutter/cupertino.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/widgets/feed-component/feed-controller.dart';
import 'package:provider/provider.dart';


enum FeedControllerAccess{
  HOME_PAGE_FEED,
  PROFILE_PAGE_FEED
}

class FeedProvider extends ChangeNotifier{
  Map<String,FeedController> _controllers = {};

  static FeedProvider getInstance(BuildContext context){
    return Provider.of<FeedProvider>(context , listen: false);
  }

  void removeFeedById(String feedID){
    _controllers.remove(feedID);
  }

  void removeFeedByObject(FeedController feedController){
    _controllers.removeWhere((key, value) => value == feedController);
  }



  FeedController getFeedControllerById({
    required BuildContext context,
    required String id,
    required ProviderFunction providerFunction,
    required bool clearData
  })
  {
    _controllers.putIfAbsent(id, () => FeedController(context, providerFunction: providerFunction!));
    FeedController target = _controllers[id]!;
    if (clearData) target.resetFeed();
    return _controllers[id]!;
  }

  void updateFeeds(){
    notifyListeners();
  }


}