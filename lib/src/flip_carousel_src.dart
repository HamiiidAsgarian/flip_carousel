import 'dart:math';
import 'package:flutter/material.dart';

class FlipCarousel extends StatefulWidget {
  const FlipCarousel({
    super.key,
    this.width = 300,
    this.height = 450,
    this.onChange,
    this.onTap,
    required this.items,
    this.backgroundColor,
    this.isAssetImage = false,
    this.fit = BoxFit.cover,
    this.childClip = Clip.hardEdge,
    this.layersGap = 30,
    this.perspectiveFactor = 0.0015,
    this.border,
    this.borderRadius = const BorderRadius.all(Radius.circular(5)),
    this.transitionDuration = const Duration(milliseconds: 500),
    this.arrowControllersVisibility = true,
    this.arrowControllersColor = Colors.white,
    this.heroTag = "3DCarouselHeroTag",
  }) : assert(items.length > 0);

  /// List of image/widgets to be shown in the carousel; Accepts two types of link.
  /// For example: `https://...jpg` for online images and `assets/...` for local images.
  final List<dynamic> items;

  /// Specifies the type of image addresses in [imagesLink].
  /// Must be `false` if [imagesLink] contains online images.
  /// Must be `true` if [imagesLink] contains local images.
  final bool isAssetImage;

  /// Set as the image slider [width].
  /// Defaults to 300.
  final double width;

  /// Set as the image slider [height].
  /// Defaults to 450.
  final double height;

  /// Returns the page index after animation is done .
  final Function(int pageIndex)? onChange;

  /// Runs the given code onPress .
  final Function()? onTap;

  /// Set as the main frames [backgroundColor].
  final Color? backgroundColor;

  /// Determines the value of the [fit] property of the images
  /// Defaults to BoxFit.cover.
  final BoxFit fit;

  /// Determines the space between two [H3DCard].
  /// Defaults to 30.
  final double layersGap;

  /// Determines the perspective transformation of the [H3DCard] when being animated.
  /// Defaults to 0.0015.
  final double perspectiveFactor;

  /// Determines the space between two [H3DCard].
  /// Defaults to 30.

  final BoxBorder? border;

  /// Determines the [borderRadius] of the [H3DCard].
  /// Defaults to 30.

  final BorderRadius borderRadius;

  /// Determines the clip behaviour of the child widget.
  /// Defaults to [Clip.hardEdge].

  final Clip childClip;

  /// Determines [Duration] of transition animation.
  /// Defaults to 500 milliseconds.
  final Duration transitionDuration;

  /// Determines [Visibility] of the transition arrows.
  /// Defaults to True.

  final bool arrowControllersVisibility;

  /// Determines [Color] of the transition arrows.
  /// Defaults to [Colors.white].
  final Color arrowControllersColor;

  /// Determines [tag] of the selected  [H3DCard].
  final String heroTag;

  @override
  State<FlipCarousel> createState() => _FlipCarouselState();
}

