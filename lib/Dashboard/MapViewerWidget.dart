import 'package:data_dashboard/Data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';

class MapViewerWidget extends StatefulWidget {
  const MapViewerWidget({super.key, required this.location, this.position});

  final DataLocation location;
  final DataPosition? position;

  @override
  State<MapViewerWidget> createState() => _MapViewerWidgetState();
}

class _MapViewerWidgetState extends State<MapViewerWidget> {
  Stream<LocationMarkerPosition> positionStream = Stream.empty();
  Stream<LocationMarkerHeading> headingStream = Stream.empty();
  Style? style;

  Future getStyle() async {
    try {
      var sty = await _readStyle();
      setState(() {
        style = sty;
      });
    } catch (e) {
      print("Failed to get style: $e");
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    getStyle();
    positionStream = Stream.value(LocationMarkerPosition(
      latitude: widget.location.value.latitude,
      longitude: widget.location.value.longitude,
      accuracy: 6,
    ));
    headingStream = Stream.value(LocationMarkerHeading(
      heading: widget.position?.value.z ?? 0,
      accuracy: 6,
    ));
  }

  @override
  void didUpdateWidget(covariant MapViewerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    positionStream = Stream.value(LocationMarkerPosition(
      latitude: widget.location.value.latitude,
      longitude: widget.location.value.longitude,
      accuracy: 6,
    ));
    headingStream = Stream.value(LocationMarkerHeading(
      heading: widget.position?.value.z ?? 0,
      accuracy: 6,
    ));
  }
  // pk.eyJ1Ijoia29lYmVsdCIsImEiOiJjbHdleXd2ZmoxajMyMmpwbHNwb3dsd3dwIn0.DovkeyoCu3WZ2439uI9XnQ

  Future<Style> _readStyle() => StyleReader(
        uri:
            'mapbox://styles/koebelt/clweyria900it01qr6sm3bmo8?access_token={key}',
        apiKey:
            "pk.eyJ1Ijoia29lYmVsdCIsImEiOiJjbHdleXd2ZmoxajMyMmpwbHNwb3dsd3dwIn0.DovkeyoCu3WZ2439uI9XnQ",
        // uri:
        //     'https://tiles.stadiamaps.com/styles/alidade_smooth_dark.json?api_key=dcea3392-aab3-43bd-8e25-571d8c6b9e17',
        // apiKey: "dcea3392-aab3-43bd-8e25-571d8c6b9e17",
      ).read();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: style == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(widget.location.value.latitude,
                    widget.location.value.longitude),
                initialZoom: 19,
                maxZoom: 20,
                backgroundColor: Theme.of(context).colorScheme.background,
              ),
              children: [
                // TileLayer(
                //   urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                // ),

                VectorTileLayer(
                  theme: style!.theme,
                  // sprites: style!.sprites,
                  tileProviders: style!.providers,
                  tileOffset: TileOffset.mapbox,
                  layerMode: VectorTileLayerMode.vector,
                  maximumZoom: 20,
                ),
                CurrentLocationLayer(
                  style: LocationMarkerStyle(
                    marker: DefaultLocationMarker(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    accuracyCircleColor:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    headingSectorColor:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  ),
                  alignPositionOnUpdate: AlignOnUpdate.always,
                  alignDirectionOnUpdate: AlignOnUpdate.never,
                  positionStream: positionStream,
                  headingStream: headingStream,
                )
              ],
            ),
    );
  }
}
