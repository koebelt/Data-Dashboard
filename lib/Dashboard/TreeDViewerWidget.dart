import 'package:flutter/material.dart';
import 'package:ditredi/ditredi.dart';
// leave out colors
import 'package:vector_math/vector_math_64.dart' show Vector3;

class TreeDViewerWidget extends StatefulWidget {
  const TreeDViewerWidget({super.key, this.rotation});

  final Vector3? rotation;

  @override
  State<TreeDViewerWidget> createState() => _TreeDViewerWidgetState();
}

enum MovementMode { TRANSLATE, ROTATE }

class _TreeDViewerWidgetState extends State<TreeDViewerWidget> {
  DiTreDiController controller = DiTreDiController(
      userScale: 250,
      viewScale: 20,
      lightStrength: 0,
      ambientLightStrength: 1,
      rotationX: 30);
  List<Face3D> model = [];
  MovementMode movementMode = MovementMode.TRANSLATE;

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
    Vector3 rotation = widget.rotation ?? Vector3(-1, 0, 0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                if (movementMode == MovementMode.ROTATE) {
                  controller.rotationX += details.delta.dy;
                  controller.rotationY += details.delta.dx;
                } else {
                  controller.translation = Offset(
                      controller.translation.dx + details.delta.dx,
                      controller.translation.dy + details.delta.dy);
                }
              });
            },
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
          ),
          Positioned(
            top: 10,
            left: 0,
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (movementMode == MovementMode.TRANSLATE) {
                        movementMode = MovementMode.ROTATE;
                      } else {
                        movementMode = MovementMode.TRANSLATE;
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(5),
                    backgroundColor: Colors.white,
                    shape: CircleBorder(),
                  ),
                  child: Icon(
                    movementMode == MovementMode.TRANSLATE
                        ? Icons.open_with
                        : Icons.rotate_90_degrees_ccw,
                    color: Theme.of(context).colorScheme.background,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      controller = DiTreDiController(
                          userScale: 250,
                          viewScale: 20,
                          lightStrength: 0,
                          ambientLightStrength: 1,
                          rotationX: 30);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(5),
                    backgroundColor: Colors.white,
                    shape: CircleBorder(),
                  ),
                  child: Icon(
                    Icons.refresh,
                    color: Theme.of(context).colorScheme.background,
                  ),
                ),
              ],
            ),
          ),
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
