import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:tiktok_clone/common/widgets/video_config/video_config.dart';
import 'package:tiktok_clone/features/authentication/repos/authentication_repo.dart';
import 'package:tiktok_clone/features/videos/view_models/playback_config_view_model.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Localizations.override(
      context: context,
      locale: const Locale("es"),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: ListView(
          children: [
            ValueListenableBuilder(
              valueListenable: configDarkMode,
              builder: (context, value, child) => SwitchListTile.adaptive(
                  activeColor: Colors.black,
                  value: value,
                  onChanged: (value) {
                    configDarkMode.value = !configDarkMode.value;
                  },
                  title: const Text("Dark Mode"),
                  subtitle: const Text('Toggle DarkMode.')),
            ),
            SwitchListTile.adaptive(
                activeColor: Colors.black,
                value: ref.watch(playbackConfigProvider).muted,
                onChanged: (value) => {
                      ref.read(playbackConfigProvider.notifier).setMuted(value),
                    },
                title: const Text("Mute video"),
                subtitle: const Text("Video will be muted by default.")),
            SwitchListTile.adaptive(
                activeColor: Colors.black,
                value: ref.watch(playbackConfigProvider).autoplay,
                onChanged: (value) => {
                      ref
                          .read(playbackConfigProvider.notifier)
                          .setAutoplay(value),
                    },
                title: const Text("Autoplay"),
                subtitle:
                    const Text('Video will start playing automatically.')),
            SwitchListTile.adaptive(
              activeColor: Colors.black,
              value: false,
              onChanged: (value) => {},
              title: const Text("Enable notifications"),
            ),
            CheckboxListTile(
              activeColor: Colors.black,
              value: false,
              onChanged: (value) => {},
              title: const Text("Marketing emails"),
              subtitle: const Text("We won't spam you."),
            ),
            ListTile(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1980),
                  lastDate: DateTime(2030),
                );
                if (kDebugMode) {
                  print(date);
                }

                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );

                if (kDebugMode) {
                  print(time);
                }

                final booking = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(1980),
                  lastDate: DateTime(2030),
                  builder: (context, child) {
                    return Theme(
                      data: ThemeData(
                        appBarTheme: const AppBarTheme(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.black,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (kDebugMode) {
                  print(booking);
                }
              },
              title: const Text('What is your birthday?'),
            ),
            ListTile(
                title: const Text('Log out(iOS)'),
                textColor: Colors.red,
                onTap: () {
                  showCupertinoDialog(
                    context: context,
                    builder: (context) => CupertinoAlertDialog(
                      title: const Text("Are you sure?"),
                      content: const Text("Plx dot go"),
                      actions: [
                        CupertinoDialogAction(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text("No"),
                        ),
                        CupertinoDialogAction(
                          onPressed: () {
                            ref.read(authRepo).signOut();
                            context.go('/');
                          },
                          isDestructiveAction: true,
                          child: const Text("Yes"),
                        )
                      ],
                    ),
                  );
                }),
            ListTile(
                title: const Text('Log out(Android)'),
                textColor: Colors.red,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      icon: const FaIcon(FontAwesomeIcons.skull),
                      title: const Text("Are you sure?"),
                      content: const Text("Plx dot go"),
                      actions: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const FaIcon(FontAwesomeIcons.car),
                        ),
                        IconButton(
                          onPressed: () => ref.read(authRepo).signOut(),
                          icon: const Text("Yes"),
                        )
                      ],
                    ),
                  );
                }),
            ListTile(
                title: const Text('Log out(iOS / Bottom)'),
                textColor: Colors.red,
                onTap: () {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (context) => CupertinoActionSheet(
                      title: const Text("Are you sure?"),
                      message: const Text("Please dooooont goooo"),
                      actions: [
                        CupertinoActionSheetAction(
                          isDefaultAction: true,
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Not log out'),
                        ),
                        CupertinoActionSheetAction(
                          isDestructiveAction: true,
                          onPressed: () => ref.read(authRepo).signOut(),
                          child: const Text('Yes plz'),
                        ),
                      ],
                    ),
                  );
                }),
            const AboutListTile(),
          ],
        ),
      ),
    );
  }
}
