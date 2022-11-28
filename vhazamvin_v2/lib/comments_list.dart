import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vhazamvin_v2/login.dart';
import 'package:vhazamvin_v2/service.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';
import 'package:http/http.dart' as http;

import 'wine_page.dart';

class CommentModel {
  String user = '';
  String comment = '';
  int note;
  String? id;

  CommentModel(
      {required this.user, required this.comment, required this.note, this.id});
}

class CommentsList extends StatelessWidget {
  List<CommentModel> comments;
  String idWine;
  CommentsList({Key? key, required this.comments, required this.idWine})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: ExpansionTile(
        leading: Icon(Icons.comment),
        trailing: Text(comments.length.toString()),
        title: Text("Commentaires"),
        children: <Widget>[
          Container(
              child: ListView.builder(
            shrinkWrap: true,
            controller: ScrollController(),
            scrollDirection: Axis.vertical,
            itemCount: comments.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                  padding: EdgeInsets.all(3),
                  child: Container(
                      padding: EdgeInsets.only(left: 5, right: 5),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SingleComment(
                        comment: comments[index],
                        idWine: idWine,
                      )));
            },
          )),
        ],
      ),
    );
  }
}

class SingleComment extends StatelessWidget {
  CommentModel comment;
  String idWine;
  SingleComment({Key? key, required this.comment, required this.idWine})
      : super(key: key);

  Future<ApiResponse> deleteComm(String id) async {
    ApiResponse _apiResponse = ApiResponse();
    var url = Uri.parse('http://192.168.19.47:3211/api/deletecomm');
    var token = Service().token;
    var response =
        await http.post(url, body: {'jwt': token, 'id': id, 'idWine': idWine});
    switch (response.statusCode) {
      case 200:
        var result = json.decode(response.body);
        _apiResponse.Data = result;
        break;
      case 400:
        _apiResponse.Data = 400;
        break;
      default:
        break;
    }
    return _apiResponse;
  }

  @override
  Widget build(BuildContext context) {
    if (Service().admin) {
      return GestureDetector(
        onLongPress: () {
          showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                    title: const Text('Suppression de commentaire'),
                    content: const Text(
                        'Etes vous sur de vouloir supprimer ce commentaire ?'),
                    actions: <Widget>[
                      TextButton(
                          onPressed: () async {
                            var result = await deleteComm(comment.id ?? "");
                            if (result.Data != 400) {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return WinePage(request: result.Data);
                              }));
                            } else if (result.Data == 400) {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      AlertDialog(
                                        title: const Text("error"),
                                        content: const Text(
                                            "vous n'avez pas le droit"),
                                        actions: <Widget>[
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text("OK"))
                                        ],
                                      ));
                            }
                          },
                          child: const Text("Oui")),
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Non")),
                    ],
                  ));
        },
        child: _SingleComment(
          comment: comment,
        ),
      );
    } else {
      return _SingleComment(comment: comment);
    }
  }
}

class _SingleComment extends StatelessWidget {
  CommentModel comment;
  _SingleComment({Key? key, required this.comment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(comment.user),
              SmoothStarRating(
                starCount: comment.note,

                /********** */
                // isReadOnly: true,

                /************* */
              )
            ],
          ),
          Text(comment.comment),
        ],
      ),
    );
  }
}
