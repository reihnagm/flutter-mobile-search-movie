import 'package:dio/dio.dart' as d;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_search/basewidgets/loader/shimmer_ver1.dart';
import 'package:flutter_search/models/movie.dart';
import 'package:flutter_search/utils/constant.dart';
import 'package:get/get.dart';

enum Loading { idle, loading, loaded, error }

class SearchV2Controller extends GetxController {

  Rx<Loading> loading = Loading.idle.obs;

  RxList<Result> movies = <Result>[].obs;
  RxList<Result> suggestions = <Result>[].obs;

  Future<List<Result>> getData(BuildContext context, String query) async {
    setStateLoading(Loading.loading.obs);
    try {
      d.Dio dio = d.Dio();
      d.Response res = await dio.get("${AppConstants.baseUrl}?api_key=${AppConstants.movieKey}&query=$query");
      Map<String, dynamic> data = res.data;
      MovieDbModel movieDbModel = MovieDbModel.fromJson(data);
      List<Result> movieDBResult = movieDbModel.results!;
      movies.value = [];
      movies.addAll(movieDBResult);
      setStateLoading(Loading.loaded.obs);
      return movieDBResult;
    } on d.DioError catch(e) {
      debugPrint(e.toString());
      debugPrint(e.response!.statusCode.toString());
      debugPrint(e.response!.statusMessage.toString());
      setStateLoading(Loading.error.obs);
    } catch(e, stacktrace) {
      debugPrint(e.toString());
      debugPrint(stacktrace.toString());
      setStateLoading(Loading.error.obs);
    }
    return [];
  }

  void setStateLoading(Rx<Loading> loadingParam) {
    loading.value = loadingParam.value;
  }

  void assignSuggestions(Result result) {
    suggestions.add(Result(
      adult: result.adult,
      backdropPath: result.backdropPath,
      genreIds: result.genreIds,
      id: result.id,
      originalLanguage: result.originalLanguage,
      originalTitle: result.originalTitle,
      overview: result.overview,
      popularity: result.popularity,
      posterPath: result.posterPath,
      releaseDate: result.releaseDate,
      title: result.title, 
      video: result.video,
      voteAverage: result.voteAverage,
      voteCount: result.voteCount
    ));
  }

  void removeSuggestions(int id) {
    suggestions.removeWhere((el) => el.id == id);
  }
}

class SearchV2 extends StatefulWidget {
  const SearchV2({
    Key? key, 
  }) : super(key: key);

  @override
  State<SearchV2> createState() => _SearchV2State();
}

class _SearchV2State extends State<SearchV2> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        title: const Text("Search V2",
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontWeight: FontWeight.w600
          ),
        ),
        leading: CupertinoNavigationBarBackButton(
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            splashRadius: 20.0,
            onPressed: () {
              showSearch(context: context, 
                delegate: MovieSearch(
                  f: setState
                )
              );
            }, 
            icon: const Icon(
              Icons.search,
              color: Colors.black,
            )
          )
        ],
      ),
    );
    
  }
}

class MovieSearch extends SearchDelegate {
  Function f;

  MovieSearch({
    required this.f
  });

  @override
  String get searchFieldLabel => "Search Movie";

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(
          color: Colors.black,
          fontSize: 16.0
        ),

        border: InputBorder.none,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.black,
      ), 
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          color: Colors.black,
          fontSize: 16.0,
        ),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0.0,
        iconTheme: IconThemeData(
          color: Colors.black
        ),
        backgroundColor: Colors.white,
      )
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear), 
        onPressed: () {
          if(query.isEmpty) {
            close(context, null);
          } else {
            query = '';
          }
        }
      )
    ];
  } 

  @override
  Widget buildLeading(BuildContext context) {
    return CupertinoNavigationBarBackButton(
      color: Colors.black,
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  } 
  
  @override
  Widget buildResults(BuildContext context) {
    return buildMatchingSuggestions(context);
  }
  
  @override
  Widget buildSuggestions(BuildContext context) {
    return buildMatchingSuggestions(context);
  }

  Widget buildMatchingSuggestions(BuildContext context) {
   
    SearchV2Controller c = Get.put(SearchV2Controller());

    if(query.isNotEmpty) {
      c.getData(context, query);
    }

    List<Result> data = query.isEmpty 
    ? [] 
    : c.movies.where((event) {
      final descLower = event.title!.toLowerCase();
      final queryLower = query.toLowerCase();
      return descLower.contains(queryLower);
    }).toList();

    return Obx(() {
      if(c.loading.value == Loading.idle) {
        return Container();
      } 
      if(c.loading.value == Loading.loading) {
        return const ShimmerVer1(count: 10);
      } 
      if(c.loading.value == Loading.loaded) {
        return query.isNotEmpty 
        ? data.isEmpty 
          ? const Center(
              child: Text("Data not found",
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.black
                ),
              )
            )
          : ListView.builder(
              itemCount: data.length,
              itemBuilder: (BuildContext context, int i) {
              final item = data[i];
              return ListTile(
                dense: true,
                onTap: () {
                  c.assignSuggestions(item);
                },
                visualDensity: const VisualDensity(
                  vertical: 4.0,
                  horizontal: 0.0
                ),
                title: Text(item.title!,
                  style: const TextStyle(
                    fontSize: 15.0,
                    color: Colors.black
                  ),
                ),
              );
            },
          ) 
        : c.suggestions.isNotEmpty 
        ? ListView.builder(
            itemCount: c.suggestions.take(3).length,
            itemBuilder: (BuildContext context, int i) {
              final item = c.suggestions[i];
              return ListTile(
                dense: true,
                onTap: () {
       
                },
                trailing: IconButton(
                  splashRadius: 20.0,
                  onPressed: () {
                    c.removeSuggestions(item.id!);
                  }, 
                  icon: const Icon(
                    Icons.clear,
                  ) 
                ),
                visualDensity: const VisualDensity(
                  vertical: 4.0,
                  horizontal: 0.0
                ),
                title: Text(item.title!,
                  style: const TextStyle(
                    fontSize: 15.0,
                    color: Colors.black
                  ),
                ),
              );
            },
          ) 
        : Container();
      }
      return Container();
    });
  }
  
}