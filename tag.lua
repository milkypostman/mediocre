---------------------------------------------------------------------------
-- @author Donald Ephraim Curtis &lt;dcurtis@cs.uiowa.edu&gt;
-- @copyright 2009 Donald Ephraim Curtis
-- @release @AWESOME_VERSION@
---------------------------------------------------------------------------

local ipairs = ipairs
local otable = otable
local table = table
local tostring = tostring
local math = math

local capi = {
    tag = tag
}

local util = require("mediocre.util")
local group = require("mediocre.group")
local layout = require("mediocre.layout")

module("mediocre.tag")

Tag = util.class(function(klass, name, ratios )
    klass.groups = {[0]=group.Group(klass, layout.floating)}
    klass.current = 1
    klass.name = name
    klass.ratios = ratios or {}
    klass.screen = nil
    klass.tag = capi.tag(name)
end
)

function Tag:group(idx)
    local idx = idx or self.current
    return self.groups[idx]
end

function Tag:add(g, idx)
    local idx = idx or self.current
    table.insert(self.groups, idx, g)
end

function Tag:remove(grp)
    -- make sure not to use group 0
    -- floating group always exists
    for i = 1, #self.groups do
        local g = self.groups[i]
        if g == grp then
            table.remove(self.groups, i)
            break
        end
    end
    if #self.groups ~= 0 and self.current > #self.groups then
        self.current = #self.groups
    end
    util.debug("grp:" .. tostring(self.current))
end

function Tag:set(grp)
    for i,g in ipairs(self.groups) do
        if g == grp then
            self.current = i
            break
        end
    end
end


function Tag:move(dir)
    local oldidx = self.current
    local og = self.groups[oldidx]

    local c = og:client()

    local nextidx = oldidx + dir
    local ng = self.groups[nextidx]

    if nextidx < 1 then
        nextidx = 1
    end

    if not ng then
        ng = group.Group(self)
        self:add(ng, nextidx)
    end

    og:remove(c)
    ng:add(c)

    self.current = nextidx
end

function Tag:arrange(wa)
    local geom = {}
    geom.x = wa.x
    geom.y = wa.y
    geom.height = wa.height
    local total = 0
    local ratio
    for i = 1, #self.groups do
        ratio = self.ratios[i] or 1/#self.groups
        total = total + ratio
    end
    local used = 0
    for i = 1, #self.groups do
        local g = self.groups[i]
        local ratio = self.ratios[i] or 1/#self.groups
        ratio = ratio / total
        geom.x = used
        geom.y = wa.y
        geom.height = wa.height
        geom.width = math.floor(wa.width * ratio)
        used = used+geom.width
        -- g is our group
        g.layout(g, geom)
    end
    if self.current == 0 then
        local f = self.groups[0]
        f.layout(f, nil)
    end
end

function Tag:move_next()
    self:move(1)
end

function Tag:move_prev()
    self:move(-1)
end

function Tag:next()
    self.current = (self.current) % #self.groups + 1
end

function Tag:prev()
    self.current = (self.current-2) % #self.groups + 1
end


-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
