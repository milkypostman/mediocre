require("mediocre")

local screens = mediocre.screens
local terminal = "urxvtc"
local browser = "firefox"

mediocre.util.debug("RC LOADING")
mediocre.util.debug(#screens)
for i = 1, #screens do
    mediocre.util.debug("Initializing Tags")
    screens[i]:add(mediocre.Tag("1:main", {.7, .3}))
    screens[i]:add(mediocre.Tag("2:www"))
end

--- bindings
local mod = {}
mod.alt = {"Mod1"}
mod.super = {"Mod4"}
mod.shift = {"Shift"}
mod.control = {"Control"}

mod.super_alt = {mod.super[1], mod.alt[1]}
mod.super_shift = {mod.super[1], mod.shift[1]}
mod.super_control = {mod.super[1], mod.control[1]}
mod.control_alt = {mod.control[1], mod.alt[1]}
mod.control_shift = {mod.control[1], mod.shift[1]}
mod.control_alt_shift = {mod.control[1], mod.alt[1], mod.shift[1]}
mod.shift_alt = {mod.shift[1], mod.alt[1]}

function spawn(cmd, screen)
    if cmd and cmd ~= "" then
        return awesome.spawn(cmd .. "&", screen or mouse.screen)
    end
end

local bindings = {}
bindings.global = {
    [{  mod.super, "Return"}] = function() spawn(terminal) end,
    [{  mod.super, "f"}] = function() spawn(browser) end,
    [{ mod.super_control, "r" }] = mediocre.restart,
    [{ mod.super, "h" }] = mediocre.left,
    [{ mod.super, "l" }] = mediocre.right,
    [{ mod.super, "j" }] = mediocre.down,
    [{ mod.super, "k" }] = mediocre.up,
    [{ mod.super_control, "h" }] = mediocre.move_left,
    [{ mod.super_control, "l" }] = mediocre.move_right,
    [{ mod.super_control, "j" }] = mediocre.move_down,
    [{ mod.super_control, "k" }] = mediocre.move_up,
    [{ mod.super, "s" }] = function() mediocre.set_layout(mediocre.layout.max) end,
    [{ mod.super, "d" }] = function() mediocre.set_layout(mediocre.layout.divide) end,
}

local keys = {}
for mod, f in pairs(bindings.global) do
    table.insert( keys, key( mod[1], mod[2], f ) )
end

--root.buttons(milkbox.buttons.root)
root.keys(keys)


mediocre.hooks.mouse_enter.register(function (c)
        mediocre.client.focus(c)
end)