class _FlipCarouselState extends State<FlipCarousel>
    with TickerProviderStateMixin {
  late AnimationController _mainAnimCntrl;

  ///Each animation card is made of two different components. because it is not possible to change two cards z-index(stack order) in a "Not boolean" way, there are total number of 4 cards.
  /// when first pair cards reach to their 90(pi/2) degree of rotation, they stop being visible then the other two cards, with reveresed order, start reversed animation which appears to be an smooth transition.
  late Animation<double> _rotateAnimPhase1;
  late Animation<double> _rotateAnimPhase2;

  late Animation<double> _translateXAnimPhase1;
  late Animation<double> _translateXAnimPhase2;

  List<Widget> _rawItems = [];

  @override
  void initState() {
    _mainAnimCntrl =
        AnimationController(vsync: this, duration: widget.transitionDuration);

    _rotateAnimPhase1 = Tween<double>(begin: 0.0, end: pi / 2).animate(
        CurvedAnimation(
            parent: _mainAnimCntrl, curve: const Interval(0.0, .5)));
    _rotateAnimPhase2 = Tween<double>(begin: pi / 2, end: 0.0).animate(
        CurvedAnimation(
            parent: _mainAnimCntrl, curve: const Interval(0.5, 1.0)));

    _translateXAnimPhase1 = Tween<double>(begin: 0.0, end: widget.layersGap)
        .animate(CurvedAnimation(
            parent: _mainAnimCntrl, curve: const Interval(0.0, .5)));
    _translateXAnimPhase2 = Tween<double>(begin: widget.layersGap, end: 0.0)
        .animate(CurvedAnimation(
            parent: _mainAnimCntrl, curve: const Interval(0.5, 1.0)));

    /// converting [items] data to widgets
    _rawItems = widget.items.map((dynamic e) {
      return Stack(
        children: [
          Container(
            clipBehavior: widget.childClip,
            decoration: BoxDecoration(
                borderRadius: widget.borderRadius,
                border: widget.border,
                image: (e is String)
                    ? DecorationImage(
                        fit: widget.fit,
                        image: widget.isAssetImage
                            ? AssetImage(e) as ImageProvider
                            : NetworkImage(e))
                    : null),
            width: widget.width,
            height: widget.height,
            child: (e is Widget) ? e : const SizedBox(),
          ),
          Visibility(
            visible: widget.arrowControllersVisibility,
            child: Center(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        icon: Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Icon(Icons.arrow_back_ios,
                                color: widget.arrowControllersColor)),
                        onPressed: () async {
                          await _onDrag(ThreeDCarouselCardsDragDirection.right);

                          widget.onChange != null
                              ? widget.onChange!(_currentIndex)
                              : () {};
                        }),
                    IconButton(
                        icon: Icon(Icons.arrow_forward_ios,
                            color: widget.arrowControllersColor),
                        onPressed: () async {
                          await _onDrag(ThreeDCarouselCardsDragDirection.left);
                          widget.onChange != null
                              ? widget.onChange!(_currentIndex)
                              : () {};
                        })
                  ]),
            ),
          )
        ],
      );
    }).toList();

    super.initState();
  }

  @override
  void dispose() {
    _mainAnimCntrl.dispose();
    super.dispose();
  }

  ///just an initial value to not be null
  ThreeDCarouselCardsDragDirection _dragDirection =
      ThreeDCarouselCardsDragDirection.right;

  ///Index indicator
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      color: widget.backgroundColor,
      child: Center(child: _carsGenerator()),
    );
  }

  AnimatedBuilder _carsGenerator() {
    AnimatedBuilder res = AnimatedBuilder(
      animation: _mainAnimCntrl,
      builder: ((context, child) {
        bool myConditionAnim1 =
            _dragDirection == ThreeDCarouselCardsDragDirection.right
                ? _rotateAnimPhase1.value == pi / 2
                : _rotateAnimPhase1.value == -(pi / 2);
        bool myConditionAnim2 =
            _dragDirection == ThreeDCarouselCardsDragDirection.right
                ? _rotateAnimPhase2.value == (pi / 2)
                : _rotateAnimPhase2.value == -(pi / 2);
        int nextCardIndex =
            _dragDirection == ThreeDCarouselCardsDragDirection.right
                ? _rawItems.length - 1
                : 1;
        return Hero(
          tag: widget.heroTag,
          child: Container(
            color: widget.backgroundColor,
            child: Stack(
              children: [
                H3DCard(
                    perspective: widget.perspectiveFactor,
                    myConditionAnim1: myConditionAnim1,
                    translateXAnim: _translateXAnimPhase1.value,
                    rotateAnim1: _rotateAnimPhase1.value,
                    child: _rawItems[nextCardIndex]),
                GestureDetector(
                  onTap: () {
                    widget.onTap != null ? widget.onTap!() : () {};
                  },
                  //Top Card is touch sensetive
                  onHorizontalDragEnd: (e) async {
                    if (e.primaryVelocity! > 0) {
                      await _onDrag(ThreeDCarouselCardsDragDirection.left);
                    } else {
                      await _onDrag(ThreeDCarouselCardsDragDirection.right);
                    }
                    widget.onTap != null ? widget.onTap!() : () {};
                  },
                  child: H3DCard(
                      perspective: widget.perspectiveFactor,
                      myConditionAnim1: myConditionAnim1,
                      translateXAnim: -_translateXAnimPhase1.value,
                      rotateAnim1: _rotateAnimPhase1.value,
                      child: _rawItems[0]),
                ),
                H3DCard(
                    perspective: widget.perspectiveFactor,
                    myConditionAnim1: myConditionAnim2,
                    translateXAnim: -_translateXAnimPhase2.value,
                    rotateAnim1: -_rotateAnimPhase2.value,
                    child: _rawItems[0]),
                H3DCard(
                    perspective: widget.perspectiveFactor,
                    myConditionAnim1: myConditionAnim2,
                    translateXAnim: _translateXAnimPhase2.value,
                    rotateAnim1: -_rotateAnimPhase2.value,
                    child: _rawItems[nextCardIndex]),
              ],
            ),
          ),
        );
      }),
    );

    return res;
  }

  Future<void> _onDrag(ThreeDCarouselCardsDragDirection direction) async {
    double angle = direction == ThreeDCarouselCardsDragDirection.left
        ? (-pi / 2)
        : (pi / 2);
    double cardsTravelDestence =
        direction == ThreeDCarouselCardsDragDirection.left
            ? (-widget.layersGap)
            : (widget.layersGap);

    _rotateAnimPhase1 = Tween<double>(begin: 0.0, end: angle).animate(
        CurvedAnimation(
            parent: _mainAnimCntrl, curve: const Interval(0.0, .5)));
    _rotateAnimPhase2 = Tween<double>(begin: angle, end: 0.0).animate(
        CurvedAnimation(
            parent: _mainAnimCntrl, curve: const Interval(0.5, 1.0)));

    _translateXAnimPhase1 = Tween<double>(begin: 0.0, end: cardsTravelDestence)
        .animate(CurvedAnimation(
            parent: _mainAnimCntrl,
            curve: const Interval(0.0, .5, curve: Curves.easeOut)));
    _translateXAnimPhase2 = Tween<double>(begin: cardsTravelDestence, end: 0.0)
        .animate(CurvedAnimation(
            parent: _mainAnimCntrl,
            curve: const Interval(0.5, 1.0, curve: Curves.easeIn)));

    setState(() {
      _dragDirection = direction;
    });
    await _mainAnimCntrl.forward();
    _mainAnimCntrl.reset();

    if (direction == ThreeDCarouselCardsDragDirection.left) {
      setState(() {
        Widget temp = _rawItems.first;

        _rawItems.removeAt(0);
        _rawItems.add(temp);
      });

      //* index calculation when draged left
      if (_currentIndex < _rawItems.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = (_rawItems.length - 1) - _currentIndex;
      }
    } else {
      Widget temp = _rawItems.last;

      _rawItems.removeLast();
      _rawItems.insert(0, temp);

      /// index calculation when draged right
      if (_currentIndex > 0) {
        _currentIndex--;
      } else {
        _currentIndex = (_rawItems.length - 1);
      }
    }
  }
}

class H3DCard extends StatelessWidget {
  const H3DCard({
    Key? key,
    required this.myConditionAnim1,
    required double translateXAnim,
    required double rotateAnim1,
    required this.child,
    required this.perspective,
  })  : _translateXAnim = translateXAnim,
        _rotateAnim1 = rotateAnim1,
        super(key: key);

  final double perspective;
  final bool myConditionAnim1;
  final Widget child;
  final double _translateXAnim;
  final double _rotateAnim1;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: !(myConditionAnim1),
      child: Transform(
          alignment: Alignment.center,
          transform: Matrix4(
            1.0,
            0,
            0,
            0,
            0,
            1.0,
            0,
            0,
            0,
            0,
            1,

            ///Depth of perspective effect - higher value,the higher the perspective
            perspective,
            _translateXAnim,
            0,
            0,
            1,
          )..rotateY(_rotateAnim1),
          child: child),
    );
  }
}

enum ThreeDCarouselCardsDragDirection { left, right }
