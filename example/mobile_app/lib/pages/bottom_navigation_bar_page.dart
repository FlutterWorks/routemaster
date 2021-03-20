import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:routemaster/routemaster.dart';

class BottomNavigationBarPage extends StatefulWidget {
  @override
  _BottomNavigationBarPageState createState() =>
      _BottomNavigationBarPageState();
}

class _BottomNavigationBarPageState extends State<BottomNavigationBarPage> {
  @override
  Widget build(BuildContext context) {
    final pageState = IndexedPage.of(context);
    final selectedIndex = pageState.index;
    final stack = pageState.stacks[selectedIndex];
    final pages = stack.createPages();

    return Scaffold(
      appBar: AppBar(title: const Text('Bottom Navigation Bar')),
      body: Navigator(
        key: ValueKey(selectedIndex),
        onPopPage: stack.onPopPage,
        pages: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            pageState.index = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.ac_unit),
            label: 'One',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explicit),
            label: 'Two',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm),
            label: 'Three',
          ),
        ],
      ),
    );
  }
}

class BottomContentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Bottom bar page 1'),
            ElevatedButton(
              // TODO: Is this confusing?
              // It feels like we should be able to use .pushNamed for
              // Android-style navigation where we don't push into the tab
              // navigator. Not sure there's a good solution to this.
              onPressed: () => Routemaster.of(context)
                  .push('/bottom-navigation-bar/sub-page'),
              child: Text('Push page Android-style'),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomContentPage2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Bottom bar page 2'),
            ElevatedButton(
              onPressed: () => Routemaster.of(context)
                  .push('/bottom-navigation-bar/sub-page'),
              child: Text('Page 2: push page'),
            ),
          ],
        ),
      ),
    );
  }
}
