import 'package:flutter/material.dart';
import 'package:ditredi/ditredi.dart';
import 'package:vector_math/vector_math_64.dart';

class TreeDViewerWidget extends StatefulWidget {
  const TreeDViewerWidget({super.key});

  @override
  State<TreeDViewerWidget> createState() => _TreeDViewerWidgetState();
}

class _TreeDViewerWidgetState extends State<TreeDViewerWidget> {
  DiTreDiController controller = DiTreDiController(
      userScale: 250,
      viewScale: 20,
      lightStrength: 0,
      ambientLightStrength: 1,
      rotationX: 30);
  List<Face3D> model = [];

  Future loadModel() async {
    final model = await ObjParser().loadFromResources("assets/sphere.obj");

    setState(() {
      this.model = model;
    });
  }

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  @override
  Widget build(BuildContext context) {
    Vector3 center = Vector3(0, 0, 0);
    Vector3 rotation = Vector3(0, 0, 0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: DiTreDi(
        config: DiTreDiConfig(
          perspective: false,
          defaultLineWidth: 0.1,
          defaultPointWidth: 0.1,
          defaultColorMesh: Theme.of(context).colorScheme.primary,
          defaultColorPoints: Theme.of(context).colorScheme.primary,
        ),
        controller: controller,
        figures: [
          ...lineGridBuilder(context, squareSize: 0.5),
          TransformModifier3D(
            Mesh3D(model),
            Matrix4.identity()
              ..translate(center)
              ..rotateX(rotation.x)
              ..rotateY(rotation.y)
              ..rotateZ(rotation.z)
              ..scale(0.0003),
          ),
          ...xyzAxesBuilder(context, center: center, rotation: rotation),
        ],
      ),
    );
  }
}

List<Model3D> xyzAxesBuilder(context,
    {double size = 0.5,
    required Vector3 center,
    double width = 4,
    required Vector3 rotation}) {
  Vector3 xStart = Vector3(0.07, 0, 0);
  Vector3 yStart = Vector3(0, 0.07, 0);
  Vector3 zStart = Vector3(0, 0, 0.07);

  return [
    TransformModifier3D(
      Line3D(xStart, Vector3(size, 0, 0),
          width: width, color: Color.fromARGB(255, 238, 250, 82)
          //Theme.of(context).colorScheme.primary,
          ),
      Matrix4.identity()
        ..translate(center)
        ..rotateX(rotation.x)
        ..rotateY(rotation.y)
        ..rotateZ(rotation.z),
    ),
    TransformModifier3D(
      Line3D(yStart, Vector3(0, size, 0),
          width: width,
          color: Color.fromARGB(
              255, 253, 180, 77) //Theme.of(context).colorScheme.primary,
          ),
      Matrix4.identity()
        ..translate(center)
        ..rotateX(rotation.x)
        ..rotateY(rotation.y)
        ..rotateZ(rotation.z),
    ),
    TransformModifier3D(
      Line3D(zStart, Vector3(0, 0, size),
          width: width,
          color: Color.fromARGB(
              255, 77, 227, 253) //Theme.of(context).colorScheme.primary,
          ),
      Matrix4.identity()
        ..translate(center)
        ..rotateX(rotation.x)
        ..rotateY(rotation.y)
        ..rotateZ(rotation.z),
    ),
  ];
}

// line grid with each square of size 1
List<Model3D> lineGridBuilder(context,
    {int gridSize = 10, double squareSize = 1}) {
  final List<Model3D> grid = [];
  final double pointSize =
      0.3 * squareSize; // Size of the points at intersections
  for (double i = -gridSize * squareSize;
      i <= gridSize * squareSize;
      i += squareSize) {
    for (double j = -gridSize * squareSize;
        j <= gridSize * squareSize;
        j += squareSize) {
      // Add a small cross at each intersection point to represent the crossing
      grid.add(Line3D(
        Vector3(i - pointSize, 0, j),
        Vector3(i + pointSize, 0, j),
        width: 1,
        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      ));
      grid.add(Line3D(
        Vector3(i, 0, j - pointSize),
        Vector3(i, 0, j + pointSize),
        width: 1,
        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      ));
    }
  }
  return grid;
}
