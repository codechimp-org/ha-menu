![Logo](https://github.com/andrew-codechimp/ha-menu/blob/master/Art/logo.png)
# HA Menu

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
HA provides default all_switches and all_light groups (not all_input_boolean's). HA Menu displays these two groups by default (in Preferences you will see under groups there is all_switches,all_lights 

If you have a lot of switches/lights or want to list input_boolean's you can have HA Menu display a specific set by [creating new groups within HA](https://www.home-assistant.io/integrations/group/). 

First of all create your group(s) within groups.yaml as per the example.  Note the group entity id is ha_menu in this example.  Validate and restart HA to have the group added to HA. If you want multiple groups just repeat the block and rename the entity id/name and change your entity's.

Once you have the group(s) added to HA, within HA Menu go to Preferences and within the Groups field enter the group entity ID's you want to be displayed (ha_menu in this example). If you have created multiple groups you can comma separate their entity ID's e.g. ha_menu,all_switches,all_lights  
Close preferences to save these settings.

Now when you click on HA Menu again the group's you have setup will be displayed.  The groups are displayed in the order you entered them into preferences, with custom groups the items are displyed in the order they are added within the group (printer, lego_lights, desk_lamp, notifications in the example).  With default groups (all_switches, all_lights) they are displayed alphabetically.

Example groups.yaml
```
ha_menu:
  control: hidden
  view: no
  name: HA Menu Switches
  entities:
    - switch.printer
    - switch.lego_lights
    - light.desk_lamp
    - input_boolean.notifications
```
