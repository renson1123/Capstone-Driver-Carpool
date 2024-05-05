import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class CommonMethods
{
  checkConnectivity(BuildContext context) async
  {
    var connectionResultList = await Connectivity().checkConnectivity();
    var connectionResult = connectionResultList.first;

    if(connectionResult != ConnectivityResult.mobile && connectionResult != ConnectivityResult.wifi)
      {
        if(!context.mounted) return;
        displaySnackBar("No internet, Check your connection and Try again.", context);
      }
  }

  displaySnackBar(String messageText, BuildContext context)
  {
    var snackBar = SnackBar(content: Text(messageText));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}