import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageViewer extends StatelessWidget {
  final String picture;
  ImageViewer({@required this.picture});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        /*actions: [
          IconButton(
            icon: Icon(
              Icons.delete,
              color: Colors.lime,
            ),
            onPressed: () => deletePicture(picture),
          )
        ],*/
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Hero(
          tag: picture,
          child: PhotoView.customChild(
            maxScale: 5.0,
            minScale: 1.0,
            child: Image.file(
              File(picture),
            ),
          ),
        ),
      ),
    );
  }
}