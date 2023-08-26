import 'dart:async';

import 'package:dart_amqp/dart_amqp.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';


import 'TestButton.dart';

void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {

  Future<Position> _getLocation() async {
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xffBF926B),
          body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 80,
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "YakDulGi",
                            style: TextStyle(
                              color: Color(0xffF2E5D5),
                              fontSize: 48,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "GPS Demo Test",
                            style: TextStyle(
                              color: Color(0xf0F2E5D5),
                              fontSize: 20,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 120,
                  ),
                  Text(
                    "Longitude",
                    style: TextStyle(
                      fontSize: 34,
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  FutureBuilder<Position>(
                      future: _getLocation(),
                      builder: (context, snapshot){
                        return Text(
                          "${snapshot.data?.longitude}",
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        );
                      }
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Text(
                    "Latitude",
                    style: TextStyle(
                      fontSize: 34,
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  FutureBuilder<Position>(
                      future: _getLocation(),
                      builder: (context, snapshot){
                        return Text(
                          "${snapshot.data?.latitude}",
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        );
                      }
                  ),
                  MyMqtt(),
                ],
              )),
        ));
  }


}

class MyMqtt extends StatefulWidget {

  @override
  _MyMqttState createState() => _MyMqttState();
}

class _MyMqttState extends State<MyMqtt> {
  final String exchangeName = 'hello.exchange';
  final String queueName = 'hello.queue';
  final String routingKey = 'hello.key';

  late Queue bindQueue;
  late Timer timer;
  
  final String SERVER_URL = '10.0.2.2'; // MQTT 브로커 주소
  final int PORT = 5672; // MQTT 브로커 포트

  Future<Position> _getLocation() async {
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  @override
  void initState(){
    super.initState();
    _setupMqtt();
  }

  Future<void> _setupMqtt() async{

    ConnectionSettings settings = ConnectionSettings(
      host: SERVER_URL,
      port: PORT,
      authProvider: const PlainAuthenticator('guest','guest'),
    );

    Client client = Client(settings: settings);
    Channel channel = await client.channel();
    
    Exchange exchange = await channel.exchange(exchangeName, ExchangeType.DIRECT,durable: true);
    Queue queue = await channel.queue(queueName);
    bindQueue = await queue.bind(exchange, routingKey);
    
    timer = Timer.periodic(
        const Duration(seconds: 3),
        publishMessage,
    );
    // Queue queue = await channel.queue(queueName);
    // await queue.bind(exchange,routingKey);
    // print("Ready to Publish\n");
    // exchange.publish("Hello From Flutter",routingKey);
  }
  
  Future<void> publishMessage(Timer timer) async {
    setState(() async {
      var location = await _getLocation();
      print("Ready to Publish\n");
      bindQueue.publish('{"message":${location.longitude},"timeStamp":${location.latitude}}');
    });

  }

  // void _onConnected() {
  //   setState(() {
  //     connectionState = MqttConnectionState.connected;
  //   });
  // }
  //
  // void _onDisconnected() {
  //   setState(() {
  //     connectionState = MqttConnectionState.disconnected;
  //   });
  // }
  @override
  Widget build(BuildContext context) {
    return const Row(
      children:[
        SizedBox(
          height: 100,
        ),
        Center(
          child: Text('Message Published to RabbitMQ!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
          ),
        ),
      ]
    );
  }




}