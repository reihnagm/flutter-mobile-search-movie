import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerVer1 extends StatelessWidget {
  final int count;
  const ShimmerVer1({
    required this.count,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: count,
      itemBuilder: (BuildContext context, int i) {
        return Container(
          margin: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Shimmer.fromColors(
                      child: const CircleAvatar(
                        backgroundColor: Colors.white,
                        minRadius: 30.0,
                      ), 
                      baseColor: Colors.grey[200]!, 
                      highlightColor: Colors.grey[300]!
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        Shimmer.fromColors(
                          child: Container(
                            height: 14.0,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5.0)
                            ),
                          ), 
                          baseColor: Colors.grey[200]!, 
                          highlightColor: Colors.grey[300]!
                        ),
                        const SizedBox(height: 8.0),
                        Shimmer.fromColors(
                          child: Container(
                            height: 14.0,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5.0)
                            ),
                          ), 
                          baseColor: Colors.grey[200]!, 
                          highlightColor: Colors.grey[300]!
                        ),
                        const SizedBox(height: 8.0),
                        Shimmer.fromColors(
                          child: Container(
                            height: 14.0,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5.0)
                            ),
                          ), 
                          baseColor: Colors.grey[200]!, 
                          highlightColor: Colors.grey[300]!
                        ),
                      ],
                    ),
                  )
                ],
              ),

            ],
          ) 
        );
      },
    );
  }
}