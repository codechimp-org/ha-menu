#  HA Menu

A Mac OS Menu Bar app to perform common Home Assistant functions  
Currently HA Menu supports turning available switches and lights on and off.

![alt text](https://github.com/andrew-codechimp/ha-menu/blob/master/Art/menu.png "HA Menu")

## Installation
Get the latest HA.Menu.zip from [Releases](https://github.com/andrew-codechimp/ha-menu/releases)  
Unzip and copy the HA Menu app to your Applications folder

You will have needed to enable Allow app's downloaded from App Store and identified developers enabled in Security & Privacy Settings to run.  

To create a token within HA, login to HA and click on your profile.
Under Long Lived Access Tokens, create a new token, give it a name and copy the token value into HA Menu preferences.

For now there's no automatic update when new versions are released.  Suggest using the Watch/Releases Only within GitHub to get notified when a new version is available. 

### Groups
If you have a lot of switches/lights and only want to have HA Menu display a specific set then [create new groups within HA](https://www.home-assistant.io/integrations/group/), add your switches/lights to the group and enter the group entity id's in HA Menu preferences.  You can have multiple groups displayed in HA Menu by comma seperating the entity id's.  They will be displayed in order with a seperator between each group.

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

### Other items
If you want to control other items with an on/off state then create a [template switch](https://www.home-assistant.io/integrations/switch.template)   

Example of an input_boolean
```
switch:
  # Your other switches
  - platform: template
    switches:
      mything_switch:
        value_template: "{{ is_state('input_boolean.mything', 'on') }}"
        turn_on:
        service: input_boolean.turn_on
          data:
            entity_id: input_boolean.mything
        turn_off:
          service: input_boolean.turn_off
          data:
            entity_id: input_boolean.mything
```
