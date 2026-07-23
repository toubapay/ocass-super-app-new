import 'dart:convert';
import 'dart:developer';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';

class PusherHelper{

  static PusherChannelsClient?  pusherClient;

  static Future<void> initializePusher() async{
    PusherChannelsOptions testOptions = PusherChannelsOptions.fromHost(
      host: Get.find<SplashController>().configModel?.websocketUrl ?? '192.168.1.62',
      scheme: 'ws',
      key: '6ammart',
      port: 6001,
    );

    pusherClient = PusherChannelsClient.websocket(
      options: testOptions,
      connectionErrorHandler: (exception, trace, refresh) async {
        log('=================$exception');
        refresh();
      },
    );

    await pusherClient?.connect();


    String? pusherChannelId =  pusherClient?.channelsManager.channelsConnectionDelegate.socketId;
      if(pusherChannelId != null){
        log('=================Pusher Connected');
      }


     pusherClient?.lifecycleStream.listen((event) {
       log('=================Pusher DisConnected');
     });


  }

  // late PrivateChannel pusherDriverLocation;
  late PublicChannel? publicChannel;

  void pusherDriverStatus({required String deliverymanId, required Function(RecordLocationBodyModel) onLocationReceived}){

    String channel = 'dm_location_$deliverymanId';

    log('========channel is: $channel');

    // _publicChannel = pusherClient!.publicChannel('pusher:subscribe');
    publicChannel = pusherClient!.publicChannel(channel);

    // _publicChannel.subscribe();
    publicChannel?.subscribeIfNotUnsubscribed();
    // FIX: PublicChannel uses 'pusher:subscription_succeeded' event via bind()

    publicChannel?.bind('pusher:subscription_succeeded').listen((_) {
      log('=======Public Subscribed');
    });

    publicChannel?.bind('pusher:subscription_error').listen((error) {
      log('=======Public Subscription Failed: ${error.data}');
    });

    publicChannel?.bind(channel).listen((event) {
      log('===========pusherDriverStatus bind is: ${event.data}');
      onLocationReceived(RecordLocationBodyModel(
        latitude: jsonDecode(event.data)['latitude'],
        longitude: jsonDecode(event.data)['longitude'],
        location: jsonDecode(event.data)['location'],
      ));
    });


  }


  void pusherDisconnectPusher(){
    publicChannel?.unsubscribe();
    pusherClient?.disconnect();
  }


}

class RecordLocationBodyModel {
  String? latitude;
  String? longitude;
  String? location;

  RecordLocationBodyModel({this.latitude, this.longitude, this.location});
}