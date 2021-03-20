/// Flutter code sample for InteractiveViewer.transformationController
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

/// This is the main application widget.
class MyApp extends StatelessWidget {
  const MyApp({key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyStatefulWidget(),
    );
  }
}

/// This is the stateful widget that the main application instantiates.
class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({key}) : super(key: key);
  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

/// This is the private State class that goes with MyStatefulWidget.
/// AnimationControllers can be created with `vsync: this` because of TickerProviderStateMixin.
class _MyStatefulWidgetState extends State<MyStatefulWidget>
    with TickerProviderStateMixin {
  final TransformationController _transformationController =
      TransformationController();
  late Animation<Matrix4> _animationReset;
  late final AnimationController _controllerReset;

  void _onAnimateReset() {
    _transformationController.value = _animationReset.value;
    if (!_controllerReset.isAnimating) {
      _animationReset.removeListener(_onAnimateReset);
      _controllerReset.reset();
    }
  }

  void _animateResetInitialize() {
    _controllerReset.reset();
    _animationReset = Matrix4Tween(
      begin: _transformationController.value,
      end: Matrix4.identity(),
    ).animate(_controllerReset);
    _animationReset.addListener(_onAnimateReset);
    _controllerReset.forward();
  }

// Stop a running reset to home transform animation.
  void _animateResetStop() {
    _controllerReset.stop();
    _animationReset.removeListener(_onAnimateReset);
    _controllerReset.reset();
  }

  void _onInteractionStart(ScaleStartDetails details) {
    // If the user tries to cause a transformation while the reset animation is
    // running, cancel the reset animation.
    if (_controllerReset.status == AnimationStatus.forward) {
      _animateResetStop();
    }
  }

  @override
  void initState() {
    super.initState();
    _controllerReset = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _controllerReset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Container(
        decoration: new BoxDecoration(
          image: new DecorationImage(
            image: new AssetImage("images/background.jpeg"),
            fit: BoxFit.cover,
          ),
        ),
        child: InteractiveViewer(
          boundaryMargin: EdgeInsets.all(double.infinity),
          transformationController: _transformationController,
          minScale: 0.1,
          maxScale: 5,
          onInteractionStart: _onInteractionStart,
          child: Container(
            // height: 50,
            // width: 50,
            margin: const EdgeInsets.all(25.0),
            padding: const EdgeInsets.all(3.0),
            decoration: BoxDecoration(
              image: DecorationImage(
                scale: 5,
                image: AssetImage("images/pinchme.png"),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
