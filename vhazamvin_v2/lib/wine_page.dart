import 'package:flutter/material.dart';
import 'package:vhazamvin_v2/comment_page.dart';
import 'package:vhazamvin_v2/comments_list.dart';
import 'package:vhazamvin_v2/custom_widgets.dart';
import 'package:vhazamvin_v2/service.dart';

class Wine {
  late String id;
  late String name;
  late String domain;
  late String year;
  late List<CommentModel> comments;

  Wine();

  Wine.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    name = json['nom'];
    domain = json['domaine'];
    year = json['annee'];
    if (json['commentaires'] != null) {
      comments = <CommentModel>[];
      json['commentaires'].forEach((v) {
        comments.add(CommentModel(
            user: v['ident'],
            comment: v['commentaire'],
            note: v['note'],
            id: v['_id']));
      });
    }
  }
}

class WinePage extends StatefulWidget {
  var request;
  var thatWine;

  WinePage({Key? key, this.request, this.thatWine}) : super(key: key);

  @override
  _WinePageState createState() => _WinePageState();
}

class _WinePageState extends State<WinePage> {
  late Wine wine;

  @override
  void initState() {
    if (widget.thatWine == null) {
      wine = Wine.fromJson(widget.request);
    } else {
      wine = widget.thatWine;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerWine(),
      appBar: AppBarWine(),
      body: Container(
          color: Colors.deepPurple,
          child: Column(children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                wine.name,
                style:
                    const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
                child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              constraints: const BoxConstraints.expand(),
              decoration: const BoxDecoration(
                  color: Colors.blueGrey,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(35),
                      topRight: Radius.circular(35))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Domaine
                  const SizedBox(
                    height: 30,
                  ),
                  const Text(
                    "Domaine",
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(left: 5),
                    child: Text(wine.domain),
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                  ),
                  // Annee
                  const SizedBox(
                    height: 30,
                  ),
                  const Text(
                    "Année",
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(left: 5),
                    child: Text(wine.year),
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                        child: CommentsList(
                      comments: wine.comments,
                      idWine: wine.id,
                    )),
                  ),
                ],
              ),
            )),
          ])),
      floatingActionButton: Visibility(
          visible: Service().isConnected(),
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return CommentPage(wine: wine);
              }));
            },
            child: Icon(Icons.comment_rounded),
          )),
    );
  }
}
