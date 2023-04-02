-------------------------------------------------
-- Playerctl Widget for Awesome Window Manager
-- Requires playerctl
-- To create the widget do:
-- ```lua
--  local playerctl_widget = require("widgets.playerctl.playerctl")
--  playerctl_widget{args}
-- ```
-------------------------------------------------

local awful = require("awful")
local wibox = require("wibox")
local watch = require("awful.widget.watch")


local widget = {}

local function worker(args)
    local preferred_player = args.preferred_player or "spotify"
    local command = 'playerctl -p ' .. preferred_player .. ',%any '
    local GET_STATUS_CMD = command .. ' status'
    local GET_CURRENT_SONG_CMD = command .. ' metadata'


    local args = args or {}

    local play_icon = args.play_icon or os.getenv("HOME") .. '/.config/awesome/widgets/playerctl/player_play.png'
    local pause_icon = args.pause_icon or os.getenv("HOME") .. '/.config/awesome/widgets/playerctl/player_pause.png'
    local font = args.font or 'Play 9'
    local dim_when_paused = args.dim_when_paused == nil and false or args.dim_when_paused
    local dim_opacity = args.dim_opacity or 0.2
    local show_tooltip = args.show_tooltip == nil and true or args.show_tooltip
    local timeout = args.timeout or 1

    local cur_artist = ''
    local cur_title = ''
    local cur_album = ''
    local status = false

    widget = wibox.widget {
        {
            layout = wibox.container.scroll.horizontal,
            max_size = 100,
            step_function = wibox.container.scroll.step_functions.increase,
            speed = 10,
            extra_space = 20,
            {
                id = 'artistw',
                font = font,
                widget = wibox.widget.textbox,
            }
        },
        {
            id = "icon",
            widget = wibox.widget.imagebox,
        },
        {
            layout = wibox.container.scroll.horizontal,
            max_size = 100,
            step_function = wibox.container.scroll.step_functions.increase,
            speed = 10,
            extra_space = 20,
            {
                id = 'titlew',
                font = font,
                widget = wibox.widget.textbox
            }
        },
        layout = wibox.layout.align.horizontal,
        set_status = function(self, is_playing)
            self.icon.image = (is_playing and play_icon or pause_icon)
            status = is_playing
            if dim_when_paused then
                self:get_children_by_id('icon')[1]:set_opacity(is_playing and 1 or dim_opacity)

                self:get_children_by_id('titlew')[1]:set_opacity(is_playing and 1 or dim_opacity)
                self:get_children_by_id('titlew')[1]:emit_signal('widget::redraw_needed')

                self:get_children_by_id('artistw')[1]:set_opacity(is_playing and 1 or dim_opacity)
                self:get_children_by_id('artistw')[1]:emit_signal('widget::redraw_needed')
            end
        end,


        set_text = function(self, artist, song)
            local artist_to_display = artist
            if self:get_children_by_id('artistw')[1]:get_markup() ~= artist_to_display then
                self:get_children_by_id('artistw')[1]:set_markup(artist_to_display)
            end
            local title_to_display = song
            if self:get_children_by_id('titlew')[1]:get_markup() ~= title_to_display then
                self:get_children_by_id('titlew')[1]:set_markup(title_to_display)
            end
        end
    }

    local update_widget_icon = function(widget, stdout, _, _, _)
        stdout = string.gsub(stdout, "\n", "")
        widget:set_status(stdout == 'Playing' and true or false)
    end

    local update_widget_text = function(widget, stdout, _, _, _)
        if string.len(stdout) == 0 then
            widget:set_text('', '')
            widget:set_visible(false)
            return
        end

        local escaped = string.gsub(stdout, "&", '&amp;')
        local title = string.match(escaped, "xesam:title *([^\n]*)")
        local album = string.match(escaped, "xesam:album *([^\n]*)")
        local artist = string.match(escaped, "xesam:artist *([^\n]*)")
        if album ~= nil and title ~= nil and artist ~= nil then
            cur_artist = artist
            cur_title = title
            cur_album = album

            widget:set_text(artist, title)
            widget:set_visible(true)
        end
    end

    watch(GET_STATUS_CMD, timeout, update_widget_icon, widget)
    watch(GET_CURRENT_SONG_CMD, timeout, update_widget_text, widget)

    --- Adds mouse controls to the widget:
    --  - left click - play/pause
    --  - scroll up - play next song
    --  - scroll down - play previous song
    widget:connect_signal("button::press", function(_, _, _, button)
        print(button)
        if (button == 1) then
            awful.spawn(command .. (status and "pause" or "play"), false) -- left click
        elseif (button == 4) then
            awful.spawn(command .. "next", false)                         -- scroll up
        elseif (button == 5) then
            awful.spawn(command .. "prev", false)                         -- scroll down
        elseif (button == 2) then
            awful.spawn("killall " .. preferred_player, false)                      -- middle mouse
        end
        awful.spawn.easy_async(GET_CURRENT_SONG_CMD, function(stdout, stderr, exitreason, exitcode)
            update_widget_icon(widget, stdout, stderr, exitreason, exitcode)
        end)
    end)


    if show_tooltip then
        local playerctl_tooltip = awful.tooltip {
            mode = 'outside',
            preferred_positions = { 'bottom' },
            bg = args.bg or "#ffcb60",
            fg = args.fg or "#000000",
            font = font
        }

        playerctl_tooltip:add_to_object(widget)

        widget:connect_signal('mouse::enter', function()
            playerctl_tooltip.markup = ((string.len(cur_album) > 0) and ('<b>Album</b>: ' .. cur_album .. "\n") or "")
                .. ((string.len(cur_artist) > 0) and ('<b>Artist</b>: ' .. cur_artist .. "\n") or "")
                .. ((string.len(cur_title) > 0) and ('<b>Title</b>: ' .. cur_title) or "")
        end)
    end

    return widget
end

return setmetatable(widget, {
    __call = function(_, ...)
        return worker(...)
    end
})
