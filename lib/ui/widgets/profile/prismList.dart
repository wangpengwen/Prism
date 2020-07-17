import 'package:Prism/theme/jam_icons_icons.dart';
import 'package:Prism/ui/widgets/popup/changelogPopUp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Prism/global/globals.dart' as globals;

class PrismList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Prism',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).accentColor,
              ),
            ),
          ),
        ),
        ListTile(
            leading: Icon(
              JamIcons.info,
            ),
            title: new Text(
              "What's new?",
              style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Proxima Nova"),
            ),
            subtitle: Text(
              "Check out the changelog",
              style: TextStyle(fontSize: 12),
            ),
            onTap: () {
              showChangelog(context, () {});
            }),
        ListTile(
            leading: Icon(
              JamIcons.share_alt,
            ),
            title: new Text(
              "Share Prism!",
              style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Proxima Nova"),
            ),
            subtitle: Text(
              "Quick link to pass on to your friends and enemies",
              style: TextStyle(fontSize: 12),
            ),
            onTap: () {
              Share.share(
                  'Hey check out this amazing wallpaper app Prism https://play.google.com/store/apps/details?id=com.hash.prism');
            }),
        ListTile(
            leading: Icon(
              JamIcons.github,
            ),
            title: new Text(
              "View Prism on GitHub!",
              style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Proxima Nova"),
            ),
            subtitle: Text(
              "Check out the code or contribute yourself",
              style: TextStyle(fontSize: 12),
            ),
            onTap: () async {
              launch("https://github.com/LiquidatorCoder/Prism");
            }),
        ListTile(
            leading: Icon(
              JamIcons.picture,
            ),
            title: new Text(
              "API",
              style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Proxima Nova"),
            ),
            subtitle: Text(
              "Prism uses Wallhaven and Pexels API for wallpapers",
              style: TextStyle(fontSize: 12),
            ),
            onTap: () async {
              showDialog(
                context: context,
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  content: Container(
                    height: 150,
                    width: 250,
                    child: Center(
                      child: ListView.builder(
                          itemCount: 2,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: Icon(
                                index == 0 ? JamIcons.picture : JamIcons.camera,
                                color: Theme.of(context).accentColor,
                              ),
                              title: Text(
                                index == 0 ? "WallHaven API" : "Pexels API",
                                style: Theme.of(context).textTheme.headline4,
                              ),
                              onTap: index == 0
                                  ? () async {
                                      HapticFeedback.vibrate();
                                      Navigator.of(context).pop();
                                      launch("https://wallhaven.cc/help/api");
                                    }
                                  : () async {
                                      HapticFeedback.vibrate();
                                      Navigator.of(context).pop();
                                      launch("https://www.pexels.com/api/");
                                    },
                            );
                          }),
                    ),
                  ),
                ),
              );
            }),
        ListTile(
            leading: Icon(
              JamIcons.computer_alt,
            ),
            title: new Text(
              "Version",
              style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Proxima Nova"),
            ),
            subtitle: Text(
              "v${globals.currentAppVersion}+${globals.currentAppVersionCode}",
              style: TextStyle(fontSize: 12),
            ),
            onTap: () {}),
        ListTile(
            leading: Icon(
              JamIcons.bug,
            ),
            title: new Text(
              "Report a bug",
              style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Proxima Nova"),
            ),
            subtitle: Text(
              "Tell us if you found out a bug",
              style: TextStyle(fontSize: 12),
            ),
            onTap: () {
              launch("https://github.com/Hash-Studios/Prism/issues");
            }),
      ],
    );
  }
}