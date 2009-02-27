---------------------------------------------------------------------------
-- @author Donald Ephraim Curtis &lt;dcurti@gmail.com&gt;
-- @copyright 2009 Donald Ephraim Curtis
-- @copyright 2008 Julien Danjou
-- @release @AWESOME_VERSION@
---------------------------------------------------------------------------

local setmetatable = setmetatable
local io = io
local loadfile = loadfile

--- Utility module for mediocre
module("mediocre.util")

-- simple class generator with no inheritance
function class(fn)
    local c = {}
    c.__index = c
    local mt = {}
    mt.__call = function(_, ...)
        local o = {}
        if fn then
            fn(o, ...)
        end
        setmetatable(o, c)
        return o
    end

    return setmetatable(c, mt)
end

function debug(text)
    io.stderr:write(text.."\n")
end

function checkfile(path)
    local f, e = loadfile(path)
    -- Return function if function, otherwise return error.
    if f then return f end
    return e
end

--: utility functions
function set_bg(color, text)
    return '<bg color="'..color..'" />'..text
end

function set_fg(color, text)
    return '<span color="'..color..'">'..text..'</span>'
end

function set_bg_fg(bgcolor, fgcolor, text)
    return '<bg color="'..bgcolor..'" /><span color="'..fgcolor..'">'..text..'</span>'
end

function set_font(font, text)
    return '<span font_desc="'..font..'">'..text..'</span>'
end

function color_strip_alpha(color)
    if color:len() == 9 then
        color = color:sub(1, 7)
    end
    return color
end

local xml_entity_names = { ["'"] = "&apos;", ["\""] = "&quot;", ["<"] = "&lt;", [">"] = "&gt;", ["&"] = "&amp;" };
--- Escape a string from XML char.
-- Useful to set raw text in textbox.
-- @param text Text to escape.
-- @return Escape text.
function escape(text)
    return text and text:gsub("['&<>\"]", xml_entity_names) or nil
end

local xml_entity_chars = { lt = "<", gt = ">", nbsp = " ", quot = "\"", apos = "'", ndash = "-", mdash = "-", amp = "&" };
--- Unescape a string from entities.
-- @param text Text to unescape.
-- @return Unescaped text.
function unescape(text)
    return text and text:gsub("&(%a+);", xml_entity_chars) or nil
end

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
