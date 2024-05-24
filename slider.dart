// images source

class Magazine {
  const Magazine({
    required this.id,
    required this.assetImage,
    required this.description,
  });

  final String id;
  final String assetImage;
  final String description;
  static final List<Magazine> fakeMagazinesValues = List.generate(
    13,
    (index) => Magazine(
      id: '$index',
      assetImage: 'assets/img/vice/vice${index + 1}.png',
      description:
          'Lorem Ipsum is simply dummy text of the printing and typesetting '
          "industry. Lorem Ipsum has been the industry's standard dummy "
          'text ever since the 1500s, when an unknown printer took a galley '
          'of type and scrambled it to make a type specimen book. It has '
          'survived not only five centuries, but also the leap into '
          'electronic typesetting, remaining essentially unchanged. It was '
          'popularised in the 1960s with the release of word set sheets '
          'containing Lorem Ipsum passages, and more recently with desktop'
          ' publishing software like Aldus PageMaker including versions of '
          'Lorem Ipsum',
    ),
  );
}


//home page

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vice_app/features/home/presentation/widgets/infinite_dragable_slider.dart';

import '../../../../core/core.dart';
import '../../../magazines_details/presentation/screens/magazines_details_screen.dart';
import '../widgets/all_editions_list_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.enableEntryAnimation = false,
    this.initialIndex = 0,
  });

  final bool enableEntryAnimation;
  final int initialIndex;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final List<Magazine> magazines = Magazine.fakeMagazinesValues;
  late int currentIndex;

  @override
  void initState() {
    currentIndex = widget.initialIndex;

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void openMagazineDetail(
    BuildContext context,
    int index,
  ) {
    setState(() => currentIndex = index);
    MagazinesDetailsScreen.push(
      context,
      magazines: magazines,
      index: currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ViceUIConsts.gradientDecoration,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: _AppBar(),
        body: Column(
          children: [
           
            SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: const TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(ViceIcons.search),
                ),
              ),
            ),
            SizedBox(height: 20),
            const Text(
              'THE ARCHIVE',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
             // change height to make slide smaller
            SizedBox(height: 72),
            Expanded(
              child: InfiniteDragableWidget(
                itemCount: Magazine.fakeMagazinesValues.length,
                itemBuilder: (context, index) => MagazineCoverImage(magazine: Magazine.fakeMagazinesValues[index]),

              )
              ),
            // TODO: InfiniteDraggableSlider
            SizedBox(height: 52),
            SizedBox(
              height: 140,
              child: AllEditionsListView(magazines: magazines),
            ),
            SizedBox(height: 12),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: SizedBox(
            height: kToolbarHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(ViceIcons.home),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(ViceIcons.settings),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(ViceIcons.share),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(ViceIcons.heart),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _AppBar extends StatelessWidget implements PreferredSize {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      clipBehavior: Clip.none,
      title: Image.asset(
        'assets/img/vice/vice-logo.png',
        height: 30,
        color: Colors.white,
      ),
      actions: [
        const MenuButton(),
      ],
    );
  }

  @override
  Widget get child => this;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}


// main dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/app/vice_app.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  runApp(const ViceApp());
}


// dragable widget


import 'dart:math';

import 'package:flutter/material.dart';
//

// understand if slide is on left or right
enum SlideDirection{ left, right}

class DragableWidget extends StatefulWidget {
  const DragableWidget({super.key, required this.child, this.onSlideOut,this.onPressed, required this.isEnableDrag});
// Things to add to the dragable
// child to display
final Widget child;
//which part of the slide is going
final ValueChanged<SlideDirection>? onSlideOut;
// function if is pressed
final VoidCallback? onPressed;
// controll if dragging is allowed
final bool isEnableDrag;




//@@@
  @override
  State<DragableWidget> createState() => _DragableWidgetState();
}

class _DragableWidgetState extends State<DragableWidget> with SingleTickerProviderStateMixin {
// moving back widget to its starter position
late AnimationController restoreController;
late Size screenSize;

final _widgetKey = GlobalKey();
Offset startOffset = Offset.zero;
// panOffset to move the card
Offset panOffset = Offset.zero;
Size size = Size.zero;
double angle = 0;

// Figure out while user make the slide
bool itWasMadeSlide = false;
double get outSizeLimit => size.width * 0.65;

// separate onPan settings
void onPanStart(DragStartDetails details){
  if(!restoreController.isAnimating){
    setState((){
        startOffset = details.globalPosition;
    });
  }
}

void onPanUpdate(DragUpdateDetails details){
  if(!restoreController.isAnimating){
    setState((){
        //panOffset = panOffset = details.globalPosition - startOffset;
        panOffset = details.globalPosition - startOffset;
        angle = currentAngle;
    });
  }
}

//onPanend
void onPanend(DragEndDetails details){
  if(restoreController.isAnimating){
    return;
  }
  final velocityX = details.velocity.pixelsPerSecond.dx;
  final positionX = currentPosition.dx;
  if(velocityX < -1000 || positionX < -outSizeLimit){
    // make rotate on slide
    itWasMadeSlide = widget.onSlideOut != null;
    widget.onSlideOut?.call(SlideDirection.left);
  }

  if(velocityX > 1000 || positionX > (screenSize.width - outSizeLimit)){
   itWasMadeSlide = widget.onSlideOut != null;
    widget.onSlideOut?.call(SlideDirection.right);
  }
  restoreController.forward();
}

// Animation listener
void restoreAnimationListener(){
  if(restoreController.isCompleted){
    restoreController.reset();
    panOffset = Offset.zero;
    itWasMadeSlide = false;
    angle = 0;
    setState(() {
      
    });
  }
}

// current position of the card while move
Offset get currentPosition{
  final renderBox = 
  _widgetKey.currentContext?.findRenderObject() as RenderBox?;
  return renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
}

// rotation
double get currentAngle{
  double angle = currentPosition.dx < 0
  ? (pi * 0.2) * currentPosition.dx / size.width
  : currentPosition.dx + size.width > screenSize.width
  ? (pi * 0.2) * 
  (currentPosition.dx + size.width - screenSize.width)
  / size.width
  : 0;
return angle.isFinite ? angle : 0.0;
}

// getChildSize
void getChildSize(){
  size = (_widgetKey.currentContext?.findRenderObject() as RenderBox?)?.size ?? Size.zero;
}
  //@@@
  @override
//initState
void initState(){
  restoreController = 
  AnimationController(vsync: this, duration: kThemeAnimationDuration)..addListener(restoreAnimationListener);
  WidgetsBinding.instance.addPostFrameCallback((_) {
    screenSize = MediaQuery.of(context).size;
    getChildSize();
   });
  super.initState();
}

//dispose
@override
void dispose(){
  restoreController
  ..removeListener(restoreAnimationListener)
  ..dispose();
  super.dispose();
}


  Widget build(BuildContext context) {
    // settings with music to check
    final child = SizedBox(key: _widgetKey, child: widget.child);
    if(!widget.isEnableDrag) return child;


    //GestureDetector
    return GestureDetector(
      // add settings
      onPanStart: onPanStart,
      // not working, solution wrap child in transform and add onPanUpdate
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanend,

      child: AnimatedBuilder(
        animation: restoreController,
        builder: (context, child) {
          final value = 1-restoreController.value;
          return Transform.translate(
            offset: panOffset * value,
            child: Transform.rotate(
              angle: angle * (itWasMadeSlide ? 1 : value),
              child: child),
            );
        },
        child: child,
      ),
    );
  }
}

// infite slider widget

import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:vice_app/core/shared/domain/entities/magazine.dart';
import 'package:vice_app/core/shared/presentation/widgets/magazine_cover_image.dart';
import 'package:vice_app/features/home/presentation/widgets/dragable_widget.dart';

class InfiniteDragableWidget extends StatefulWidget {
  const InfiniteDragableWidget({
    super.key, required this.itemBuilder, required this.itemCount, this.index = 0,
  });
// ** properties
// pass emements to slide, essential
final Function(BuildContext context, int index) itemBuilder;
// how many elements, essential
final int itemCount;
//remind current item to display, optional
final int index;

// **overrides
  @override
  State<InfiniteDragableWidget> createState() => _InfiniteDragableWidgetState();
}


class _InfiniteDragableWidgetState extends State<InfiniteDragableWidget> with SingleTickerProviderStateMixin {
 // angle rotation used a lot, use a variable
 final defaultAngle18Degree = pi * 0.1;
 late AnimationController controller;
 late int index;

// animation on slide
SlideDirection slideDirection = SlideDirection.left;

 // fix images appearing above each other
//  Offset getOffset(int stackIndex){
//   return {
//     0: Offset(70, 30),
//     1: Offset(-70, 30),
//     2: Offset(70, 30),
//   }[stackIndex] ?? Offset(0, 0); // why without this error
//  }

  Offset getOffset(int stackIndex){
  return {
    0: Offset(lerpDouble(0, 70, controller.value)!, 30),
    1: Offset(lerpDouble(-70, 0, controller.value)!, 30),
    2: Offset(70, 30) * (1 - controller.value),
  }[stackIndex] ?? Offset(0, 0); // why without this error
 }

// fix magazines rotate to the same angle
double getAngle(int stackIndex)=>{
    0: 0.0,
    1: -defaultAngle18Degree,
    2: defaultAngle18Degree,
  }[stackIndex] ?? 0.0;

// fix the small scale
double getScale(int stackIndex) =>
{
0: 0.6,
1: 0.9,
2: 0.95,
}[stackIndex] ?? 1.0;

void onSlideOut(SlideDirection direction){
  slideDirection = direction;
  controller.forward();
}

// void animationListener(){
//   if(controller.isCompleted){
//     setState(() {
//       if(widget.itemCount == ++index){
//         index = 0;
//       }
//     });
//   }
// }
//fixe:
void animationListener(){
  if(controller.isCompleted){
    setState(() {
      index++;
      if(index >= widget.itemCount){
        index = 0;
      }
    });
    controller.reset();
  }
}

@override
  void initState() {
    index = widget.index;
    controller = AnimationController(vsync: this, duration: kThemeAnimationDuration)
    ..addListener(animationListener);
    super.initState();
  }

@override
  void dispose() {
    controller
    ..removeListener(animationListener)
    ..dispose();
    super.dispose();
  }

// @@@@overrides@@@@
@override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Stack(
          children:
            List.generate(
              4, 
            (stackIndex){
              final modIndex = (index + 3 - stackIndex) % widget.itemCount;
              return Transform.translate(
              offset: getOffset(stackIndex),
              child: Transform.scale(
                scale: getScale(stackIndex),
                child: Transform.rotate(
                  angle: getAngle(stackIndex),
                  // check
                  child: DragableWidget(
                    onSlideOut: onSlideOut,
                    // if index is 3 IS draggable
                    isEnableDrag: stackIndex == 3,
                    child: widget.itemBuilder(context, modIndex),
                  )
                  //widget.itemBuilder(context, stackIndex),
                ),
              ),
            );
            })
        );
      }
    );
  }
}

