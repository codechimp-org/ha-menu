#  HA Menu

A Mac OS Menu Bar app to perform common Home Assistant functions  
Currently HA Menu supports turning available switches, lights and input_boolean's on and off.

![alt text](https://github.com/andrew-codechimp/ha-menu/blob/master/Art/menu.png "HA Menu")

## Installation
Get the latest HA.Menu.zip from [Releases](https://github.com/andrew-codechimp/ha-menu/releases)  
Unzip and copy the HA Menu app to your Applications folder

You will have needed to enable Allow app's downloaded from App Store and identified developers enabled in Security & Privacy Settings to run.  

To create a token within HA, login to HA and click on your profile.
Under Long Lived Access Tokens, create a new token, give it a name and copy the token value into HA Menu preferences.

For now there's no automatic update when new versions are released.  Suggest using the Watch/Releases Only within GitHub to get notified when a new version is available. 

### Groups
HA provides default all_switches and all_light groups (not all_input_boolean's). If you have a lot of switches/lights or want to list input_boolean's you can have HA Menu display a specific set by [creating new groups within HA](https://www.home-assistant.io/integrations/group/). Add your switches/lights/input_booleans to the group(s) and enter the group entity id's in HA Menu preferences.  You can have multiple groups displayed in HA Menu by comma seperating the entity id's.  They will be displayed in order with a seperator between each group.

Example groups.yaml
```
hamenu:
  control: hidden
  view: no
  name: HA Menu Switches
  entities:
    - switch.printer
    - switch.lego_lights
    - light.desk_lamp
    - input_boolean.notifications
```
