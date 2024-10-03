import 'package:data_dashboard/Keyframes.dart';
import 'package:ditredi/ditredi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

class LandingAnimationWidget extends StatefulWidget {
  const LandingAnimationWidget({super.key});

  @override
  State<LandingAnimationWidget> createState() => _LandingAnimationWidgetState();
}

class _LandingAnimationWidgetState extends State<LandingAnimationWidget>
    with TickerProviderStateMixin {
  DiTreDiController controller = DiTreDiController(
      userScale: 250,
      viewScale: 20,
      lightStrength: 0,
      ambientLightStrength: 1,
      rotationX: 30);
  List<Face3D> model = [];
  Vector3 center = Vector3(0, 0, 0);

  late AnimationController _controller;
  late Animation<double> _animation;

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
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(); // The controller repeats indefinitely

    // You can animate a double (0 to 1) to control the keyframes
    _animation = TweenSequence<double>([
      for (int i = 0; i < keyFrames.length; i++)
        TweenSequenceItem(
          tween: Tween<double>(
                  begin: i.toDouble(),
                  end: (i + 1) % keyFrames.length.toDouble())
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 1.0, // Equal weight for each keyframe transition
        ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Vector3 interpolateVectors(Vector3 start, Vector3 end, double progress) {
    return Vector3(
      start.x + (end.x - start.x) * progress,
      start.y + (end.y - start.y) * progress,
      start.z + (end.z - start.z) * progress,
    );
  }

  List<Vector3> getCurrentRotation(double progress) {
    int startFrame = progress.floor();
    int endFrame = (startFrame + 1) % keyFrames.length;

    double frameProgress = progress - startFrame;

    List<Vector3> interpolatedFrame = [];
    for (int i = 0; i < keyFrames[startFrame].length; i++) {
      interpolatedFrame.add(interpolateVectors(
          keyFrames[startFrame][i], keyFrames[endFrame][i], frameProgress));
    }

    return interpolatedFrame;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        double progress = _animation.value;
        List<Vector3> currentRotation = getCurrentRotation(progress);
        return Container(
          height: 400,
          margin: const EdgeInsets.symmetric(vertical: 20),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
                color: Theme.of(context).colorScheme.primary, width: 2),
          ),
          child: ClipRRect(
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
                  Matrix4.identity()..scale(0.0003),
                ),
                ...xyzAxesBuilder(context,
                    center: center, rotation: currentRotation),
              ],
            ),
          ),
        );
      },
    );
  }
}

List<Model3D> xyzAxesBuilder(context,
    {double size = 0.3,
    required Vector3 center,
    double width = 5,
    required List<Vector3> rotation}) {
  List<Vector3> start = [
    Vector3(0.07, 0, 0),
    Vector3(0, 0.07, 0),
    Vector3(0, 0, 0.07),
    Vector3(-0.07, 0, 0),
    Vector3(0, -0.07, 0),
    Vector3(0, 0, -0.07),
  ];

  List<Vector3> end = [
    Vector3(size, 0, 0),
    Vector3(0, size, 0),
    Vector3(0, 0, size),
    Vector3(-size, 0, 0),
    Vector3(0, -size, 0),
    Vector3(0, 0, -size),
  ];

  Vector3 globalRotation = rotation[6];

  return [
    for (int i = 0; i < 6; i++)
      TransformModifier3D(
        Line3D(
          start[i],
          end[i],
          width: width,
          color: Theme.of(context).colorScheme.primary,
        ),
        Matrix4.identity()
          ..translate(center)
          ..rotateX(rotation[i].x + globalRotation.x)
          ..rotateY(rotation[i].y + globalRotation.y)
          ..rotateZ(rotation[i].z + globalRotation.z),
      ),
    // TransformModifier3D(
    //   Line3D(
    //     xStart, Vector3(size, 0, 0),
    //     width: width, color: Theme.of(context).colorScheme.primary,
    //     //Theme.of(context).colorScheme.primary,
    //   ),
    //   Matrix4.identity()
    //     ..translate(center)
    //     ..rotateX(rotation.x)
    //     ..rotateY(rotation.y)
    //     ..rotateZ(rotation.z),
    // ),
    // TransformModifier3D(
    //   Line3D(
    //     yStart,
    //     Vector3(0, size, 0),
    //     width: width,
    //     color: Theme.of(context).colorScheme.primary,
    //   ),
    //   Matrix4.identity()
    //     ..translate(center)
    //     ..rotateX(rotation.x)
    //     ..rotateY(rotation.y)
    //     ..rotateZ(rotation.z),
    // ),
    // TransformModifier3D(
    //   Line3D(
    //     zStart, Vector3(0, 0, size),
    //     width: width,
    //     color: Theme.of(context)
    //         .colorScheme
    //         .primary, //Theme.of(context).colorScheme.primary,
    //   ),
    //   Matrix4.identity()
    //     ..translate(center)
    //     ..rotateX(rotation.x)
    //     ..rotateY(rotation.y)
    //     ..rotateZ(rotation.z),
    // ),
  ];
}

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
