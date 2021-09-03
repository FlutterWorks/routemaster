import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';
import 'package:routemaster/src/trie_router/trie_router.dart';

import 'helpers.dart';

void main() {
  test('Can get relative routes', () {
    final relativeMap = RelativeRouteMap(routes: {
      'one': (_) => const MaterialPageOne(),
      'one/two': (_) => const MaterialPageTwo(),
      'one/two/three': (_) => const MaterialPageThree(),
    });

    final result = relativeMap.getAll(
      path: 'one/two/three',
      parent: RouterResult(
        builder: (_) => const MaterialPageOne(),
        pathParameters: {},
        pathSegment: '/parent',
        pathTemplate: '/parent',
        basePath: '/parent',
      ),
    );
    expect(result!.length, 3);
  });

  test('Can get relative routes 2 times', () {
    final relativeMap = RelativeRouteMap(routes: {
      'one': (_) => const MaterialPageOne(),
      'one/two': (_) => const MaterialPageTwo(),
      'one/two/three': (_) => const MaterialPageThree(),
    });

    final result = relativeMap.getAll(
      path: 'one/two/three/one/two/three',
      parent: RouterResult(
        builder: (_) => const MaterialPageOne(),
        pathParameters: {},
        pathSegment: '/base',
        pathTemplate: '/base',
        basePath: '/base',
      ),
    );
    expect(result!.length, 6);

    expect(result[0].pathSegment, '/base/one');
    expect(result[0].pathTemplate, '/base/one');
    expect(result[1].pathSegment, '/base/one/two');
    expect(result[1].pathTemplate, '/base/one/two');
    expect(result[2].pathSegment, '/base/one/two/three');
    expect(result[2].pathTemplate, '/base/one/two/three');
    expect(result[3].pathSegment, '/base/one/two/three/one');
    expect(result[3].pathTemplate, '/base/one/two/three/one');
    expect(result[4].pathSegment, '/base/one/two/three/one/two');
    expect(result[4].pathTemplate, '/base/one/two/three/one/two');
    expect(result[5].pathSegment, '/base/one/two/three/one/two/three');
    expect(result[5].pathTemplate, '/base/one/two/three/one/two/three');
  });

  test('Can get relative routes 3 times', () {
    final relativeMap = RelativeRouteMap(routes: {
      'one': (_) => const MaterialPageOne(),
      'one/two': (_) => const MaterialPageTwo(),
      'one/two/three': (_) => const MaterialPageThree(),
    });

    final result = relativeMap.getAll(
      path: 'one/two/three/one/two/three/one/two/three',
      parent: RouterResult(
        builder: (_) => const MaterialPageOne(),
        pathParameters: {},
        pathSegment: '/base',
        pathTemplate: '/base',
        basePath: '/base',
      ),
    );
    expect(result!.length, 9);

    expect(result[0].pathSegment, '/base/one');
    expect(result[1].pathSegment, '/base/one/two');
    expect(result[2].pathSegment, '/base/one/two/three');
    expect(result[3].pathSegment, '/base/one/two/three/one');
    expect(result[4].pathSegment, '/base/one/two/three/one/two');
    expect(result[5].pathSegment, '/base/one/two/three/one/two/three');
    expect(result[6].pathSegment, '/base/one/two/three/one/two/three/one');
    expect(result[7].pathSegment, '/base/one/two/three/one/two/three/one/two');
    expect(
      result[8].pathSegment,
      '/base/one/two/three/one/two/three/one/two/three',
    );
  });

  test('Can get relative routes without parent path', () {
    final relativeMap = RelativeRouteMap(routes: {
      'one': (_) => const MaterialPageOne(),
      'one/two': (_) => const MaterialPageTwo(),
      'one/two/three': (_) => const MaterialPageThree(),
    });

    final result = relativeMap.getAll(
      path: 'one/two/three',
      parent: null,
    );
    expect(result!.length, 3);
  });

  test('Base path works', () {
    final relativeMap = RelativeRouteMap(
      routes: {'one': (_) => const MaterialPageTwo()},
    );

    final result = relativeMap.getAll(
      path: 'one',
      parent: RouterResult(
        builder: (_) => const MaterialPageOne(),
        basePath: '/tabs',
        pathSegment: '/tabs/one',
        pathTemplate: '/tabs/',
        pathParameters: const {},
        unmatchedPath: 'one',
      ),
    );

    // /tabs/two/two
    expect(result!.single.pathSegment, '/tabs/one');
  });

  test('Can get relative routes without parent path with initial slash', () {
    final relativeMap = RelativeRouteMap(routes: {
      'one': (_) => const MaterialPageOne(),
      'one/two': (_) => const MaterialPageTwo(),
      'one/two/three': (_) => const MaterialPageThree(),
    });

    final result = relativeMap.getAll(
      path: '/one/two/three',
      parent: null,
    );
    expect(result!.length, 3);
  });

  testWidgets('Can combine wildcards and relative routes', (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => const MaterialPageOne(),
          '/feed': (_) => const MaterialPageOne(),
          '/*': (_) {
            return RelativeRouteMap(
              routes: {
                'one': (_) => const MaterialPageOne(),
                'one/two': (_) => const MaterialPageTwo(),
                'one/two/three': (_) => const MaterialPageThree(),
              },
            );
          },
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    delegate.push('/one/two');
    await tester.pump();
    await tester.pumpPageTransition();

    expect(find.byType(PageTwo), findsOneWidget);

    expect(
      delegate.currentConfiguration!.fullPath,
      '/one/two',
    );

    expect(
      delegate.currentConfiguration!.pathTemplate,
      '/one/two',
    );
  });

  testWidgets(
      'Can combine wildcards, path parameters, relative routes and query string',
      (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => const MaterialPageOne(),
          '/:id1/*': (_) {
            return RelativeRouteMap(
              routes: {
                'one': (_) => const MaterialPageOne(),
                'one/:id2': (_) => const MaterialPageTwo(),
                'one/:id2/three': (_) => const MaterialPageThree(),
              },
            );
          },
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    delegate.push('/myId1/one/myId2/three?query=string');
    await tester.pump();
    await tester.pumpPageTransition();
    expect(find.byType(PageThree), findsOneWidget);

    final route = delegate.currentConfiguration!;
    expect(route.fullPath, '/myId1/one/myId2/three?query=string');
    expect(route.path, '/myId1/one/myId2/three');
    expect(
      delegate.currentConfiguration!.pathTemplate,
      '/:id1/one/:id2/three',
    );
    expect(
      delegate.currentConfiguration!.pathParameters,
      {'id1': 'myId1', 'id2': 'myId2'},
    );
    expect(
      delegate.currentConfiguration!.queryParameters,
      {'query': 'string'},
    );
  });

  testWidgets(
      'Can combine wildcards, path parameters, recursive relative routes and query string',
      (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => const MaterialPageOne(),
          '/:id1/*': (_) {
            return RelativeRouteMap(
              routes: {
                'one': (_) => const MaterialPageOne(),
                'one/:id2': (_) => const MaterialPageTwo(),
                'one/:id2/three': (_) => const MaterialPageThree(),
              },
            );
          },
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    delegate.push('/myId1/one/myId2/three/one/myId3/three?query=string');
    await tester.pump();
    await tester.pumpPageTransition();
    expect(find.byType(PageThree), findsOneWidget);

    final route = delegate.currentConfiguration!;
    expect(
        route.fullPath, '/myId1/one/myId2/three/one/myId3/three?query=string');
    expect(route.path, '/myId1/one/myId2/three/one/myId3/three');
    expect(
      delegate.currentConfiguration!.pathTemplate,
      '/:id1/one/:id2/three/one/:id2/three',
    );
    expect(
      delegate.currentConfiguration!.pathParameters,
      {'id1': 'myId1', 'id2': 'myId3'},
    );
    expect(
      delegate.currentConfiguration!.queryParameters,
      {'query': 'string'},
    );
  });

  testWidgets('Can combine root wildcard and relative routes', (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => const MaterialPageOne(),
          '/*': (_) {
            return RelativeRouteMap(
              routes: {
                'one': (_) => const MaterialPageOne(),
                'one/two': (_) => const MaterialPageTwo(),
                'one/two/three': (_) => const MaterialPageThree(),
              },
            );
          },
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    delegate.push('/one/two/three');
    await tester.pump();
    await tester.pumpPageTransition();

    expect(find.byType(PageThree), findsOneWidget);
  });

  testWidgets('Can combine root wildcard and relative routes with route param',
      (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => const MaterialPageOne(),
          '/*': (_) {
            return RelativeRouteMap(
              routes: {
                'one': (_) => const MaterialPageOne(),
                'one/:id': (_) => const MaterialPageTwo(),
                'one/:id/three': (_) => const MaterialPageThree(),
              },
            );
          },
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    delegate.push('/one/myId/three');
    await tester.pump();
    await tester.pumpPageTransition();

    expect(find.byType(PageThree), findsOneWidget);

    expect(delegate.currentConfiguration!.pathParameters, {'id': 'myId'});
  });

  testWidgets('Can combine non-root wildcard and relative routes',
      (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/section/*': (_) {
            return RelativeRouteMap(
              routes: {
                'one': (_) => const MaterialPageOne(),
                'one/two': (_) => const MaterialPageTwo(),
                'one/two/three': (_) => const MaterialPageThree(),
              },
            );
          },
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    delegate.push('/section/one/two/three');
    await tester.pump();
    await tester.pumpPageTransition();

    expect(find.byType(PageThree), findsOneWidget);

    final route = delegate.currentConfiguration!;
    expect(route.fullPath, '/section/one/two/three');
    expect(route.path, '/section/one/two/three');
    expect(route.publicPath, '/section/one/two/three');
    expect(route.pathTemplate, '/section/one/two/three');
  });

  testWidgets(
      'Can combine root wildcard and relative routes with two route params',
      (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => const MaterialPageOne(),
          '/:id1/*': (_) {
            return RelativeRouteMap(
              routes: {
                'one': (_) => const MaterialPageOne(),
                'one/:id2': (_) => const MaterialPageTwo(),
                'one/:id2/three': (_) => const MaterialPageThree(),
              },
            );
          },
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    delegate.push('/myId1/one/myId2/three');
    await tester.pump();
    await tester.pumpPageTransition();

    expect(find.byType(PageThree), findsOneWidget);

    expect(
      delegate.currentConfiguration!.pathParameters,
      {'id1': 'myId1', 'id2': 'myId2'},
    );
  });

  testWidgets('Can combine unknown route with relative routes', (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => const MaterialPageOne(),
        },
        onUnknownRoute: (route) {
          return RelativeRouteMap(
            routes: {
              'one': (_) => const MaterialPageOne(),
              'one/two': (_) => const MaterialPageTwo(),
              'one/two/three': (_) => const MaterialPageThree(),
            },
          );
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    delegate.push('/one/two');
  });

  testWidgets('Can combine tabs with relative routes', (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => MaterialPage<void>(child: Container()),
          '/tabs': (_) =>
              TabPage(child: MyTabPage(), paths: const ['one', 'two']),
          '/tabs/one': (_) => const MaterialPageOne(),
          '/tabs/*': (_) {
            return RelativeRouteMap(
              routes: {'two': (_) => const MaterialPageTwo()},
            );
          },
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );
    delegate.push('/tabs/two');
    await tester.pump();
    await tester.pumpPageTransition();

    expect(find.byType(PageTwo), findsOneWidget);

    final route = delegate.currentConfiguration!;
    expect(route.fullPath, '/tabs/two');
    expect(route.path, '/tabs/two');
    expect(route.publicPath, '/tabs/two');
    expect(route.pathTemplate, '/tabs/two');
  });

  testWidgets('Can combine relative routes with tabs with default tab route',
      (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => MaterialPage<void>(child: Container()),
          '/tabs': (_) =>
              TabPage(child: MyTabPage(), paths: const ['one', 'two']),
          '/tabs/*': (_) {
            return RelativeRouteMap(
              routes: {'one': (_) => const MaterialPageOne()},
            );
          },
          '/tabs/two': (_) => const MaterialPageTwo(),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );
    delegate.push('/tabs');
    await tester.pump();
    await tester.pumpPageTransition();

    expect(find.byType(PageOne), findsOneWidget);

    final route = delegate.currentConfiguration!;
    expect(route.fullPath, '/tabs/one');
    expect(route.path, '/tabs/one');
    expect(route.publicPath, '/tabs/one');
    expect(route.pathTemplate, '/tabs/one');
  });

  // TODO: Fix
  // testWidgets(
  //     'Can combine relative routes with tabs with default tab route and query string',
  //     (tester) async {
  //   final delegate = RoutemasterDelegate(
  //     routesBuilder: (_) => RouteMap(
  //       routes: {
  //         '/': (_) => MaterialPage<void>(child: Container()),
  //         '/tabs': (_) =>
  //             TabPage(child: MyTabPage(), paths: const ['one', 'two']),
  //         '/tabs/*': (_) {
  //           return RelativeRouteMap(
  //             routes: {'one': (_) => const MaterialPageOne()},
  //           );
  //         },
  //         '/tabs/two': (_) => const MaterialPageTwo(),
  //       },
  //     ),
  //   );

  //   await tester.pumpWidget(
  //     MaterialApp.router(
  //       routeInformationParser: const RoutemasterParser(),
  //       routerDelegate: delegate,
  //     ),
  //   );
  //   delegate.push('/tabs?query=string');
  //   await tester.pump();
  //   await tester.pumpPageTransition();

  //   expect(find.byType(PageOne), findsOneWidget);

  //   final route = delegate.currentConfiguration!;
  //   expect(route.fullPath, '/tabs/one');
  //   expect(route.path, '/tabs/one');
  //   expect(route.publicPath, '/tabs/one');
  //   expect(route.pathTemplate, '/tabs/one');
  //   expect(route.queryParameters, {'query': 'string'});
  // });
}

class MyTabPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tabPage = TabPage.of(context);
    final stack = tabPage.stacks[tabPage.index];

    return Container(
      height: 300,
      child: PageStackNavigator(stack: stack),
    );
  }
}
