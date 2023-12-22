import 'package:flutter/cupertino.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/widgets/feed-component/feed-controller.dart';
import 'package:provider/provider.dart';

import '../pages/profile/user-profile.dart';


enum FeedControllerAccess{
  HOME_PAGE_FEED,
  PROFILE_PAGE_FEED
}

class FeedProvider extends ChangeNotifier{
  Map<String,FeedController> _controllers = {};

  static FeedProvider getInstance(BuildContext context){
    return Provider.of<FeedProvider>(context , listen: false);
  }

  void resetAllFeeds(){
    print("hereeeeeee");
    _controllers.clear();
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
    _controllers.putIfAbsent(id, () => FeedController(context, providerFunction: providerFunction));
    FeedController target = _controllers[id]!;
    if (clearData) target.resetFeed();
    return _controllers[id]!;
  }

  void updateFeeds(){
    notifyListeners();
  }

  void updateProfileFeed(BuildContext context, String id, {bool? isCurrProfile}){
    if(isCurrProfile != null && isCurrProfile){
      return;
    }
    FeedController temp =  getFeedControllerById(
      context: context,
      id: id + Auth.getInstance(context).getCurrentUser()!.id,
      providerFunction: ProviderFunction.PROFILE_PAGE_TWEETS,
      clearData: false,
    );
    temp.resetFeed();
    temp.updateFeeds();
  }

}