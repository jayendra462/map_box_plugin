import 'package:flutter_test/flutter_test.dart';
import 'package:map_box_plugin/map_box_plugin.dart';
import 'package:map_box_plugin/map_box_plugin_platform_interface.dart';
import 'package:map_box_plugin/map_box_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMapBoxPluginPlatform
    with MockPlatformInterfaceMixin
    implements MapBoxPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final MapBoxPluginPlatform initialPlatform = MapBoxPluginPlatform.instance;

  test('$MethodChannelMapBoxPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMapBoxPlugin>());
  });

  test('getPlatformVersion', () async {
    MapBoxPlugin mapBoxPlugin = MapBoxPlugin();
    MockMapBoxPluginPlatform fakePlatform = MockMapBoxPluginPlatform();
    MapBoxPluginPlatform.instance = fakePlatform;

    expect(await mapBoxPlugin.getPlatformVersion(), '42');
  });
}
