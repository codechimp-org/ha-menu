#  HA Menu

A Mac OS Menu Bar app to perform common Home Assistant functions  
Currently HA Menu supports turning switches on and off.

![alt text](https://github.com/andrew-codechimp/ha-menu/blob/master/Art/menu.png "HA Menu")

## Installation
Get the latest HA.Menu.zip from [Releases](https://github.com/andrew-codechimp/ha-menu/releases)  
Unzip and copy the HA Menu app to your Applications folder

You will have needed to enable Allow app's downloaded from App Store and identified developers enabled in Security & Privacy Settings to run.  

To create a token within HA, login to HA and click on your profile.
Under Long Lived Access Tokens, create a new token, give it a name and copy the token value into HA Menu preferences.

### Other items
If you want to control other items with an on/off state, such as lights then create a [template switch](https://www.home-assistant.io/integrations/switch.template)

### Groups
If you have a lot of switches and only want to have HA Menu display a specific set then [create a new group within HA](https://www.home-assistant.io/integrations/group/), add your switches to the group and enter the group entity id in HA Menu preferences.

Example   
```
hamenu:
  control: hidden
  view: no
  name: HA Menu Switches
  entities:
    - switch.printer
    - switch.lego_lights
```