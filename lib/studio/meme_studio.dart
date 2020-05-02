import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker_saver/image_picker_saver.dart';
import 'package:meme_studio/studio/viewer.dart';
import 'gallery_json.dart';
import 'editor.dart';

class MemeStudio extends StatefulWidget {
  final Color mainColor;
  final Color secondaryColor;
  final Color bodyColor;
  final String title;
  final TextStyle headerTextStyle;
  final TextStyle titleTextStyle;
  final TextStyle subTitleTextStyle;
  final TextStyle bodyTextStyle;

  MemeStudio({
    @required this.title,
    this.mainColor = Colors.lightBlue,
    this.secondaryColor = Colors.pink,
    this.bodyColor = Colors.white,
    this.titleTextStyle,
    this.subTitleTextStyle,
    this.headerTextStyle,
    this.bodyTextStyle,
  });

  @override
  _MemeStudioState createState() => _MemeStudioState();
}

class _MemeStudioState extends State<MemeStudio> {
  bool exists;
  Color mainColor;
  Color secondaryColor;
  Color bodyColor;
  String title;
  TextStyle headerTextStyle;
  TextStyle titleTextStyle;
  TextStyle subTitleTextStyle;
  TextStyle bodyTextStyle;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    exists = false;
    mainColor = widget.mainColor;
    secondaryColor = widget.secondaryColor;
    bodyColor = widget.bodyColor;
    title = widget.title;
    headerTextStyle = widget.headerTextStyle;
    titleTextStyle = widget.titleTextStyle;
    subTitleTextStyle = widget.subTitleTextStyle;
    bodyTextStyle = widget.bodyTextStyle;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: widget.titleTextStyle,
        ),
        backgroundColor: mainColor,
        actions: [
          Builder(
            builder: (context) => IconButton(
              onPressed: () async {
                /*File picker = await ImagePickerSaver.pickImage(source: ImageSource.gallery);
                if (picker != null) {
                  insertPicture(picker.path).whenComplete(() {
                    setState(() {
                      print("set state");
                    });
                  });
                }
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Pictures added",
                    ),
                  ),
                );*/
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Editor()));
              },
              icon: Icon(
                Icons.add,
                color: secondaryColor,
              ),
              tooltip: "Add Pictures",
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getPictures(),
        builder: (context, snap) {
          if ((snap.connectionState == ConnectionState.waiting) ||
              (snap.connectionState == ConnectionState.active)) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(mainColor),
              ),
            );
          } else if (snap.connectionState == ConnectionState.done) {
            if (snap.hasData) {
              if (snap.data.length == 0) {
                exists = false;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "No Memes are found.",
                      textAlign: TextAlign.center,
                      style: bodyTextStyle,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: FlatButton(
                        onPressed: () async {
                          File picker = await ImagePickerSaver.pickImage(
                              source: ImageSource.gallery);
                          if (picker != null) {
                            insertPictureSec(picker.path).whenComplete(() {
                              setState(() {
                                print("set state");
                              });
                            });
                          }
                        },
                        color: secondaryColor,
                        padding: EdgeInsets.all(5),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Text(
                          'Make a Meme',
                          style: bodyTextStyle,
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                exists = true;
                return GridView.count(
                  crossAxisCount: 3,
                  children: List.generate(
                    snap.data.length,
                    (index) {
                      return Padding(
                        padding: EdgeInsets.all(3.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(3)),
                          child: GestureDetector(
                            onLongPress: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  actions: [
                                    FlatButton(
                                      onPressed: () {
                                        deletePicture(
                                          snap.data[index]['path'],
                                        ).whenComplete(() {
                                          setState(() =>
                                              Navigator.of(context).pop());
                                        });
                                      },
                                      child: Text(
                                        'Delete',
                                        style: subTitleTextStyle,
                                      ),
                                    ),
                                    FlatButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: Text(
                                        'Cancel',
                                        style: subTitleTextStyle,
                                      ),
                                    ),
                                  ],
                                  title: Text(
                                    'Delete',
                                    style: headerTextStyle,
                                  ),
                                  content: Text(
                                    'Delete this Meme form recent menu?',
                                    style: bodyTextStyle,
                                  ),
                                ),
                              );
                            },
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ImageViewer(
                                    picture: snap.data[index]['path'],
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              color: Colors.black,
                              child: Hero(
                                tag: snap.data[index],
                                child: Image.memory(
                                  base64Decode(snap.data[index]['thumb']),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
            } else {
              print(snap.error);
              return Center(
                  child: Text(
                "error:\n${snap.error}",
                style: TextStyle(color: Colors.white),
              ));
            }
          }
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(mainColor),
            ),
          );
        },
      ),
    );
  }
}
