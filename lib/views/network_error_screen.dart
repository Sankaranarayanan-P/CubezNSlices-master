import 'package:cubes_n_slice/constants/assets.dart';
import 'package:cubes_n_slice/domain/network_error_controller.dart';
import 'package:cubes_n_slice/views/common_widgets/CustomButton.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NetworkErrorScreen extends StatelessWidget {
  final bool NoConnection;
  const NetworkErrorScreen({Key? key,this.NoConnection = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Image.asset(NoConnection ?Assets.noInternet:Assets.warningImage,width: 300,),
            const SizedBox(height: 16),
             Text(
              NoConnection ?'Oops,No Internet Connection':'Something went wrong',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child:  Text(
                 NoConnection ?'Make Sure wifi or cellular data is turned on and then try again':'Something went wrong with the server. Please try again later.',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
                widthFactor: 0.5,
                text: "TRY AGAIN",
                onPressed: () {
                  Get.find<NetworkErrorController>().setNetworkError(false);
                })
          ],
        ),
      ),
    );
  }
}
