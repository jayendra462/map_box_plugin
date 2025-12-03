import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:map_box_plugin/embedded/controller.dart';
import 'package:map_box_plugin/map_box_plugin.dart';
import 'package:map_box_plugin/models/models.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  MapboxMap? mapboxMap;
  var isLight = true;
  bool isPathDraw = true;
  PointAnnotation? pointAnnotation;
  PointAnnotationManager? pointAnnotationManager;

  Future<void> initialize() async {
    if (!mounted) return;

    MapBoxPlugin.instance.setDefaultOptions(MapBoxOptions(
        initialLatitude: 36.1175275,
        initialLongitude: -115.1839524,
        zoom: 13.0,
        tilt: 0.0,
        bearing: 0.0,
        enableRefresh: false,
        alternatives: true,
        voiceInstructionsEnabled: false,
        bannerInstructionsEnabled: true,
        allowsUTurnAtWayPoints: true,
        mode: MapBoxNavigationMode.driving,
        mapStyleUrlDay: "mapbox://styles/viral-mobmaxime/clv24enbn00bo01qv1cg5bcsm",
        mapStyleUrlNight: "mapbox://styles/viral-mobmaxime/clv24enbn00bo01qv1cg5bcsm",
        longPressDestinationEnabled: true,
        units: VoiceUnits.imperial,
        simulateRoute: true,
        language: "en"));
    _navigationOption = MapBoxPlugin.instance.getDefaultOptions();

    //_navigationOption.initialLatitude = 36.1175275;
    //_navigationOption.initialLongitude = -115.1839524;
    MapBoxPlugin.instance.registerRouteEventListener(_onEmbeddedRouteEvent);

    String? platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await MapBoxPlugin.instance.getPlatformVersion();
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  void dispose() {
    _controller?.clearRoute();
    _controller?.finishNavigation();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _onEmbeddedRouteEvent(e) async {
    switch (e.eventType) {
      case MapBoxEvent.progress_change:
        // var progressEvent = e.data as RouteProgressEvent;
        // if (progressEvent.currentStepInstruction != null) {
        //   _instruction = progressEvent.currentStepInstruction;
        // }
        break;
      case MapBoxEvent.route_building:
      case MapBoxEvent.route_built:
        setState(() {
          _routeBuilt = true;
        });
        break;
      case MapBoxEvent.route_build_failed:
        setState(() {
          _routeBuilt = false;
        });
        break;
      case MapBoxEvent.navigation_running:
        break;
      case MapBoxEvent.on_arrival:
        if (!_isMultipleStop) {
          await Future.delayed(const Duration(seconds: 3));
          await _controller?.finishNavigation();
        } else {}
        break;
      case MapBoxEvent.navigation_finished:
      case MapBoxEvent.navigation_cancelled:
        break;
      default:
        break;
    }
    setState(() {});
  }

  late MapBoxOptions _navigationOption;
  MapBoxNavigationViewController? _controller;
  bool _isMultipleStop = false;
  bool _routeBuilt = false;
  String? _platformVersion;
  String? _instruction;

  final _origin = WayPoint(name: "Way Point 1", latitude: 23.06914384323535, longitude: 72.5735900946265, isSilent: true);
  final _stop1 = WayPoint(name: "Way Point 2", latitude: 23.075934836781453, longitude: 72.57470589354793, isSilent: true);
  // final _stop2 = WayPoint(name: "Way Point 3", latitude: 38.91040213277608, longitude: -77.03848242759705, isSilent: false);
  // final _stop3 = WayPoint(name: "Way Point 4", latitude: 38.909650771013034, longitude: -77.03850388526917, isSilent: true);
  final _destination =
      WayPoint(name: "Way Point 5", latitude: 23.081422656620386, longitude: 72.57685343344956, isSilent: false);

  _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;
    mapboxMap.style;

    mapboxMap.location.updateSettings(LocationComponentSettings(enabled: true));
  }

  @override
  void initState() {
    super.initState();
    setLocationComponent();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              FloatingActionButton(
                  heroTag: null,
                  onPressed: () async {
                    _isMultipleStop = true;
                    var wayPoints = <WayPoint>[];
                    wayPoints.add(_origin);
                    wayPoints.add(_stop1);
                    // wayPoints.add(_stop2);
                    // wayPoints.add(_stop3);
                    wayPoints.add(_destination);

                    MapBoxPlugin.instance.startNavigation(
                        wayPoints: wayPoints,
                        options: MapBoxOptions(
                            mode: MapBoxNavigationMode.driving,
                            simulateRoute: true,
                            language: "en",
                            allowsUTurnAtWayPoints: true,
                            units: VoiceUnits.metric));
                  },
                  child: const Icon(Icons.directions)),
            ],
          ),
        ),
        body: MapWidget(
          key: const ValueKey("mapWidget"),
          cameraOptions: CameraOptions(
              center: Point(
                  coordinates: Position(
                23.059515,
                72.57225,
              )).toJson(),
              zoom: 3.0),
          styleUri: MapboxStyles.LIGHT,
          textureView: true,
          gestureRecognizers: {
            Factory<EagerGestureRecognizer>(() => EagerGestureRecognizer()),
          },
          onMapCreated: _onMapCreated,
          onLongTapListener: (coordinate) {},
          resourceOptions: ResourceOptions(
              accessToken:
                  'pk.eyJ1IjoidmlyYWwtbW9ibWF4aW1lIiwiYSI6ImNsM2lvaTVvZjByejkzaWxubGw5NzI3N2gifQ.UCQRHLsUow_6gpjr90LV3A'),
        ),
      ),
    );
  }

  setCameraPosition(Position position) {
    mapboxMap?.flyTo(
        CameraOptions(
          center: Point(coordinates: position).toJson(),
          zoom: 16,
        ),
        null);
  }

  setLocationComponent() async {
    await mapboxMap?.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
        // puckBearing: PuckBearing.COURSE,
      ),
    );
  }
}
