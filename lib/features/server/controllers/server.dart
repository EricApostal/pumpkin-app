import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pumpkin_app/rust/src/api/simple.dart';
import 'package:pumpkin_app/rust/src/third_party/rcon_client.dart';
import 'package:rcon/rcon.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:toml/toml.dart';

part 'server.g.dart';

@Riverpod(keepAlive: true)
class ServerController extends _$ServerController {
  @override
  void build() {}

  Future<void> start() async {
    final directory = Directory(
      "${(await getApplicationDocumentsDirectory()).path}/server",
    );
    await directory.create();
    final configPath = '${directory.path}/config/features.toml';
    try {
      TomlDocument document = await TomlDocument.load(configPath);

      final config = document.toMap();

      print("enabling rcon!");
      // we need to force enable rcon for the console
      config["networking"]["rcon"]["enabled"] = true;
      config["networking"]["rcon"]["password"] = "pumpkin";
      TomlDocument newDocument = TomlDocument.fromMap(config);
      final file = File(configPath);
      await file.writeAsString(newDocument.toString());

      startServer(appDir: directory.path);
      await Future.delayed(Duration(milliseconds: 7000));
      print("making client and logging in...");
      final client = await RconClient.newInstance(
        config: RCONConfig(url: "127.0.0.1:25575"),
      );
      print("logging in");
      final authResult = await client.auth(
        auth: await AuthRequest.newInstance(password: "pumpkin"),
      );
      print("success?");
      print(authResult);
      // // final login = rconClient.login("");
      // // print(login);
      // print("logged in");

      // rconClient.listen((e) {
      //   print("eventy");
      // });

      // print(
      //   rconClient.send(Message.create(rconClient, PacketType.command, "help")),
      // );
    } catch (e, st) {
      print(e);
      print(st);
    }
  }
}
