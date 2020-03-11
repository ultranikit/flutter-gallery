import 'package:flutter/material.dart';
import 'gallery-source.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GalleryList(title: 'Gallery'),
    );
  }
}

class GalleryList extends StatefulWidget {
  GalleryList({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _GalleryListState createState() => _GalleryListState();
}

class _GalleryListState extends State<GalleryList> {
  List<Picture> images = List();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

// async function to get data
  Future getPics() async {
    // url using constant apiKey from gallery-source.dart
    String url = 'https://api.unsplash.com/photos/?client_id=$apiKey';
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      // will create Picture with parameters username, picture name, picture link ) from data
      // push it to images list
      for (var item in jsonData) {
        Picture picture = Picture(
            item['user']['username'],
            item['alt_description'],
            item['urls']['raw']
        );
        images.add(picture);
      }

      setState(() {
        return images;
      });
    } else {
      throw Exception('Failed to load images');
    }
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _refreshIndicatorKey.currentState?.show();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.blue,
            title: Text(
              widget.title,
              style: TextStyle(color: Colors.white),
            )),
        body: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: getPics,
          child: ListView.builder(
              itemCount: images.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  // for tapping on one card add InkWell
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) =>
                                  DetailPicture(images[index])
                          ));
                    },
                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: <Widget>[
                          Image.network(
                              images[index].image, // image link
                              fit: BoxFit.fitWidth, width: 600, height: 300),
                          Padding(padding: EdgeInsets.only(top: 20.0)),
                          Text(
                            images[index].imageName, // name of image
                            style: TextStyle(
                                fontSize: 14.0, fontWeight: FontWeight.normal),
                          ),
                          Padding(padding: EdgeInsets.only(bottom: 20.0)),
                          Align(
                            alignment: Alignment.bottomLeft, // align left-bottom for user name
                            child: Text(
                              images[index].username, // user name
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
        ));
  }
}

class DetailPicture extends StatelessWidget {
  final Picture picture;

  DetailPicture(this.picture);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text(picture.imageName)),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(picture.image),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class Picture {
  final String username;
  final String imageName;
  final String image;

  Picture(this.username, this.imageName, this.image);
}
