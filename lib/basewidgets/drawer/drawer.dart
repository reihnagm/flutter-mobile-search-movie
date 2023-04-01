import 'package:flutter/material.dart';
import 'package:flutter_search/screens/searchv2.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            padding: EdgeInsets.zero,
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: SizedBox(),
          ),
          ListTile(
            title: const Text('Search V1',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.black
              ),
            ),
            minLeadingWidth: 20.0,
            leading: const Icon(Icons.search),
            onTap: () {
              
            },
          ),
          Divider(
            height: 0.0,
            color: Colors.grey[200]!,
            thickness: 1.0,
          ),
          ListTile(
            title: const Text('Search V2',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.black
              ),
            ),
            minLeadingWidth: 20.0,
            leading: const Icon(Icons.search),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchV2()),
              );
            },
          ),
        ],
      ),
    );
  }
}