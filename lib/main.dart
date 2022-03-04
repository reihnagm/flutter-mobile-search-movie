import 'dart:async';

import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:flutter_search/models/movie.dart';
import 'package:flutter_search/utils/constant.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Search Moview',
      debugShowCheckedModeBanner: false,
      home: MyHomePage(key: UniqueKey()),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey<ScaffoldState> globalKey = GlobalKey<ScaffoldState>();

  late bool isLoading;
  late TextEditingController searchTextEditingController;

  List<Result> results = [];
  

  Timer? debounce;

  void textChange() {
    setState(() {
      isLoading = true;
    });
    if (debounce?.isActive ?? false) debounce!.cancel();
    debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    isLoading = true;
    searchTextEditingController = TextEditingController();
    searchTextEditingController.addListener(textChange);
  }

  @override 
  void dispose() {
    searchTextEditingController.removeListener(textChange);
    searchTextEditingController.dispose();
    super.dispose();
    debounce!.cancel();
  }

  @override
  Widget build(BuildContext context) {

    loadData(context);

    return Scaffold(
      key: globalKey,
      backgroundColor: const Color(0xffF8F8FF),
      resizeToAvoidBottomInset: false,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [

          const SliverAppBar(
            backgroundColor: Colors.white,
            title: Text("Search App",
              style: TextStyle(
                color: Colors.black,
                fontSize: 14.0,
                fontWeight: FontWeight.w400
              ),
            ),
            pinned: true,
            centerTitle: true,
            forceElevated: true,
            elevation: 0.0,
            automaticallyImplyLeading: false,
          ),

          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.only(
                top: 16.0,
                left: 16.0, 
                right: 16.0
              ),
              child: TextField(
                controller: searchTextEditingController,
                style: const TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400
                ),
                cursorColor: Colors.black,
                decoration: const InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  labelText: "Search Movie",
                  labelStyle: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                    fontWeight: FontWeight.w400
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(),
                  errorBorder: OutlineInputBorder(),
                ),
              ),
            ),
          ),


          isLoading 
          ? const SliverFillRemaining(
              child: Center(
                child: SizedBox(
                  width: 16.0,
                  height: 16.0,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                ),
              ),
            )
          : SliverPadding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
              sliver: SliverList(
              delegate: SliverChildListDelegate([
          
                Container(
                  margin: const EdgeInsets.only(
                    left: 16.0, 
                    right: 16.0,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: results.length,
                    itemBuilder: (BuildContext context, int i) {
                      return Container(
                        margin: const EdgeInsets.only(
                          top: 4.0, 
                          bottom: 8.0
                        ),
                        padding: const EdgeInsets.all(
                          8.0
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[200],
                          border: Border.all(
                            color: Colors.black
                          )
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CachedNetworkImage(
                              imageUrl: "https://image.tmdb.org/t/p/w500/${results[i].posterPath}",
                              fit: BoxFit.cover,
                              height: 150.0,
                              placeholder: (BuildContext context, String val) {
                                return const Center(
                                  child: SizedBox(
                                    width: 16.0,
                                    height: 16.0,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                    ),
                                  ),
                                );
                              },
                              errorWidget: (BuildContext context, String val, dynamic data) {
                                return Image.asset("assets/images/default.png",
                                  fit: BoxFit.cover,
                                  height: 150.0,
                                );
                              }
                            ),
                            const SizedBox(height: 8.0),
                            Text(results[i].title!,
                              style: const TextStyle(
                                fontSize: 16.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(results[i].overview!,
                              textAlign: TextAlign.justify,
                              style: const TextStyle(
                                fontSize: 14.0,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ) 
                      );
                    }
                  ),
                )
                
              ]),
            ),
          )

     

        ],
      ),
    );
  }

  Future<void> loadData(BuildContext context) async {
    try {
      Dio dio = Dio();
      Response res = await dio.get("https://api.themoviedb.org/3/search/movie?api_key=${AppConstants.movieKey}&query='${searchTextEditingController.text}'");
      Map<String, dynamic> data = res.data;
      MovieDbModel movieDbModel = MovieDbModel.fromJson(data);
      setState(() {
        results = [];
        results.addAll(movieDbModel.results!);
        isLoading = false;
      });
    } on DioError catch(e) {
      setState(() => isLoading = false);
      debugPrint(e.response!.statusCode.toString());
      debugPrint(e.response!.statusMessage.toString());
    } catch(e) {
      setState(() => isLoading = false);
      debugPrint(e.toString());
    }
  }

}
