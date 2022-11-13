import 'package:comic_img/comic_img.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum RenderType {
  assets,
  network,
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Comic Demo',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: const MyHomePage(title: 'Comic'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String? title;
  const MyHomePage({Key? key, this.title}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int id = 0;
  int count = 0;

  RenderType renderType = RenderType.assets;

  TextEditingController detailIdController = TextEditingController();
  TextEditingController countController = TextEditingController();

  List<Map<String, dynamic>> data = [];

  beforeHook() {}

  @override
  void initState() {
    super.initState();
    beforeHook();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text("Commic Pic Reader"),
      ),
      body: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 50,
            child: Row(
              children: [
                TextButton(
                  onPressed: () {
                    renderType = renderType == RenderType.assets
                        ? RenderType.network
                        : RenderType.assets;
                    setState(() {});
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.flash_auto),
                      const SizedBox(width: 4.2),
                      Text(
                        "切换成${renderType == RenderType.network ? '本地' : '网络'}图片",
                      ),
                    ],
                  ),
                ),
                if (renderType == RenderType.network) Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6.0,
                            horizontal: 12.0,
                          ),
                          child: TextField(
                            keyboardType: TextInputType.number,
                            controller: detailIdController,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 4.2,
                              ),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6.0,
                            horizontal: 12.0,
                          ),
                          child: TextField(
                            keyboardType: TextInputType.number,
                            controller: countController,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 4.2,
                              ),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        "$id,$count",
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2.0,
                          horizontal: 4.2,
                        ),
                        child: CupertinoButton.filled(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                          ),
                          onPressed: handleChange,
                          child: const Text(
                            "重新加载",
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Builder(builder: (context) {
              if (renderType == RenderType.assets) {
                return Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 42),
                      Text(
                        "assets/00003.webp",
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DecoratedBox(
                        decoration: BoxDecoration(boxShadow: [
                          BoxShadow(
                            offset: const Offset(1, 1),
                            color: Colors.black.withOpacity(.24),
                            blurRadius: 5.0,
                          ),
                        ]),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CommicImage(
                            fit: BoxFit.cover,
                            detailID: 320683,
                            picID: '00003',
                            imageType: CommicImageUrlType.assets,
                            image: 'assets/00003.webp',
                            placeholder: SizedBox(
                              width: MediaQuery.of(context).size.width * .66,
                              height: 240,
                              child: const Center(
                                child: CupertinoActivityIndicator(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: data.map(
                          (e) => _buildImage(e),
                        ).toList(),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  void handleChange() {
    if (data.isNotEmpty) {
      data.clear();
      setState(() {});
    }
    int xid = int.tryParse(detailIdController.text) ?? 0;
    int xcount = int.tryParse(countController.text) ?? 0;
    if (xid <= 3 || xcount <= 0) return;
    data.clear();
    setState(() {});
    for (var i = 0; i < xcount; i++) {
      String syb = (i + 1).toString();
      var s = syb;
      int l = syb.length;
      for (var i = 0; i < (5 - l); i++) {
        s = "0$s";
      }
      s = '$s.webp';
      data.add({
        "id": xid,
        "data": s,
      });
    }
    id = xid;
    count = xcount;
    setState(() {});
  }

  Widget _buildImage(Map<String, dynamic> e) {
    var filename = e['data'].split(".");
    return Center(
      child: CommicImage(
        fit: BoxFit.contain,
        detailID: e['id'],
        picID: filename[0],
        imageExtension: filename[1],
        imageType: CommicImageUrlType.network,
        placeholder: SizedBox(
          width: MediaQuery.of(context).size.width * .66,
          height: 240,
          child: const Center(
            child: CupertinoActivityIndicator(),
          ),
        ),
      ),
    );
  }
}
