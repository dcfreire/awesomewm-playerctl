# Playerctl widget for AweomseWM

Widget to control whatever player you're using with [playerctl](https://github.com/altdesktop/playerctl). Based on [this widget](https://github.com/streetturtle/awesome-wm-widgets/blob/master/spotify-widget/spotify.lua) by streetturtle.

## Installation

Clone this repo under `~/.config/awesome/widgets/`, then add it to your `theme.lua`.

```lua
playerctl_widget{preferred_layer="player_name"} --Defaults to "spotify"
```

## Customization

It is possible to customize widget by providing a table with all or some of the following config parameters:
| Name | Default | Description |
|---|---|---|
| `preferred_player` | `"spotify"` | Player |
| `play_icon` | `"~/.config/awesome/widgets/playerctl/player_play.png"` | Play icon |
| `pause_icon` | `"~/.config/awesome/widgets/playerctl/player_pause.png"` | Pause icon |
| `font` | `"Play 9"`| Font |
| `dim_when_paused` | `false` | Decrease the widget opacity if spotify is paused |
| `dim_opacity` | `0.2` | Widget's opacity when dimmed, `dim_when_paused` should be set to `true` |
| `max_length` | `15` | Maximum lentgh of artist and title names. Text will be ellipsized if longer. |
| `show_tooltip` | `true` | Show tooltip on hover with information about the playing song |
| `timeout` | `1` | How often in seconds the widget refreshes |
| `bg` | `#ffcb60` | Tooltip background |
| `fg` | `#000000` | Tooltip foreground |

## Dependencies

This widget depends on [playerctl](https://github.com/altdesktop/playerctl).
