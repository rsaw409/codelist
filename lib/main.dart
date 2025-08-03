import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher_string.dart';

import './model/contest.dart';
//import './widget/contest_card.dart';
import './api_fetch/fetch.dart';
import './appSettings.dart';
import 'widget/contest_card1.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);
  runApp(
    MaterialApp(
      title: 'CodeList',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: GoogleFonts.lato().fontFamily,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
            .copyWith(surface: Colors.white)
            .copyWith(secondary: Colors.blueAccent),
      ),
      home: MyApp(),
    ),
  );
}
// clist.by

class MySplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('CodeList'),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 5,
              backgroundColor: Color(0xff435373),
            ),
          ],
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  Future<Widget> loadApp() async {
    Hive.registerAdapter(ContestAdapter());
    await Hive.initFlutter();

    final Box<Contest> contestBox = await Hive.openBox<Contest>('ContestBox');
    final Box settingBox = await Hive.openBox('settingBox');

    if (contestBox.length <= 0 || settingBox.length <= 0) {
      print("contest box length is ${contestBox.length}");
      print("settingBox length is ${settingBox.length}");

      await fetchContests(contestBox, settingBox);
      print("Fetching contests success");

      await fetchIcons(settingBox);
      print("Fetching Icons success");

      return MyHomePage(
        title: 'Available Events',
        contestBox: contestBox,
        settingBox: settingBox,
      );
    } else {
      print("Loading from FileStored");
      return MyHomePage(
        title: 'Available Events',
        contestBox: contestBox,
        settingBox: settingBox,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadApp(),
      builder: (BuildContext ctx, AsyncSnapshot<Widget> snapshot) {
        if (snapshot.hasData) return snapshot.data!;
        return MySplashScreen();
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  late final String title;
  late final Box<Contest> contestBox;
  late final Box settingBox;

  MyHomePage(
      {Key? key,
      required this.title,
      required this.contestBox,
      required this.settingBox})
      : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<void> refresh() async {
    await fetchContests(widget.contestBox, widget.settingBox);
    print("contests info fetched");
    await fetchIcons(widget.settingBox);
    print("icons info fetched");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(widget, context),
      body: RefreshIndicator(
        onRefresh: () => refresh(),
        child: ValueListenableBuilder(
          valueListenable:
              widget.settingBox.listenable(keys: ['selectedPlatform']),
          builder: (ctx, Box settingBox, _) => ValueListenableBuilder(
            valueListenable: widget.contestBox.listenable(),
            builder: (ctx, Box<Contest> contestBox, _) {
              List<Contest> tmpList = [];

              late DateTime endDate;
              DateTime today = DateTime.now();
              if (settingBox.get('selectedPlatform').length > 0) {
                for (int i = 0; i < contestBox.length; i++) {
                  endDate = contestBox.getAt(i)!.endDate;
                  if (settingBox
                          .get('selectedPlatform')
                          .contains(contestBox.getAt(i)?.title) &&
                      !endDate.isBefore(today)) {
                    Contest? b = contestBox.getAt(i);
                    if (b != null) tmpList.add(b);
                  }
                }
              } else {
                for (int i = 0; i < contestBox.length; i++) {
                  endDate = contestBox.getAt(i)!.endDate;
                  if (!endDate.isBefore(today)) {
                    Contest? b = contestBox.getAt(i);
                    if (b != null) {
                      tmpList.add(b);
                    }
                  }
                }
              }

              return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Container(
                    child: ListView.separated(
                      itemBuilder: (context, index) {
                        return ContestCard1(tmpList[index]);
                      },
                      itemCount: tmpList.length,
                      separatorBuilder: (ctx, index) => Divider(
                        thickness: 1,
                      ),
                    ),
                  ));
            },
          ),
        ),
      ),
    );
  }
}

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final widget;
  final context;

  MyAppBar(this.widget, this.context);

  @override
  Size get preferredSize {
    return new Size.fromHeight(kToolbarHeight);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        widget.title,
        style: GoogleFonts.lato(),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (context) => AppSettings(widget.settingBox),
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.info_outline),
          onPressed: () {
            showAboutDialog(
              context: context,
              applicationName: 'CodeList',
              applicationVersion: '1.0.1',
              applicationIcon: Image.asset(
                'asset/icon.png',
                width: 50,
                height: 50,
              ),
              children: [
                //Text("CodeList is an application, which is used to have a single place to view all the coding events happening across so many different platforms"),
                Text(
                    'This app aims is to promote and help competitive programming community.'),
                Divider(),
                Text(
                    'Select your favorite platform out of 70+ available platforms'),
                Divider(),
                Text(
                    'This app works in offline mode also, periodically refresh to load new data.'),
                Divider(),
                IconButton(
                  icon: Icon(Icons.mail_outline_sharp),
                  onPressed: () {
                    launchUrlString('https://rohitsaw.github.io');
                  },
                )
              ],
            );
          },
        ),
      ],
    );
  }
}
