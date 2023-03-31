import 'dart:async';

import 'package:flutter_search/basewidgets/loader/shimmer_ver1.dart';
import 'package:shimmer/shimmer.dart';

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
    return const MaterialApp(
      title: 'Search Movie',
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
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
  late TextEditingController searchC;

  List<Result> results = [];
  
  Timer? debounce;

  Future<void> getData(BuildContext context) async {
    try {
      Dio dio = Dio();
      Response res = await dio.get("${AppConstants.baseUrl}?api_key=${AppConstants.movieKey}&query=${searchC.text}");
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
    } catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
      setState(() => isLoading = false);
    }
  }

  void onChange() {
    if(searchC.text.isNotEmpty) {
      setState(() => isLoading = true);

      if (debounce?.isActive ?? false) debounce!.cancel();
      debounce = Timer(const Duration(milliseconds: 1000), () async {
        await getData(context);
        setState(() => isLoading = false);
      });
    }
  }

  @override
  void initState() {
    super.initState();

    searchC = TextEditingController();
    searchC.addListener(onChange);
    
    isLoading = true;

    Future.delayed(Duration.zero, () async {
      await getData(context);
    });
  }

  @override 
  void dispose() {
    super.dispose();

    searchC.removeListener(onChange);
    searchC.dispose();
    debounce!.cancel();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: globalKey,
      backgroundColor: const Color(0xffF8F8FF),
      resizeToAvoidBottomInset: false,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [

          const SliverAppBar(
            backgroundColor: Colors.white,
            title: Text("Search Movie",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.0,
                fontWeight: FontWeight.w600
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
                controller: searchC,
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
          ? const SliverToBoxAdapter(
              child: ShimmerVer1(count: 10)
            )
          : results.isEmpty 
          ?  const SliverFillRemaining(
              child: Center(
                child: Text("Data not found",
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black
                  ),
                )
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
                          12.0
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
                              imageUrl: "${AppConstants.baseUrlImg}/${results[i].posterPath}",
                              imageBuilder: (BuildContext context, ImageProvider<Object> imageProvider) {
                                return Container(
                                  width: 150.0,
                                  height: 150.0,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      alignment: Alignment.centerLeft,
                                      fit: BoxFit.fitHeight,
                                      image: imageProvider
                                    )
                                  ),
                                );
                              },
                              placeholder: (BuildContext context, String val) {
                                return const SizedBox(
                                  width: 16.0,
                                  height: 16.0,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                  ),
                                );
                              },
                              errorWidget: (BuildContext context, String val, dynamic data) {
                                return Image.asset("assets/images/default.png",
                                  fit: BoxFit.fitHeight,
                                  alignment: Alignment.centerLeft,
                                  width: 150.0,
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

}
