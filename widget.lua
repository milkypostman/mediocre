---------------------------------------------------------------------------
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2008 Julien Danjou
-- @release @AWESOME_VERSION@
---------------------------------------------------------------------------

-- Grab environment we need
local ipairs = ipairs
local pairs = pairs
local table = table
local otable = otable
local type = type
local math = math
local capi =
{
    screen = screen,
    client = client,
    button = button,
    widget = widget,
    image = image,
    mouse = mouse
}
local util = require("mediocre.util")
local hooks = require("mediocre.hooks")
local beautiful = require("beautiful")
local client = require("mediocre.client")
local tag = require("mediocre.tag")

--- Widget module for awful
module("mediocre.widget")

-- Various public structures
taglist = {}
taglist.label = {}
tasklist = {}
tasklist.label = {}

-- Private structures
local tagwidgets = otable()

local function list_update(w, buttons, label, data, widgets, objects)
    -- Hack: if it has been registered as a widget in a wibox,
    -- it's w.len since __len meta does not work on table until Lua 5.2.
    -- Otherwise it's standard #w.
    local len = (w.len or #w) / 2
    -- Add more widgets
    if len < #objects then
        for i = len * 2 + 1, #objects * 2, 2 do
            local ib = capi.widget({ type = "imagebox", align = widgets.imagebox.align })
            local tb = capi.widget({ type = "textbox", align = widgets.textbox.align })

            w[i] = ib
            w[i + 1] = tb
            w[i + 1]:margin({ left = widgets.textbox.margin.left, right = widgets.textbox.margin.right })
            w[i + 1].bg_resize = widgets.textbox.bg_resize or false
            w[i + 1].bg_align = widgets.textbox.bg_align or ""

            if type(objects[math.floor(i / 2) + 1]) == "tag" then
                tagwidgets[ib] = objects[math.floor(i / 2) + 1]
                tagwidgets[tb] = objects[math.floor(i / 2) + 1]
            end
        end
    -- Remove widgets
    elseif len > #objects then
        for i = #objects * 2 + 1, len * 2, 2 do
            w[i] = nil
            w[i + 1] = nil
        end
    end

    -- update widgets text
    for k = 1, #objects * 2, 2 do
        local o = objects[(k + 1) / 2]
        if buttons then
            if not data[o] then
                data[o] = { }
                -- Replace press function by a new one calling with object as
                -- argument
                for kb, b in ipairs(buttons) do
                    -- Copy object
                    data[o][kb] = capi.button(b)
                    data[o][kb].press = function () b.press(o) end
                end
            end
            w[k]:buttons(data[o])
            w[k + 1]:buttons(data[o])
        end

        local text, bg, bg_image, icon = label(o)
        w[k + 1].text, w[k + 1].bg, w[k + 1].bg_image = text, bg, bg_image
        w[k].bg, w[k].image = bg, icon
        if not w[k + 1].text then
            w[k+1].visible = false
        else
            w[k+1].visible = true
        end
        if not w[k].image then
            w[k].visible = false
        else
            w[k].visible = true
        end
   end
end

local function taglist_update (screen, w, label, buttons, data, widgets)
    local tags = capi.screen[screen]:tags()

    list_update(w, buttons, label, data, widgets, tags)
end

--- Get the tag object the given widget appears on.
-- @param widget The widget the look for.
-- @return The tag object.
function taglist.gettag(widget)
    return tagwidgets[widget]
end

--- Create a new taglist widget.
-- @param screen The screen to draw tag list for.
-- @param label Label function to use.
-- @param buttons A table with buttons binding to set.
function taglist.new(screen, label, buttons)
    local w = {}
    local widgets = { }
    widgets.imagebox = { }
    widgets.textbox  = { ["margin"] = { ["left"]  = 0,
                                        ["right"] = 0},
                         ["bg_resize"] = true
                       }
    local data = otable()
    local u = function (s)
        if s == screen then
            taglist_update(s, w, label, buttons, data, widgets)
        end
    end
    local uc = function (c) return u(c.screen) end
    hooks.focus.register(uc)
    hooks.unfocus.register(uc)
    hooks.arrange.register(u)
    hooks.tags.register(u)
    hooks.tagged.register(uc)
    hooks.property.register(function (c, prop)
        if prop == "urgent" then
            u(c.screen)
        end
    end)
    -- Free data on tag removal
    hooks.tags.register(function (s, tag, action)
        if action == "remove" then data[tag] = nil end
    end)
    u(screen)
    return w
end

--- Return labels for a taglist widget with all tag from screen.
-- It returns the tag name and set a special
-- foreground and background color for selected tags.
-- @param t The tag.
-- @param args The arguments table.
-- bg_focus The background color for selected tag.
-- fg_focus The foreground color for selected tag.
-- bg_urgent The background color for urgent tags.
-- fg_urgent The foreground color for urgent tags.
-- squares_sel Optional: a user provided image for selected squares.
-- squares_unsel Optional: a user provided image for unselected squares.
-- squares_resize Optional: true or false to resize squares.
-- @return A string to print, a background color, a background image and a
-- background resize value.
function taglist.label.all(t, args)
    if not args then args = {} end
    local theme = beautiful.get()
    local fg_focus = args.fg_focus or theme.taglist_fg_focus or theme.fg_focus
    local bg_focus = args.bg_focus or theme.taglist_bg_focus or theme.bg_focus
    local fg_urgent = args.fg_urgent or theme.taglist_fg_urgent or theme.fg_urgent
    local bg_urgent = args.bg_urgent or theme.taglist_bg_urgent or theme.bg_urgent
    local taglist_squares_sel = args.squares_sel or theme.taglist_squares_sel
    local taglist_squares_unsel = args.squares_unsel or theme.taglist_squares_unsel
    local taglist_squares_resize = theme.taglist_squares_resize or args.squares_resize or "true"
    local font = args.font or theme.taglist_font or theme.font or ""
    local text = "<span font_desc='"..font.."'>"
    local sel = capi.client.focus
    local bg_color = nil
    local fg_color = nil
    local bg_image
    local icon
    local bg_resize = false
    if t.selected then
        bg_color = bg_focus
        fg_color = fg_focus
    end
    if sel and sel:tags()[t] then
        if taglist_squares_sel then
            bg_image = capi.image(taglist_squares_sel)
            bg_resize = taglist_squares_resize == "true"
        end
    else
        local cls = t:clients()
        if #cls > 0 and taglist_squares_unsel then
            bg_image = capi.image(taglist_squares_unsel)
            bg_resize = taglist_squares_resize == "true"
        end
        for k, c in pairs(cls) do
            if c.urgent then
                if bg_urgent then bg_color = bg_urgent end
                if fg_urgent then fg_color = fg_urgent end
                break
            end
        end
    end
    local taglist_squares = false
    if taglist_squares_sel or taglist_squares_unsel then
        taglist_squares = true
    end
    if t.name then
        if fg_color then
            text = text .. "<span color='"..util.color_strip_alpha(fg_color).."'>"
            if taglist_squares then
                text = text .. " "
            end
            text = text..util.escape(t.name).." </span>"
        else
            if taglist_squares then
                text = text .. " "
            end
            text = text .. util.escape(t.name) .. " "
        end
    elseif taglist_squares then
        text = text .. " "
    end
    text = text .. "</span>"
    --if tag.geticon(t) and type(tag.geticon(t)) == "image" then
        --icon = tag.geticon(t)
    --elseif tag.geticon(t) then
        --icon = capi.image(tag.geticon(t))
    --end

    return text, bg_color, bg_image, icon
end

--- Return labels for a taglist widget with all *non empty* tags from screen.
-- It returns the tag name and set a special
-- foreground and background color for selected tags.
-- @param t The tag.
-- @param args The arguments table.
-- bg_focus The background color for selected tag.
-- fg_focus The foreground color for selected tag.
-- bg_urgent The background color for urgent tags.
-- fg_urgent The foreground color for urgent tags.
-- @return A string to print, a background color, a background image and a
-- background resize value.
function taglist.label.noempty(t, args)
    if #t:clients() > 0 or t.selected then
        return taglist.label.all(t, args)
    end
end

local function tasklist_update(w, buttons, label, data, widgets)
    local clients = capi.client.get()
    local shownclients = {}
    for k, c in ipairs(clients) do
        if not (c.skip_taskbar or c.hide
            or c.type == "splash" or c.type == "dock" or c.type == "desktop") then
            table.insert(shownclients, c)
        end
    end
    clients = shownclients

    list_update(w, buttons, label, data, widgets, clients)
end

--- Create a new tasklist widget.
-- @param label Label function to use.
-- @param buttons A table with buttons binding to set.
function tasklist.new(label, buttons)
    local w = {}
    local widgets = { }
    widgets.imagebox = { ["align"]      = "flex" }
    widgets.textbox  = { ["align"]     = "flex",
                         ["margin"]    = { ["left"]  = 2,
                                           ["right"] = 2 },
                         ["bg_resize"] = true,
                         ["bg_align"]  = "right"
                       }
    local data = otable()
    local u = function () tasklist_update(w, buttons, label, data, widgets) end
    hooks.arrange.register(u)
    hooks.clients.register(u)
    hooks.tagged.register(u)
    hooks.focus.register(u)
    hooks.unfocus.register(u)
    hooks.property.register(function (c, prop)
        if prop == "urgent"
            or prop == "floating"
            or prop == "maximized_horizontal"
            or prop == "maximized_vertical"
            or prop == "icon"
            or prop == "name"
            or prop == "icon_name" then
            u()
        end
    end)
    u()
    -- Free data on unmanage
    hooks.unmanage.register(function (c) data[c] = nil end)
    return w
end

local function widget_tasklist_label_common(c, args)
    if not args then args = {} end
    local theme = beautiful.get()
    local fg_focus = args.fg_focus or theme.tasklist_fg_focus or theme.fg_focus
    local bg_focus = args.bg_focus or theme.tasklist_bg_focus or theme.bg_focus
    local fg_urgent = args.fg_urgent or theme.tasklist_fg_urgent or theme.fg_urgent
    local bg_urgent = args.bg_urgent or theme.tasklist_bg_urgent or theme.bg_urgent
    local fg_minimize = args.fg_minimize or theme.tasklist_fg_minimize or theme.fg_minimize
    local bg_minimize = args.bg_minimize or theme.tasklist_bg_minimize or theme.bg_minimize
    local floating_icon = args.floating_icon or theme.tasklist_floating_icon
    local font = args.font or theme.tasklist_font or theme.font or ""
    local bg = nil
    local text = "<span font_desc='"..font.."'>"
    local name
    local status_image
    --if client.floating.get(c) and floating_icon then
        --status_image = capi.image(floating_icon)
    --end
    if c.minimized then
        name = util.escape(c.icon_name) or util.escape("<untitled>")
    else
        name = util.escape(c.name) or util.escape("<untitled>")
    end
    if capi.client.focus == c then
        bg = bg_focus
        if fg_focus then
            text = text .. "<span color='"..util.color_strip_alpha(fg_focus).."'>"..name.."</span>"
        else
            text = text .. name
        end
    elseif c.urgent and fg_urgent then
        bg = bg_urgent
        text = text .. "<span color='"..util.color_strip_alpha(fg_urgent).."'>"..name.."</span>"
    elseif c.minimized and fg_minimize and bg_minimize then
        bg = bg_minimize
        text = text .. "<span color='"..util.color_strip_alpha(fg_minimize).."'>"..name.."</span>"
    else
        text = text .. name
    end
    text = text .. "</span>"
    return text, bg, status_image, c.icon
end

--- Return labels for a tasklist widget with clients from all tags and screen.
-- It returns the client name and set a special
-- foreground and background color for focused client.
-- It also puts a special icon for floating windows.
-- @param c The client.
-- @param screen The screen we are drawing on.
-- @param args The arguments table.
-- bg_focus The background color for focused client.
-- fg_focus The foreground color for focused client.
-- bg_urgent The background color for urgent clients.
-- fg_urgent The foreground color for urgent clients.
-- @return A string to print, a background color and a status image.
function tasklist.label.allscreen(c, screen, args)
    return widget_tasklist_label_common(c, args)
end

--- Return labels for a tasklist widget with clients from all tags.
-- It returns the client name and set a special
-- foreground and background color for focused client.
-- It also puts a special icon for floating windows.
-- @param c The client.
-- @param screen The screen we are drawing on.
-- @param args The arguments table.
-- bg_focus The background color for focused client.
-- fg_focus The foreground color for focused client.
-- bg_urgent The background color for urgent clients.
-- fg_urgent The foreground color for urgent clients.
-- @return A string to print, a background color and a status image.
function tasklist.label.alltags(c, screen, args)
    -- Only print client on the same screen as this widget
    if c.screen ~= screen then return end
    return widget_tasklist_label_common(c, args)
end

--- Return labels for a tasklist widget with clients from currently selected tags.
-- It returns the client name and set a special
-- foreground and background color for focused client.
-- It also puts a special icon for floating windows.
-- @param c The client.
-- @param screen The screen we are drawing on.
-- @param args The arguments table.
-- bg_focus The background color for focused client.
-- fg_focus The foreground color for focused client.
-- bg_urgent The background color for urgent clients.
-- fg_urgent The foreground color for urgent clients.
-- @return A string to print, a background color and a status image.
function tasklist.label.currenttags(c, screen, args)
    -- Only print client on the same screen as this widget
    if c.screen ~= screen then return end
    for k, t in ipairs(capi.screen[screen]:tags()) do
        if t.selected and c:tags()[t] then
            return widget_tasklist_label_common(c, args)
        end
    end
end

--- Create a button widget. When clicked, the image is deplaced to make it like
-- a real button.
-- @param args Standard widget table arguments, plus image for the image path or
-- the image object.
-- @return A textbox widget configured as a button.
function button(args)
    if not args or not args.image then return end
    local img_release
    if type(args.image) == "string" then
        img_release = capi.image(args.image)
    elseif type(args.image) == "image" then
        img_release = args.image
    else
        return
    end
    local img_press = img_release:crop(-2, -2, img_release.width, img_release.height)
    args.type = "imagebox"
    local w = capi.widget(args)
    w.image = img_release
    w:buttons({ capi.button({}, 1, function () w.image = img_press end, function () w.image = img_release end) })
    function w.mouse_leave(s) w.image = img_release end
    function w.mouse_enter(s) if capi.mouse.coords().buttons[1] then w.image = img_press end end
    return w
end

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
