# Security Banner

DataRobot has the capability to display a Security Banner at the top of the screen.

## Configuration

To enable and configure the Security Banner, modify the `config.yaml` file:

```yaml
# config.yaml snippet
---
app_configuration:
    SHOW_SECURITY_BANNER: True
    SHOW_SECURITY_BANNER_COLOR: red
    SHOW_SECURITY_BANNER_TEXT: This system has a security banner.
```

### SHOW_SECURITY_BANNER

_Default value:_ False
_Description:_ This environment variable controls the display of the banner. If it is False, then the banner is not displayed.

### SHOW_SECURITY_BANNER_COLOR

_Default value:_ red
_Value choices:_ red, yellow, green
_Description_: This controls the color of the banner and the text. The predefined choices are:
  * red: Red background with white text 
  * yellow: Yellow background with black text
  * green: Green background with white text
  
### SHOW_SECURITY_BANNER_TEXT

_Default value:_ 'Default banner text'
_Description:_ The text that is displayed in the banner. It is center aligned and it is recommended that the text be less than 100 characters long.
