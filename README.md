A simple infinite horizontal carousel with flip animation which can be used for both image and widgets

![](https://i.ibb.co/N2LWGsY/hamiiid.gif)

## 📱 Usage

Import package in your file
```dart
import 'package:flip_carousel/flip_carousel.dart';
```
Use FlipCarousel widget
```dart
FlipCarousel(items:cardItems);
```
Give a list of data and set the properties as you wish
```dart

List<dynamic> cardItems = [
    'https://i.ibb.co/QYdQHBw/batman2.jpg',
    'https://i.ibb.co/vwhykYp/spider1.jpg',
    'https://i.ibb.co/H4VrQS4/spider2.jpg',
    Container(color: Colors.amber, child: const FlutterLogo()),
  ];



FlipCarousel(
        items: cardItems,
          transitionDuration: const Duration(milliseconds: 400),
          isAssetImage: false,
          border: Border.all(width: 5, color: const Color(0xFFFFFFFF)),
          width: 250,
          height: 400,
          fit: BoxFit.cover,
          perspectiveFactor: 0.002,
          layersGap: 30,
          
          onChange: (int pageIndex) {
            print(pageIndex);
          },
          onTap: () {
            print("tap");
          },
        ),
```

## Customization 
- You can add both widgets and ImageUrls as input.
- make sure that you have set the the [ isAssetImage ] value base on your source.

Here is the rest of properties that can be modyfied

```dart

  /// List of image/widgets to be shown in the carousel; Accepts two types of link.
  /// For example: `https://...jpg` for online images and `assets/...` for local images.
  final List<dynamic> items;

  /// Specifies the type of image addresses in [imagesLink].
  /// Must be `false` if [imagesLink] contains online images.
  /// Must be `true` if [imagesLink] contains local images.
  final bool assetImage;

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

```#
