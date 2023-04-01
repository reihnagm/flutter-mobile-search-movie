import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_search/models/movie.dart';
import 'package:flutter_search/utils/constant.dart';

class SearchV2 extends StatelessWidget {
  const SearchV2({Key? key, 
  }) : super(key: key);

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
              showSearch(context: context, delegate: EventSearch(     
                context: context
              ));
            }, 
            icon: const Icon(
              Icons.search,
              color: Colors.black,
            )
          )
          // GestureDetector(
          //   onTap: () {
          //     showSearch(context: context, delegate: EventSearch(
          //       context: context
          //     ));
          //   },
          //   child: Container(
          //     margin: const EdgeInsets.only(left: 16.0, right: 16.0),
          //     child: Row(
          //       children: const [
          //         Icon(
          //           Icons.search,
          //           size: 20.0,
          //           color: Colors.white,
          //         ),
          //       ],
          //     ) 
          //   ),
          // )
        ],
      ),
    );
    
  }
}

class EventSearch extends SearchDelegate {
  final BuildContext? context;
  EventSearch({
    this.context
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
  List<Widget> buildActions(BuildContext context) => [
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

  @override
  Widget buildLeading(BuildContext context) =>  IconButton(
    icon: const Icon(Icons.arrow_back), 
    onPressed: () {
      Navigator.of(context).pop();
    }
  );
  
  @override
  Widget buildResults(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.movie,
          size: 120.0,
        ),
        const SizedBox(height: 48.0),
        Text(query)
      ],
    ),
  );
  
  @override
  Widget buildSuggestions(BuildContext context) {

    Future<List<Result>> getData(BuildContext context, String query) async {
      Dio dio = Dio();
      Response res = await dio.get("${AppConstants.baseUrl}?api_key=${AppConstants.movieKey}&query=$query");
      Map<String, dynamic> data = res.data;
      MovieDbModel movieDbModel = MovieDbModel.fromJson(data);
      List<Result> movieDBResult = movieDbModel.results!;
      return movieDBResult;
    }

    return query.isEmpty 
    ? Container() 
    : FutureBuilder<List<Result>>(
      future: getData(context, query),
      builder: (BuildContext context, AsyncSnapshot<List<Result>> snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        }

        List<Result> data = snapshot.data!;

        List<Result> suggestions = query.isEmpty 
        ? [] 
        : data.where((event) {
          final descLower = event.title!.toLowerCase();
          final queryLower = query.toLowerCase();
          return descLower.contains(queryLower);
        }).toList();

        return suggestions.isEmpty 
        ? Center(
            child: Container()
          ) 
        : ListView.builder(
            itemCount: suggestions.length,
            itemBuilder: (BuildContext context, int i) {
            final suggestion = suggestions[i];
            return ListTile(
              dense: true,
              onTap: () {
                
              },
              visualDensity: const VisualDensity(
                vertical: 4.0,
                horizontal: 0.0
              ),
              title: Text(suggestion.title!,
                style: const TextStyle(
                  fontSize: 15.0,
                  color: Colors.black
                ),
              ),
            );
          },
        ); 
      }
    );
  }
  
}