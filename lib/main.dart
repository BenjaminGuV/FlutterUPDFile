import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: UploadImageDemo(),
    );
  }
}

class UploadImageDemo extends StatefulWidget {
  UploadImageDemo() : super();

  final String title = "Upload Image Demo";

  @override
  UploadImageDemoState createState() => UploadImageDemoState();
}

class UploadImageDemoState extends State<UploadImageDemo> {
  //
  static final String uploadEndPoint =
      'http://192.168.0.14:8080/nsfw';
  Future<File> file;
  String status = '';
  String base64Image;
  File tmpFile;
  String errMessage = 'Error Uploading Image';

  chooseImage() {
    setState(() {
      file = ImagePicker.pickImage(source: ImageSource.gallery);
    });
    setStatus('');
  }

  setStatus(String message) {
    setState(() {
      status = message;
    });
  }

  startUpload() {
    setStatus('Uploading Image...');
    if (null == tmpFile) {
      setStatus(errMessage);
      return;
    }
    String fileName = tmpFile.path.split('/').last;
    String fileNameDos = tmpFile.path;
    //upload(fileName);
    //uploadDos(fileNameDos, fileName);
    uploadImageLL(fileName, uploadEndPoint, fileNameDos);
  }

  upload(String fileName) {
    //String JSON = '';
    print(fileName);
    http.post(
        uploadEndPoint,
        //headers:{ "Content-Type": "multipart/form-data" },
        //headers: {'Content-type': 'application/json'},
        headers: {
          'content-type': 'multipart/form-data; charset=utf-8'
        },
        /*body: {
          "image": base64Image,
          'name': 'temp.jpeg',
        }*/
        body: jsonEncode({
          "file": base64Image,
          'image': 'temp.jpeg',
        }),
    ).then((result) {
      print("body");
      print(result.body);
      print("errMessage");
      print( errMessage );
      setStatus(result.statusCode == 200 ? result.body : errMessage);
    }).catchError((error) {
      print( "error" );
      print( error );
      //setStatus(error);
    });
  }

  uploadDos(String fileName, String fileNameDos) async {
    var fileName2 = fileName;
    Uri myUri = Uri.parse(fileName2);
    var postUri = Uri.parse( uploadEndPoint );
    var request = new http.MultipartRequest("POST", postUri);

    Uint8List temp = await File.fromUri( myUri ).readAsBytesSync();
    String base64 = base64Encode( temp );

    request.headers["content-type"] = 'application/json';
    request.fields['fieldname'] = 'image';
    request.fields['originalname'] = fileNameDos;
    request.fields['mimetype'] = 'image/jpeg';
    request.fields['encoding'] = '7bit';
    request.files.add(
        new http.MultipartFile.fromBytes(
            'image',
            await File.fromUri( myUri ).readAsBytes(),
            //temp,
            contentType: new MediaType('image', 'jpeg')
      )
    );

    request.send().then((response) {
    if (response.statusCode == 200) print("Uploaded!");
    });

  }

  //upload funcional
Future<String> uploadImageLL(filename, url, filenameDos) async {
      print( "url" );
      print( url );
      print( filenameDos );

      Uri myUri = Uri.parse(filenameDos);
      print( "myUri" );
      print( myUri );

      //get length from file
      File f = new File(filenameDos);
      var s = f.lengthSync();
      print(s);


      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.files.add(
          //await http.MultipartFile.fromPath('image', filename)
          await http.MultipartFile.fromPath('image', filenameDos)
      );
      var res = await request.send();
      return res.reasonPhrase;
}


  Widget showImage() {
    return FutureBuilder<File>(
      future: file,
      builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            null != snapshot.data) {
          tmpFile = snapshot.data;
          base64Image = base64Encode(snapshot.data.readAsBytesSync());
          return Flexible(
            child: Image.file(
              snapshot.data,
              fit: BoxFit.fill,
            ),
          );
        } else if (null != snapshot.error) {
          return const Text(
            'Error Picking Image',
            textAlign: TextAlign.center,
          );
        } else {
          return const Text(
            'No Image Selected',
            textAlign: TextAlign.center,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Image Demo"),
      ),
      body: Container(
        padding: EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            OutlineButton(
              onPressed: chooseImage,
              child: Text('Choose Image'),
            ),
            SizedBox(
              height: 20.0,
            ),
            showImage(),
            SizedBox(
              height: 20.0,
            ),
            OutlineButton(
              onPressed: startUpload,
              child: Text('Upload Image'),
            ),
            SizedBox(
              height: 20.0,
            ),
            Text(
              status,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w500,
                fontSize: 20.0,
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
          ],
        ),
      ),
    );
  }
}