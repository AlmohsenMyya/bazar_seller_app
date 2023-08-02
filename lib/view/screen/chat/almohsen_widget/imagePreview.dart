import 'package:flutter/material.dart';
class ImagePreview extends StatefulWidget {
  ImageProvider? imageProvider ;
  bool show ;
  final Function? onDelete;
   ImagePreview({Key? key, required this.show , this.onDelete ,this.imageProvider}) : super(key: key);

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  @override
  Widget build(BuildContext context) {
   if ( widget.show ) {return  Container(); }
   else { return Container(
     width: 50,
     height:
     50,
     decoration:
     BoxDecoration(
       image:
       DecorationImage(
         image: widget.imageProvider!
         ,
         fit: BoxFit
             .cover,
       ),
       borderRadius:
       BorderRadius.circular(4),
     ),
     child:
     IconButton(
       icon: const Icon(
           Icons
               .clear,
           color:
           Colors.red),
       onPressed:
           () {
             if (widget.onDelete != null) {
               widget.onDelete!();
             }
       },
     ),
   )  ;}

  }
}
