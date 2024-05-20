import 'package:capstone_driver_carpool/pages/map_page.dart';
import 'package:capstone_driver_carpool/pages/message_page.dart';
import 'package:capstone_driver_carpool/pages/trips_page.dart';
import 'package:capstone_driver_carpool/pages/home_page.dart';
import 'package:capstone_driver_carpool/pages/profile_page.dart';
import 'package:capstone_driver_carpool/pages/trips_page.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget
{
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with SingleTickerProviderStateMixin
{
  TabController? controller;
  int indexSelected = 0;

  onBarItemClicked(int i)
  {
    setState(() {
      indexSelected = i;
      controller!.index = indexSelected;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    controller = TabController
      (
        length: 5,
        vsync: this
      );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView
        (
        physics: const NeverScrollableScrollPhysics(),
        controller: controller,
        children: const [
          HomePage(),
          TripsPage(),
          MapPage(),
          MessagePage(),
          ProfilePage(),
        ],


      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.car_rental),
              label: "Trips"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: "Map"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: "Message"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile"
          ),
        ],
        currentIndex: indexSelected,
        // backgroundColor: Colors.black,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.pink,
        showSelectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 12),
        type: BottomNavigationBarType.fixed,
        onTap: onBarItemClicked,
      ),
    );
  }
}
