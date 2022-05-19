import 'dart:typed_data';
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'components/spinner.dart';

class GyroStuff extends StatefulWidget {
  // Constant Values
  final int GYRO_SENSITIVITY = 3;
  final double SYSTEM_SLEEP = 2.2;
  final String DEVICE_ADDRESS = '98:DA:40:00:F7:5D';

  const GyroStuff({Key? key}) : super(key: key);

  @override
  State<GyroStuff> createState() => _GyroStuffState();
}

class _GyroStuffState extends State<GyroStuff> {
  double x = 0, y = 0;
  String direction = "";
  bool waitingBT = false, connected = false;

  @override
  void initState() {
    gyroscopeEvents.listen((GyroscopeEvent event) => _gyroHandler(event));
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Guglu"),
          backgroundColor: Colors.redAccent,
        ),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(30),
                child: Column(children: [
                  Text(
                    direction,
                    style: TextStyle(fontSize: 30),
                  )
                ])),
            if (!connected)
              MaterialButton(
                onPressed: () => _testConnection(),
                child: const Text('Connect'),
                color: Colors.blueAccent,
                textColor: Colors.white,
              ),
            MaterialButton(
              onPressed: () => Fluttertoast.showToast(
                  msg: "This opens the unity apk :D",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  fontSize: 16.0),
              child: const Text('Launch App'),
              color: Colors.grey,
              textColor: Colors.white,
            ),
            connected
                ? const Text('All cool :)')
                : waitingBT
                    ? const LoadingSpinner()
                    : const Text('No Connection :(')
          ],
        ));
  }

  /// Tests the connection with the BT MAC Address defined in DEVICE_ADDRESS
  Future<void> _testConnection() async {
    waitingBT = true;
    setState(() {});
    await _sendData(_toUint8List('h')).then((ok) {
      _handleBtResponse(ok);
      waitingBT = false;
      setState(() {});
    });
    return;
  }

  /// Handles Gyroscope event, sending a BT signal only when connected
  /// and using the sensitivity defined in GYRO_SENSITIVITY
  void _gyroHandler(GyroscopeEvent event) async {
    if ((!connected) ||
        (waitingBT) ||
        ((event.x > -widget.GYRO_SENSITIVITY &&
                event.y > -widget.GYRO_SENSITIVITY) &&
            (event.x < widget.GYRO_SENSITIVITY &&
                event.y < widget.GYRO_SENSITIVITY))) {
      return;
    }

    // debugPrint(event.toString());

    direction = '';

    x = event.x;
    y = event.y;

    if (x > 1) {
      direction += 'u'; //Up
    } else if (x < -1) {
      direction += 'd'; //Down
    }

    if (y > 1) {
      direction += 'r'; //Right
    } else if (y < -1) {
      direction += 'l'; //Left
    }

    waitingBT = true;

    if (direction.isNotEmpty) {
      debugPrint('Sending BT event...');
      await _sendData(_toUint8List(direction))
          .then((ok) => _handleBtResponse(ok));
    }

    await Future.delayed(
            Duration(milliseconds: (widget.SYSTEM_SLEEP * 1000).round()))
        .then((_) {
      debugPrint('Wait is over');
      waitingBT = false;
      setState(() {});
    });

    return;
  }

  /// Send byte message to the BT MAC Address defined in DEVICE_ADDRESS
  Future<bool> _sendData(Uint8List data) async {
    try {
      BluetoothConnection connection =
          await BluetoothConnection.toAddress(widget.DEVICE_ADDRESS);

      connection.output.add(data);
      await connection.output.allSent
          .then((_) => debugPrint('SendData() consumed'));

      connection.close();

      return true;
    } catch (_) {
      // Ignore error, but notify state
      return false;
    }
  }

  void _handleBtResponse(bool ok) {
    if (ok) {
      debugPrint('BT event consumed');
      connected = true;
    } else {
      debugPrint('No BT Response');
      connected = false;
    }
    setState(() {});
  }

  /// Converts a string to a byte message that can be decoded by Arduino
  Uint8List _toUint8List(String str) {
    final List<int> codeUnits = str.codeUnits;
    final Uint8List unit8List = Uint8List.fromList(codeUnits);

    return unit8List;
  }
}
