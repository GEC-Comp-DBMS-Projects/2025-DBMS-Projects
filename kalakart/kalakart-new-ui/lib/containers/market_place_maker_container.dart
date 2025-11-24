import 'package:flutter/material.dart';
import 'package:kart_app/containers/banner_container.dart';
import 'package:kart_app/containers/zone_container.dart';
import 'package:kart_app/controllers/db_service.dart';
import 'package:kart_app/models/categories_model.dart';
import 'package:kart_app/models/promo_banners_model.dart';
import 'package:shimmer/shimmer.dart';

class MarketPlaceMakerContainer extends StatefulWidget {
  const MarketPlaceMakerContainer({super.key});

  @override
  State<MarketPlaceMakerContainer> createState() =>
      _MarketPlaceMakerContainerState();
}

class _MarketPlaceMakerContainerState extends State<MarketPlaceMakerContainer> {
  int min = 0;

  minCalculator(int a, int b) {
    return min = a > b ? b : a;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: DbService().readCategories(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<CategoriesModel> categories =
              CategoriesModel.fromJsonList(snapshot.data!.docs)
                  as List<CategoriesModel>;
          if (categories.isEmpty) {
            return SizedBox();
          } else {
            return StreamBuilder(
              stream: DbService().readBanners(),
              builder: (context, bannerSnapshot) {
                if (bannerSnapshot.hasData) {
                  List<PromoBannersModel> banners =
                      PromoBannersModel.fromJsonList(snapshot.data!.docs)
                          as List<PromoBannersModel>;
                  if (banners.isEmpty) {
                    return SizedBox();
                  } else {
                    return Column(
                      children: [
                        for (int i = 0; i < snapshot.data!.docs.length; i++)
                          Column(
                            children: [
                              ZoneContainer(
                                category: snapshot.data!.docs[i]["name"],
                              ),
                            ],
                          ),
                      ],
                    );
                  }
                } else {
                  return SizedBox();
                }
              },
            );
          }
        } else {
          return Shimmer(
            child: Container(height: 400, width: double.infinity),
            gradient: LinearGradient(
              colors: [Colors.grey.shade200, Colors.white],
            ),
          );
        }
      },
    );
  }
}
