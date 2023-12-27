import 'package:flutter/cupertino.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/widgets/feed-component/feed-controller.dart';
import 'package:provider/provider.dart';


enum FeedControllerAccess{
  HOME_PAGE_FEED,
  PROFILE_PAGE_FEED
}

/// This class is responsible for managing the state of the feed widget
/// it is initialized only once and all feeds can access it and fetch their controller
/// if the controller was already initialized it's loaded directly without calling the server to fetch data again
/// of course it also offer the ability to refresh feed data
class FeedProvider extends ChangeNotifier{
  Map<String,FeedController> _controllers = {};

  static FeedProvider getInstance(BuildContext context){
    return Provider.of<FeedProvider>(context , listen: false);
  }

  /// Delete all instance of the feed controller that was made, causing the widgets to refetch the data again
  void resetAllFeeds(){
    _controllers.clear();
  }

  /// Removes certain feed controller by its id if exists
  void removeFeedById(String feedID){
    _controllers.remove(feedID);
  }

  /// Removes certain feed controller using its instance match is exists
  void removeFeedByObject(FeedController feedController){
    _controllers.removeWhere((key, value) => value == feedController);
  }


  /// gets the feed widget controller by id
  /// if the controller already exists it will be returned directly
  /// or either it will be recreated and saved in the controllers cache then returned
  /// [context] : the current buildContext object of the page
  /// [id] : feedID
  /// [providerFunction] : endpoint service code for fetching the data
  /// [clearData] : specifies whether to remove feed data and fetch it again or keep it
  FeedController getFeedControllerById({
    required BuildContext context,
    required String id,
    required ProviderFunction providerFunction,
    required bool clearData
  })
  {
    _controllers.putIfAbsent(id, () => FeedController(
        context,
        id: id,
        providerFunction: providerFunction
    ));
    FeedController target = _controllers[id]!;
    if (clearData) target.resetFeed();
    return _controllers[id]!;
  }


  /// Notifies all class listeners to update their state to follow any changes
  void updateFeeds(){
    Future.delayed(Duration.zero , (){
      notifyListeners();
    });
  }

  /// Special Service for the profile page feed
  /// it's called whenever current user information changes like in case of (Likes, Adding Post, Retweeting, etc...)
  /// if isCurrProfile where true, it will not update the feed
  /// [context] : the current buildContext object of the page
  /// [id] : user profile feed id (can be any feed id)
  /// [isCurrProfile] {optional} : is the current page the profile of the logged in user or not
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