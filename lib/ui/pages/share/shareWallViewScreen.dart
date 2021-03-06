import 'package:Prism/data/pexels/model/wallpaperp.dart';
import 'package:Prism/data/pexels/provider/pexels.dart';
import 'package:Prism/data/prism/provider/prismProvider.dart';
import 'package:Prism/data/wallhaven/model/wallpaper.dart';
import 'package:Prism/data/wallhaven/provider/wallhaven.dart';
import 'package:Prism/routes/router.dart';
import 'package:Prism/routes/routing_constants.dart';
import 'package:Prism/theme/jam_icons_icons.dart';
import 'package:Prism/ui/widgets/animated/loader.dart';
import 'package:Prism/ui/widgets/clockOverlay.dart';
import 'package:Prism/ui/widgets/menuButton/downloadButton.dart';
import 'package:Prism/ui/widgets/menuButton/favWallpaperButton.dart';
import 'package:Prism/ui/widgets/menuButton/setWallpaperButton.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:io';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ShareWallpaperViewScreen extends StatefulWidget {
  final List arguments;
  ShareWallpaperViewScreen({this.arguments});

  @override
  _ShareWallpaperViewScreenState createState() =>
      _ShareWallpaperViewScreenState();
}

class _ShareWallpaperViewScreenState extends State<ShareWallpaperViewScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String id;
  String provider;
  String url;
  String thumb;
  bool isLoading = true;
  PaletteGenerator paletteGenerator;
  List<Color> colors;
  Color accent;
  bool colorChanged = false;
  File _imageFile;
  bool screenshotTaken = false;
  ScreenshotController screenshotController = ScreenshotController();
  AnimationController shakeController;
  Future future;
  PanelController panelController = PanelController();
  var image;
  bool panelClosed = true;

  Future<void> _updatePaletteGenerator() async {
    setState(() {
      isLoading = true;
    });
    try {
      image = new CachedNetworkImageProvider(thumb, errorListener: () {
        colors = [
          Color(0xFFFFFFFF),
          Color(0xFFc7c7c7),
          Color(0xFF848484),
          Color(0xFF3d3d3d),
          Color(0xFF000000)
        ];
      });
    } catch (e) {
      // toasts.error(e.toString());
    }
    paletteGenerator = await PaletteGenerator.fromImageProvider(image,
        maximumColorCount: 20, timeout: Duration(seconds: 120));
    setState(() {
      isLoading = false;
    });
    colors = paletteGenerator.colors.toList();
    print(colors.toString());
    if (paletteGenerator.colors.length > 5) {
      colors = colors.sublist(0, 5);
    }
    setState(() {
      accent = colors[0];
    });
  }

  void updateAccent() {
    if (colors.contains(accent)) {
      var index = colors.indexOf(accent);
      setState(() {
        accent = colors[(index + 1) % 5];
      });
      setState(() {
        colorChanged = true;
      });
    }
  }

  @override
  void initState() {
    shakeController = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    id = widget.arguments[0];
    provider = widget.arguments[1];
    url = widget.arguments[2];
    thumb = widget.arguments[3];
    isLoading = true;
    if (provider == "WallHaven") {
      future = Provider.of<WallHavenProvider>(context, listen: false)
          .getWallbyID(id);
    } else if (provider == "Pexels") {
      future =
          Provider.of<PexelsProvider>(context, listen: false).getWallbyIDP(id);
    } else if (provider == "Prism") {
      future =
          Provider.of<PrismProvider>(context, listen: false).getDataByID(id);
    }
    _updatePaletteGenerator();
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  @override
  void dispose() {
    shakeController.dispose();
    super.dispose();
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.top, SystemUiOverlay.bottom]);
  }

  Future<bool> onWillPop() async {
    if(navStack.length>1)navStack.removeLast();
    print(navStack);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> offsetAnimation = Tween(begin: 0.0, end: 48.0)
        .chain(CurveTween(curve: Curves.easeOutCubic))
        .animate(shakeController)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              shakeController.reverse();
            }
          });
    return WillPopScope(
      onWillPop: onWillPop,
      child: provider == "WallHaven"
          ? Scaffold(
              resizeToAvoidBottomPadding: false,
              key: _scaffoldKey,
              backgroundColor:
                  isLoading ? Theme.of(context).primaryColor : accent,
              body: SlidingUpPanel(
                onPanelOpened: () {
                  if (panelClosed) {
                    print('Screenshot Starting');
                    screenshotController
                        .capture(
                      pixelRatio: 3,
                      delay: Duration(milliseconds: 10),
                    )
                        .then((File image) async {
                      setState(() {
                        _imageFile = image;
                        screenshotTaken = true;
                        panelClosed = false;
                      });
                      print('Screenshot Taken');
                    }).catchError((onError) {
                      print(onError);
                    });
                  }
                },
                onPanelClosed: () {
                  setState(() {
                    panelClosed = true;
                  });
                },
                backdropEnabled: true,
                backdropTapClosesPanel: true,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [],
                collapsed: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      color: Color(0xFF2F2F2F)),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 20,
                    child: Center(
                        child: Icon(
                      JamIcons.chevron_up,
                      color: Colors.white,
                    )),
                  ),
                ),
                minHeight: MediaQuery.of(context).size.height / 20,
                parallaxEnabled: true,
                parallaxOffset: 0.54,
                color: Color(0xFF2F2F2F),
                maxHeight: MediaQuery.of(context).size.height * .46,
                controller: panelController,
                panel: Container(
                  height: MediaQuery.of(context).size.height * .42,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    color: Color(0xFF2F2F2F),
                  ),
                  child: FutureBuilder<WallPaper>(
                      future: future,
                      builder: (context, AsyncSnapshot<WallPaper> snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting ||
                            snapshot.connectionState == ConnectionState.none) {
                          print("snapshot none, waiting in share route");
                          return CircularProgressIndicator();
                        } else {
                          print("done");
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Center(
                                  child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Icon(
                                  JamIcons.chevron_down,
                                  color: Colors.white,
                                ),
                              )),
                              Expanded(
                                flex: 2,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: List.generate(
                                    colors == null ? 5 : colors.length,
                                    (color) {
                                      return GestureDetector(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: colors == null
                                                  ? Color(0xFF000000)
                                                  : colors[color],
                                              borderRadius:
                                                  BorderRadius.circular(500),
                                            ),
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                8,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                8,
                                          ),
                                          onTap: () {
                                            // String route = currentRoute;
                                            // currentRoute = previousRoute;
                                            // previousRoute = route;
                                            // print(currentRoute);
                                            SystemChrome
                                                .setEnabledSystemUIOverlays([
                                              SystemUiOverlay.top,
                                              SystemUiOverlay.bottom
                                            ]);
                                            Navigator.pushNamed(
                                              context,
                                              ColorRoute,
                                              arguments: [
                                                colors[color]
                                                    .toString()
                                                    .replaceAll(
                                                        "Color(0xff", "")
                                                    .replaceAll(")", ""),
                                              ],
                                            );
                                          });
                                    },
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(35, 0, 35, 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 5, 0, 10),
                                            child: Text(
                                              id.toString().toUpperCase(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                JamIcons.eye,
                                                size: 20,
                                                color: Colors.white70,
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                "${Provider.of<WallHavenProvider>(context).wall == null ? 0 : Provider.of<WallHavenProvider>(context).wall.views.toString()}",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2,
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Icon(
                                                JamIcons.heart_f,
                                                size: 20,
                                                color: Colors.white70,
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                "${Provider.of<WallHavenProvider>(context).wall == null ? 0 : Provider.of<WallHavenProvider>(context).wall.favourites.toString()}",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2,
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Icon(
                                                JamIcons.save,
                                                size: 20,
                                                color: Colors.white70,
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                "${Provider.of<WallHavenProvider>(context).wall == null ? 0 : (double.parse(((double.parse(Provider.of<WallHavenProvider>(context).wall.file_size.toString()) / 1000000).toString())).toStringAsFixed(2))} MB",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 0, 0, 0),
                                            child: Row(
                                              children: [
                                                Text(
                                                  Provider.of<WallHavenProvider>(
                                                                  context)
                                                              .wall ==
                                                          null
                                                      ? "General"
                                                      : (Provider.of<WallHavenProvider>(
                                                                  context)
                                                              .wall
                                                              .category
                                                              .toString()[0]
                                                              .toUpperCase() +
                                                          Provider.of<WallHavenProvider>(
                                                                  context)
                                                              .wall
                                                              .category
                                                              .toString()
                                                              .substring(1)),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText2,
                                                ),
                                                SizedBox(width: 10),
                                                Icon(
                                                  JamIcons.unordered_list,
                                                  size: 20,
                                                  color: Colors.white70,
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Text(
                                                "${Provider.of<WallHavenProvider>(context).wall == null ? 0x0 : Provider.of<WallHavenProvider>(context).wall.resolution.toString()}",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2,
                                              ),
                                              SizedBox(width: 10),
                                              Icon(
                                                JamIcons.set_square,
                                                size: 20,
                                                color: Colors.white70,
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Text(
                                                provider.toString(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2,
                                              ),
                                              SizedBox(width: 10),
                                              Icon(
                                                JamIcons.database,
                                                size: 20,
                                                color: Colors.white70,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    DownloadButton(
                                        colorChanged: colorChanged,
                                        link: screenshotTaken
                                            ? _imageFile.path
                                            : Provider.of<WallHavenProvider>(
                                                            context)
                                                        .wall ==
                                                    null
                                                ? ""
                                                : Provider.of<
                                                            WallHavenProvider>(
                                                        context)
                                                    .wall
                                                    .path
                                                    .toString()),
                                    SetWallpaperButton(
                                      colorChanged: colorChanged,
                                      url: screenshotTaken
                                          ? _imageFile.path
                                          : Provider.of<WallHavenProvider>(
                                                          context)
                                                      .wall ==
                                                  null
                                              ? ""
                                              : Provider.of<WallHavenProvider>(
                                                      context)
                                                  .wall
                                                  .path
                                                  .toString(),
                                    ),
                                    FavouriteWallpaperButton(
                                      id: Provider.of<WallHavenProvider>(
                                                      context)
                                                  .wall ==
                                              null
                                          ? ""
                                          : Provider.of<WallHavenProvider>(
                                                  context)
                                              .wall
                                              .id
                                              .toString(),
                                      provider: "WallHaven",
                                      wallhaven: Provider.of<WallHavenProvider>(
                                                      context)
                                                  .wall ==
                                              null
                                          ? WallPaper()
                                          : Provider.of<WallHavenProvider>(
                                                  context)
                                              .wall,
                                      trash: false,
                                    )
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                      }),
                ),
                body: Stack(
                  children: <Widget>[
                    AnimatedBuilder(
                        animation: offsetAnimation,
                        builder: (buildContext, child) {
                          if (offsetAnimation.value < 0.0)
                            print('${offsetAnimation.value + 8.0}');
                          return GestureDetector(
                            child: CachedNetworkImage(
                              imageUrl: url,
                              imageBuilder: (context, imageProvider) =>
                                  Screenshot(
                                controller: screenshotController,
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: offsetAnimation.value * 1.25,
                                      horizontal: offsetAnimation.value / 2),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        offsetAnimation.value),
                                    image: DecorationImage(
                                      colorFilter: colorChanged
                                          ? ColorFilter.mode(
                                              accent, BlendMode.hue)
                                          : null,
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              placeholder: (context, url) => Stack(
                                children: <Widget>[
                                  SizedBox.expand(child: Text("")),
                                  Container(
                                    child: Center(
                                      child: Loader(),
                                    ),
                                  ),
                                ],
                              ),
                              errorWidget: (context, url, error) => Container(
                                child: Center(
                                  child: Icon(
                                    JamIcons.close_circle_f,
                                    color: isLoading
                                        ? Theme.of(context).accentColor
                                        : accent.computeLuminance() > 0.5
                                            ? Colors.black
                                            : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            onPanUpdate: (details) {
                              if (details.delta.dy < -10) {
                                HapticFeedback.vibrate();
                                panelController.open();
                              }
                            },
                            onLongPress: () {
                              setState(() {
                                colorChanged = false;
                              });
                              HapticFeedback.vibrate();
                              shakeController.forward(from: 0.0);
                            },
                            onTap: () {
                              HapticFeedback.vibrate();
                              !isLoading ? updateAccent() : print("");
                              shakeController.forward(from: 0.0);
                            },
                          );
                        }),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                          onPressed: () {
                            navStack.removeLast();
                            print(navStack);
                            Navigator.pop(context);
                          },
                          color: isLoading
                              ? Theme.of(context).accentColor
                              : accent.computeLuminance() > 0.5
                                  ? Colors.black
                                  : Colors.white,
                          icon: Icon(
                            JamIcons.chevron_left,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                          onPressed: () {
                            var link = url;
                            Navigator.push(
                                context,
                                PageRouteBuilder(
                                    transitionDuration:
                                        Duration(milliseconds: 300),
                                    pageBuilder: (context, animation,
                                        secondaryAnimation) {
                                      animation = Tween(begin: 0.0, end: 1.0)
                                          .animate(animation);
                                      return FadeTransition(
                                          opacity: animation,
                                          child: ClockOverlay(
                                            colorChanged: colorChanged,
                                            accent: accent,
                                            link: link,
                                            file: false,
                                          ));
                                    },
                                    fullscreenDialog: true,
                                    opaque: false));
                          },
                          color: isLoading
                              ? Theme.of(context).accentColor
                              : accent.computeLuminance() > 0.5
                                  ? Colors.black
                                  : Colors.white,
                          icon: Icon(
                            JamIcons.clock,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          : provider == "Prism"
              ? Scaffold(
                  resizeToAvoidBottomPadding: false,
                  key: _scaffoldKey,
                  backgroundColor:
                      isLoading ? Theme.of(context).primaryColor : accent,
                  body: SlidingUpPanel(
                    onPanelOpened: () {
                      if (panelClosed) {
                        print('Screenshot Starting');
                        screenshotController
                            .capture(
                          pixelRatio: 3,
                          delay: Duration(milliseconds: 10),
                        )
                            .then((File image) async {
                          setState(() {
                            _imageFile = image;
                            screenshotTaken = true;
                            panelClosed = false;
                          });
                          print('Screenshot Taken');
                        }).catchError((onError) {
                          print(onError);
                        });
                      }
                    },
                    onPanelClosed: () {
                      setState(() {
                        panelClosed = true;
                      });
                    },
                    backdropEnabled: true,
                    backdropTapClosesPanel: true,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [],
                    collapsed: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          color: Color(0xFF2F2F2F)),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height / 20,
                        child: Center(
                            child: Icon(
                          JamIcons.chevron_up,
                          color: Colors.white,
                        )),
                      ),
                    ),
                    minHeight: MediaQuery.of(context).size.height / 20,
                    parallaxEnabled: true,
                    parallaxOffset: 0.54,
                    color: Color(0xFF2F2F2F),
                    maxHeight: MediaQuery.of(context).size.height * .46,
                    controller: panelController,
                    panel: Container(
                      height: MediaQuery.of(context).size.height * .42,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        color: Color(0xFF2F2F2F),
                      ),
                      child: FutureBuilder<Map>(
                          future: future,
                          builder: (context, AsyncSnapshot<Map> snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.waiting ||
                                snapshot.connectionState ==
                                    ConnectionState.none) {
                              print("snapshot none, waiting in share route");
                              return CircularProgressIndicator();
                            } else {
                              print("done");
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Center(
                                      child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Icon(
                                      JamIcons.chevron_down,
                                      color: Colors.white,
                                    ),
                                  )),
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: List.generate(
                                        colors == null ? 5 : colors.length,
                                        (color) {
                                          return GestureDetector(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: colors == null
                                                      ? Color(0xFF000000)
                                                      : colors[color],
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          500),
                                                ),
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    8,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    8,
                                              ),
                                              onTap: () {
                                                // String route = currentRoute;
                                                // currentRoute = previousRoute;
                                                // previousRoute = route;
                                                // print(currentRoute);
                                                SystemChrome
                                                    .setEnabledSystemUIOverlays([
                                                  SystemUiOverlay.top,
                                                  SystemUiOverlay.bottom
                                                ]);
                                                Navigator.pushNamed(
                                                  context,
                                                  ColorRoute,
                                                  arguments: [
                                                    colors[color]
                                                        .toString()
                                                        .replaceAll(
                                                            "Color(0xff", "")
                                                        .replaceAll(")", ""),
                                                  ],
                                                );
                                              });
                                        },
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          35, 0, 35, 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 5, 0, 10),
                                                child: Text(
                                                  id.toString().toUpperCase(),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText1,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Icon(
                                                    JamIcons.camera,
                                                    size: 20,
                                                    color: Colors.white70,
                                                  ),
                                                  SizedBox(width: 10),
                                                  Text(
                                                    "${Provider.of<PrismProvider>(context).wall == null ? 0 : Provider.of<PrismProvider>(context).wall["by"].toString()}",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText2,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 5),
                                              Row(
                                                children: [
                                                  Icon(
                                                    JamIcons.arrow_circle_right,
                                                    size: 20,
                                                    color: Colors.white70,
                                                  ),
                                                  SizedBox(width: 10),
                                                  Text(
                                                    "${Provider.of<PrismProvider>(context).wall == null ? 0 : Provider.of<PrismProvider>(context).wall["desc"].toString()}",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText2,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 5),
                                              Row(
                                                children: [
                                                  Icon(
                                                    JamIcons.save,
                                                    size: 20,
                                                    color: Colors.white70,
                                                  ),
                                                  SizedBox(width: 10),
                                                  Text(
                                                    "${Provider.of<PrismProvider>(context).wall == null ? 0 : Provider.of<PrismProvider>(context).wall["size"].toString()}",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText2,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 0, 0, 0),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      Provider.of<PrismProvider>(
                                                                      context)
                                                                  .wall ==
                                                              null
                                                          ? "General"
                                                          : (Provider.of<PrismProvider>(
                                                                      context)
                                                                  .wall[
                                                                      "category"]
                                                                  .toString()[0]
                                                                  .toUpperCase() +
                                                              Provider.of<PrismProvider>(
                                                                      context)
                                                                  .wall[
                                                                      "category"]
                                                                  .toString()
                                                                  .substring(
                                                                      1)),
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText2,
                                                    ),
                                                    SizedBox(width: 10),
                                                    Icon(
                                                      JamIcons.unordered_list,
                                                      size: 20,
                                                      color: Colors.white70,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Row(
                                                children: [
                                                  Text(
                                                    "${Provider.of<PrismProvider>(context).wall == null ? 0x0 : Provider.of<PrismProvider>(context).wall["resolution"].toString()}",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText2,
                                                  ),
                                                  SizedBox(width: 10),
                                                  Icon(
                                                    JamIcons.set_square,
                                                    size: 20,
                                                    color: Colors.white70,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 5),
                                              Row(
                                                children: [
                                                  Text(
                                                    provider.toString(),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText2,
                                                  ),
                                                  SizedBox(width: 10),
                                                  Icon(
                                                    JamIcons.database,
                                                    size: 20,
                                                    color: Colors.white70,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        DownloadButton(
                                            colorChanged: colorChanged,
                                            link: screenshotTaken
                                                ? _imageFile.path
                                                : Provider.of<PrismProvider>(
                                                                context)
                                                            .wall ==
                                                        null
                                                    ? ""
                                                    : Provider.of<
                                                                PrismProvider>(
                                                            context)
                                                        .wall["wallpaper_url"]
                                                        .toString()),
                                        SetWallpaperButton(
                                          colorChanged: colorChanged,
                                          url: screenshotTaken
                                              ? _imageFile.path
                                              : Provider.of<PrismProvider>(
                                                              context)
                                                          .wall ==
                                                      null
                                                  ? ""
                                                  : Provider.of<PrismProvider>(
                                                          context)
                                                      .wall["wallpaper_url"]
                                                      .toString(),
                                        ),
                                        FavouriteWallpaperButton(
                                          id: Provider.of<PrismProvider>(
                                                          context)
                                                      .wall ==
                                                  null
                                              ? ""
                                              : Provider.of<PrismProvider>(
                                                      context)
                                                  .wall["id"]
                                                  .toString(),
                                          provider: "Prism",
                                          prism: Provider.of<PrismProvider>(
                                                          context)
                                                      .wall ==
                                                  null
                                              ? {}
                                              : Provider.of<PrismProvider>(
                                                      context)
                                                  .wall,
                                          trash: false,
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }
                          }),
                    ),
                    body: Stack(
                      children: <Widget>[
                        AnimatedBuilder(
                            animation: offsetAnimation,
                            builder: (buildContext, child) {
                              if (offsetAnimation.value < 0.0)
                                print('${offsetAnimation.value + 8.0}');
                              return GestureDetector(
                                child: CachedNetworkImage(
                                  imageUrl: url,
                                  imageBuilder: (context, imageProvider) =>
                                      Screenshot(
                                    controller: screenshotController,
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                          vertical:
                                              offsetAnimation.value * 1.25,
                                          horizontal:
                                              offsetAnimation.value / 2),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            offsetAnimation.value),
                                        image: DecorationImage(
                                          colorFilter: colorChanged
                                              ? ColorFilter.mode(
                                                  accent, BlendMode.hue)
                                              : null,
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  placeholder: (context, url) => Stack(
                                    children: <Widget>[
                                      SizedBox.expand(child: Text("")),
                                      Container(
                                        child: Center(
                                          child: Loader(),
                                        ),
                                      ),
                                    ],
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    child: Center(
                                      child: Icon(
                                        JamIcons.close_circle_f,
                                        color: isLoading
                                            ? Theme.of(context).accentColor
                                            : accent.computeLuminance() > 0.5
                                                ? Colors.black
                                                : Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                onPanUpdate: (details) {
                                  if (details.delta.dy < -10) {
                                    HapticFeedback.vibrate();
                                    panelController.open();
                                  }
                                },
                                onLongPress: () {
                                  setState(() {
                                    colorChanged = false;
                                  });
                                  HapticFeedback.vibrate();
                                  shakeController.forward(from: 0.0);
                                },
                                onTap: () {
                                  HapticFeedback.vibrate();
                                  !isLoading ? updateAccent() : print("");
                                  shakeController.forward(from: 0.0);
                                },
                              );
                            }),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButton(
                              onPressed: () {
                                navStack.removeLast();
                                print(navStack);
                                Navigator.pop(context);
                              },
                              color: isLoading
                                  ? Theme.of(context).accentColor
                                  : accent.computeLuminance() > 0.5
                                      ? Colors.black
                                      : Colors.white,
                              icon: Icon(
                                JamIcons.chevron_left,
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButton(
                              onPressed: () {
                                var link = url;
                                Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                        transitionDuration:
                                            Duration(milliseconds: 300),
                                        pageBuilder: (context, animation,
                                            secondaryAnimation) {
                                          animation =
                                              Tween(begin: 0.0, end: 1.0)
                                                  .animate(animation);
                                          return FadeTransition(
                                              opacity: animation,
                                              child: ClockOverlay(
                                                colorChanged: colorChanged,
                                                accent: accent,
                                                link: link,
                                                file: false,
                                              ));
                                        },
                                        fullscreenDialog: true,
                                        opaque: false));
                              },
                              color: isLoading
                                  ? Theme.of(context).accentColor
                                  : accent.computeLuminance() > 0.5
                                      ? Colors.black
                                      : Colors.white,
                              icon: Icon(
                                JamIcons.clock,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              : provider == "Pexels"
                  ? Scaffold(
                      resizeToAvoidBottomPadding: false,
                      key: _scaffoldKey,
                      backgroundColor: isLoading
                          ? Theme.of(context).primaryColor
                          : colors[0],
                      body: SlidingUpPanel(
                        backdropEnabled: true,
                        backdropTapClosesPanel: true,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        boxShadow: [],
                        collapsed: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                              color: Color(0xFF2F2F2F)),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height / 20,
                            child: Center(
                                child: Icon(
                              JamIcons.chevron_up,
                              color: Colors.white,
                            )),
                          ),
                        ),
                        minHeight: MediaQuery.of(context).size.height / 20,
                        parallaxEnabled: true,
                        parallaxOffset: 0.54,
                        color: Color(0xFF2F2F2F),
                        maxHeight: MediaQuery.of(context).size.height * .46,
                        controller: panelController,
                        panel: Container(
                          height: MediaQuery.of(context).size.height * .42,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            color: Color(0xFF2F2F2F),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Center(
                                  child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Icon(
                                  JamIcons.chevron_down,
                                  color: Colors.white,
                                ),
                              )),
                              Expanded(
                                flex: 2,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: List.generate(
                                    colors == null ? 5 : colors.length,
                                    (color) {
                                      return GestureDetector(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: colors == null
                                                  ? Color(0xFF000000)
                                                  : colors[color],
                                              borderRadius:
                                                  BorderRadius.circular(500),
                                            ),
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                8,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                8,
                                          ),
                                          onTap: () {
                                            // String route = currentRoute;
                                            // currentRoute = previousRoute;
                                            // previousRoute = route;
                                            // print(currentRoute);
                                            SystemChrome
                                                .setEnabledSystemUIOverlays([
                                              SystemUiOverlay.top,
                                              SystemUiOverlay.bottom
                                            ]);
                                            Navigator.pushNamed(
                                              context,
                                              ColorRoute,
                                              arguments: [
                                                colors[color]
                                                    .toString()
                                                    .replaceAll(
                                                        "Color(0xff", "")
                                                    .replaceAll(")", ""),
                                              ],
                                            );
                                          });
                                    },
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(35, 0, 35, 15),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 5, 0, 10),
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .8,
                                          child: Text(
                                            Provider.of<PexelsProvider>(context).wall == null
                                                ? "Wallpaper"
                                                : (Provider.of<PexelsProvider>(context).wall.url.toString().replaceAll("https://www.pexels.com/photo/", "").replaceAll("-", " ").replaceAll("/", "").length > 8
                                                    ? Provider.of<PexelsProvider>(context)
                                                            .wall
                                                            .url
                                                            .toString()
                                                            .replaceAll(
                                                                "https://www.pexels.com/photo/", "")
                                                            .replaceAll(
                                                                "-", " ")
                                                            .replaceAll(
                                                                "/", "")[0]
                                                            .toUpperCase() +
                                                        Provider.of<PexelsProvider>(context).wall.url.toString().replaceAll("https://www.pexels.com/photo/", "").replaceAll("-", " ").replaceAll("/", "").substring(
                                                            1,
                                                            Provider.of<PexelsProvider>(context).wall.url.toString().replaceAll("https://www.pexels.com/photo/", "").replaceAll("-", " ").replaceAll("/", "").length -
                                                                7)
                                                    : Provider.of<PexelsProvider>(context)
                                                            .wall
                                                            .url
                                                            .toString()
                                                            .replaceAll(
                                                                "https://www.pexels.com/photo/", "")
                                                            .replaceAll(
                                                                "-", " ")
                                                            .replaceAll(
                                                                "/", "")[0]
                                                            .toUpperCase() +
                                                        Provider.of<PexelsProvider>(context)
                                                            .wall
                                                            .url
                                                            .toString()
                                                            .replaceAll("https://www.pexels.com/photo/", "")
                                                            .replaceAll("-", " ")
                                                            .replaceAll("/", "")
                                                            .substring(1)),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Row(
                                                children: [
                                                  Icon(
                                                    JamIcons.camera,
                                                    size: 20,
                                                    color: Colors.white70,
                                                  ),
                                                  SizedBox(width: 10),
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .4,
                                                    child: Text(
                                                      Provider.of<PexelsProvider>(
                                                                      context)
                                                                  .wall ==
                                                              null
                                                          ? "Photographer"
                                                          : Provider.of<
                                                                      PexelsProvider>(
                                                                  context)
                                                              .wall
                                                              .photographer
                                                              .toString(),
                                                      textAlign: TextAlign.left,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText2,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 5),
                                              Row(
                                                children: [
                                                  Icon(
                                                    JamIcons.set_square,
                                                    size: 20,
                                                    color: Colors.white70,
                                                  ),
                                                  SizedBox(width: 10),
                                                  Text(
                                                    "${Provider.of<PexelsProvider>(context).wall == null ? 0 : Provider.of<PexelsProvider>(context).wall.width.toString()}x${Provider.of<PexelsProvider>(context).wall == null ? 0 : Provider.of<PexelsProvider>(context).wall.height.toString()}",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText2,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Row(
                                                children: [
                                                  Text(
                                                    id.toString(),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText2,
                                                  ),
                                                  SizedBox(width: 10),
                                                  Icon(
                                                    JamIcons.info,
                                                    size: 20,
                                                    color: Colors.white70,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 5),
                                              Row(
                                                children: [
                                                  Text(
                                                    provider.toString(),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText2,
                                                  ),
                                                  SizedBox(width: 10),
                                                  Icon(
                                                    JamIcons.database,
                                                    size: 20,
                                                    color: Colors.white70,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    DownloadButton(
                                      colorChanged: colorChanged,
                                      link: screenshotTaken
                                          ? _imageFile.path
                                          : url.toString(),
                                    ),
                                    SetWallpaperButton(
                                      colorChanged: colorChanged,
                                      url: screenshotTaken
                                          ? _imageFile.path
                                          : url.toString(),
                                    ),
                                    FavouriteWallpaperButton(
                                      id: Provider.of<PexelsProvider>(context,
                                                      listen: false)
                                                  .wall ==
                                              null
                                          ? ""
                                          : Provider.of<PexelsProvider>(context,
                                                  listen: false)
                                              .wall
                                              .id
                                              .toString(),
                                      provider: "Pexels",
                                      pexels:
                                          Provider.of<PexelsProvider>(context)
                                                      .wall ==
                                                  null
                                              ? WallPaperP()
                                              : Provider.of<PexelsProvider>(
                                                      context,
                                                      listen: false)
                                                  .wall,
                                      trash: false,
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        body: Stack(
                          children: <Widget>[
                            AnimatedBuilder(
                                animation: offsetAnimation,
                                builder: (buildContext, child) {
                                  if (offsetAnimation.value < 0.0)
                                    print('${offsetAnimation.value + 8.0}');
                                  return GestureDetector(
                                    child: CachedNetworkImage(
                                      imageUrl: url,
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                        margin: EdgeInsets.symmetric(
                                            vertical:
                                                offsetAnimation.value * 1.25,
                                            horizontal:
                                                offsetAnimation.value / 2),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              offsetAnimation.value),
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      placeholder: (context, url) => Stack(
                                        children: <Widget>[
                                          SizedBox.expand(child: Text("")),
                                          Container(
                                            child: Center(
                                              child: Loader(),
                                            ),
                                          ),
                                        ],
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        child: Center(
                                          child: Icon(
                                            JamIcons.close_circle_f,
                                            color: isLoading
                                                ? Theme.of(context).accentColor
                                                : colors[0].computeLuminance() >
                                                        0.5
                                                    ? Colors.black
                                                    : Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    onPanUpdate: (details) {
                                      if (details.delta.dy < -10) {
                                        HapticFeedback.vibrate();
                                        panelController.open();
                                      }
                                    },
                                    onLongPress: () {
                                      HapticFeedback.vibrate();
                                      shakeController.forward(from: 0.0);
                                    },
                                    onTap: () {
                                      HapticFeedback.vibrate();
                                      shakeController.forward(from: 0.0);
                                    },
                                  );
                                }),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: IconButton(
                                  onPressed: () {
                                    navStack.removeLast();
                                    print(navStack);
                                    Navigator.pop(context);
                                  },
                                  color: isLoading
                                      ? Theme.of(context).accentColor
                                      : colors[0].computeLuminance() > 0.5
                                          ? Colors.black
                                          : Colors.white,
                                  icon: Icon(
                                    JamIcons.chevron_left,
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: IconButton(
                                  onPressed: () {
                                    var link = url;
                                    Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                            transitionDuration:
                                                Duration(milliseconds: 300),
                                            pageBuilder: (context, animation,
                                                secondaryAnimation) {
                                              animation =
                                                  Tween(begin: 0.0, end: 1.0)
                                                      .animate(animation);
                                              return FadeTransition(
                                                  opacity: animation,
                                                  child: ClockOverlay(
                                                    colorChanged: colorChanged,
                                                    accent: accent,
                                                    link: link,
                                                    file: false,
                                                  ));
                                            },
                                            fullscreenDialog: true,
                                            opaque: false));
                                  },
                                  color: isLoading
                                      ? Theme.of(context).accentColor
                                      : colors[0].computeLuminance() > 0.5
                                          ? Colors.black
                                          : Colors.white,
                                  icon: Icon(
                                    JamIcons.clock,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  : Container(),
    );
  }
}
