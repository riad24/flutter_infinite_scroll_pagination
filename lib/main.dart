import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:http/http.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
class Post {
  final String title;
  final String body;
  Post(this.title, this.body);


}
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  final _numberOfPostsPerRequest = 20;

  final PagingController<int, Post> pagingController =
  PagingController(firstPageKey: 0);

  void _incrementCounter() {

    setState(() {
      _counter++;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  @override
  void dispose() {
    pagingController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    print(pageKey);
    try {
      final response = await get(Uri.parse(
          "https://jsonplaceholder.typicode.com/posts?_page=$pageKey&_limit=$_numberOfPostsPerRequest"));
      List responseList = json.decode(response.body);
      List<Post> postList = responseList.map((data) =>
          Post(data['title'], data['body'])).toList();
      final isLastPage = postList.length < _numberOfPostsPerRequest;
      if (isLastPage) {
        pagingController.appendLastPage(postList);
      } else {
        final nextPageKey = pageKey + 1;
        pagingController.appendPage(postList, nextPageKey);
      }
    } catch (e) {
      print("error --> $e");
      pagingController.error = e;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(title: const Text("Blog App"), centerTitle: true,),
      body: RefreshIndicator(
        onRefresh: () => Future.sync(() => pagingController.refresh()),
        child: PagedListView<int, Post>(
          pagingController: pagingController,
          builderDelegate: PagedChildBuilderDelegate<Post>(
            itemBuilder: (context, item, index) =>
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: PostItem(
                      item.title, item.body
                  ),
                ),

          ),

        ),
      ),
    );
  }
}


class PostItem extends StatelessWidget {

  final String title;
  final String body;

  PostItem(this.title, this.body);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: 200,
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          color: Colors.amber
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(title,
              style: const TextStyle(
                  color: Colors.purple,
                  fontSize: 20,
                  fontWeight: FontWeight.bold
              ),),
            const SizedBox(height: 10,),
            Text(body,
              style: const TextStyle(
                  fontSize: 12
              ),)
          ],
        ),
      ),
    );
  }
}
