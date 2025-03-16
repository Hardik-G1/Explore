// import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hello_world/screens/components/nav_bar.dart';
import 'package:hello_world/screens/map_screen.dart';
// import 'package:hello_world/utils/rive_utils.dart';
// import 'package:rive/rive.dart';

// import '../../models/menu.dart';
// import 'components/btm_nav_item.dart';
// import 'components/menu_btn.dart';
// import 'components/side_bar.dart';

const Color backgroundColor2 = Color(0xFF17203A);
const Color backgroundColorLight = Color(0xFFF2F6FF);
const Color backgroundColorDark = Color(0xFF25254B);
const Color shadowColorLight = Color(0xFF4A5367);
const Color shadowColorDark = Colors.black;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        resizeToAvoidBottomInset: false,
        backgroundColor: backgroundColor2,
        body: MapScreen(),
        bottomNavigationBar: GlassNavBar());
  }
}
// Stack(
//         children: [
//           AnimatedPositioned(
//             width: 288,
//             height: MediaQuery.of(context).size.height,
//             duration: const Duration(milliseconds: 200),
//             curve: Curves.fastOutSlowIn,
//             left: isSideBarOpen ? 0 : -288,
//             top: 0,
//             child: const SideBar(),
//           ),
//           Transform(
//             alignment: Alignment.center,
//             transform: Matrix4.identity()
//               ..setEntry(3, 2, 0.001)
//               ..rotateY(
//                   1 * animation.value - 30 * (animation.value) * pi / 180),
//             child: Transform.translate(
//               offset: Offset(animation.value * 265, 0),
//               child: Transform.scale(
//                 scale: scalAnimation.value,
//                 child: const ClipRRect(
//                   borderRadius: BorderRadius.all(
//                     Radius.circular(24),
//                   ),
//                   child: MapScreen(),
//                 ),
//               ),
//             ),
//           ),
//           AnimatedPositioned(
//             duration: const Duration(milliseconds: 200),
//             curve: Curves.fastOutSlowIn,
//             left: isSideBarOpen ? 220 : 0,
//             top: 16,
//             child: MenuBtn(
//               press: () {
//                 isMenuOpenInput.value = !isMenuOpenInput.value;

//                 if (_animationController.value == 0) {
//                   _animationController.forward();
//                 } else {
//                   _animationController.reverse();
//                 }

//                 setState(
//                   () {
//                     isSideBarOpen = !isSideBarOpen;
//                   },
//                 );
//               },
//               riveOnInit: (artboard) {
//                 final controller = StateMachineController.fromArtboard(
//                     artboard, "State Machine");

//                 artboard.addController(controller!);

//                 isMenuOpenInput =
//                     controller.findInput<bool>("isOpen") as SMIBool;
//                 isMenuOpenInput.value = true;
//               },
//             ),
//           ),
//         ],
//       ),
