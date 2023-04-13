import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';


class ImageCarousel extends StatefulWidget {
  final List<CarouselItem> items;

  ImageCarousel({required this.items});

  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        CarouselSlider.builder(
          itemCount: widget.items.length,
          itemBuilder: (BuildContext context, int index, int realIndex) {
            final item = widget.items[index];
            return Stack(
              children: [
                Image.network(
                  item.imageUrl,
                  fit: BoxFit.fill,
                ),
                // Filtre couleur fond transparent pour mieux voir les textes
                /*Container(
                  color: Color(0xFF1A2025).withOpacity(0.5),
                ),*/
                Positioned(
                  left: 20,
                  bottom: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        item.description,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Color(0xFF636AF6)),
                        ),
                        onPressed: () {
                          // Action when button is pressed
                        },
                        child: Text(
                          item.buttonText,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          options: CarouselOptions(
            height: 190,
            viewportFraction: 1,
            aspectRatio: 16/9,
            initialPage: _currentIndex,
            enableInfiniteScroll: true,
            enlargeCenterPage: true,
            autoPlay: true,
            autoPlayInterval: Duration(seconds: 7),
           /* onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },*/
          ),
        ),
        SizedBox(height: 10),

      ],
    );
  }
}

class CarouselItem {
  final String imageUrl;
  final String title;
  final String description;
  final String buttonText;

  CarouselItem({
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.buttonText,
  });
}



