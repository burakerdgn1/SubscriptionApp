import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';

class Settings extends StatefulWidget {
  const Settings({
    Key? key,
  }) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool isSwitchedSetting1 = false;
  bool isSwitchedSetting2 = false;
  bool isSwitchedSetting3 = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: SettingsList(
        
        sections: [
          SettingsSection(
            
            titlePadding: EdgeInsets.all(15),
            
            title: 'General',
            tiles: [
              SettingsTile(
                title: 'Language',
                subtitle: 'English',
                leading: Icon(Icons.language),
                onPressed: (BuildContext context) {},
              ),
              SettingsTile(
                title: 'Account Settings',
                subtitle: 'Change Password etc.',
                leading: Icon(Icons.account_box),
                onPressed: (BuildContext context) {},
              ),
              
              SettingsTile.switchTile(
                title: 'Setting1',
                leading: Icon(Icons.phone_android),
                switchValue: isSwitchedSetting1,
                onToggle: (value) {
                  setState(() {
                    isSwitchedSetting1 = value;
                  });
                },
              ),
              SettingsTile.switchTile(
                title: 'Setting2',
                leading: Icon(Icons.phone_android),
                switchValue: isSwitchedSetting2,
                onToggle: (value) {
                  setState(() {
                    isSwitchedSetting2 = value;
                  });
                },
              ),
              SettingsTile.switchTile(
                
                title: 'Setting3',
                leading: Icon(Icons.phone_android),
                switchValue: isSwitchedSetting3,
                onToggle: (value) {
                  setState(() {
                    isSwitchedSetting3 = value;
                  });
                },
              ),
            ],
          ),
          SettingsSection(
            titlePadding: EdgeInsets.all(15),
            title: 'Report&Feedback',
            tiles: [
              SettingsTile(
                title: 'Report Bug',
                leading: Icon(Icons.report),
                onPressed: (BuildContext context) {},
              ),
              SettingsTile(
                title: 'Give Feedback',
                leading: Icon(Icons.feedback),
                onPressed: (BuildContext context) {},
              ),
              
            ],
          ),
        ],
      ),
    );
  }
}
