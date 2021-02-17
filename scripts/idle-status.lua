-- Toggle status msg when pause.
-- by @absummer

local options = require "mp.options"
local msg = require "mp.msg"

local opts = {
    enable = false,
    rmp = false
}
options.read_options(opts)

local enabled = opts.enable
local osd_level = mp.get_property_native("osd-level")
local osd_level_a = 2
local osd_level_p = 3

function on_osd_level(name, value)
    if not mp.get_property_bool("core-idle") then
        if mp.get_property("vid") ~= "no" then
            osd_level = value
        else
            osd_level_a = value
        end
    end
    if value == 0 then
        mp.set_property_native("osd-level", 1)
        if osd_level == 0 then osd_level = 1 end
        if osd_level_a == 0 then osd_level_a = 1 end
    end
    msg.debug("on_osd_level | osd_level: " .. osd_level .. ", _a: " .. osd_level_a .. ", _p: " .. osd_level_p)
end

function on_core_idle(name, value)
    if value then
        mp.set_property_native("osd-level", osd_level_p)
    elseif mp.get_property("vid") ~= "no" then
        if mp.get_property_native("osd-level") == 1 then
            osd_level = 1
        end
        mp.set_property_native("osd-level", osd_level)
    else
        if mp.get_property_native("osd-level") == 1 then
            osd_level_a = 1
        end
        mp.set_property_native("osd-level", osd_level_a)
    end
    msg.debug("on_core_idle | osd_level: " .. osd_level .. ", _a: " .. osd_level_a .. ", _p: " .. osd_level_p)
end

function on_osd(name, value)
    if value >= 2 then
        osd_level_p = value
    else
        osd_level_p = 3
    end
    msg.debug("on_osd | osd_level: " .. osd_level .. ", _a: " .. osd_level_a .. ", _p: " .. osd_level_p)
end
function on_osc(name, value)
    if not value and mp.get_property_bool("core-idle") then
        osd_level = 1
    end
    msg.debug("on_osc | osd_level: " .. osd_level .. ", _a: " .. osd_level_a .. ", _p: " .. osd_level_p)
end -- for {high-quality} and {image-viewer}
function on_aid(name, value)
    if value ~= "no" and mp.get_property("vid") == "no" then
        mp.set_property_native("osd-level", osd_level_a)
    end
    msg.debug("on_vid | osd_level: " .. osd_level .. ", _a: " .. osd_level_a .. ", _p: " .. osd_level_p)
end
function on_vid(name, value)
    if value == "no" then
        osd_level_a = 2; mp.set_property_native("osd-level", osd_level_a)
    else
        mp.set_property_native("osd-level", osd_level)
    end
    msg.debug("on_aid | osd_level: " .. osd_level .. ", _a: " .. osd_level_a .. ", _p: " .. osd_level_p)
end

function pause_status()
    if enabled then
        mp.observe_property("osd-level", "native", on_osd)
        -- mp.observe_property("osc",       "bool",   on_osc)
        mp.observe_property("aid",       "string", on_aid)
        mp.observe_property("vid",       "string", on_vid)
        mp.observe_property("osd-level", "native", on_osd_level)
        -- mp.observe_property("core-idle", "bool",   on_core_idle)
    else
        mp.unobserve_property(on_osd)
        -- mp.unobserve_property(on_osc)
        mp.unobserve_property(on_aid)
        mp.unobserve_property(on_vid)
        mp.unobserve_property(on_osd_level)
        -- mp.unobserve_property(on_core_idle)
    end
end

if enabled then pause_status() end

--[[mp.observe_property("osd-level", "number", function(name, value)
    if value > 1 then
        mp.set_property_native("osd-on-seek", "bar")
    else
        mp.set_property_native("osd-on-seek", "msg")
    end
end)
mp.observe_property("fullscreen", "bool", function(name, value)
    mp.osd_message(" ")
end)
]]
--[[ mp.observe_property("pause", "bool", function(name, value)
    if value then
        mp.add_timeout(0.16, function() mp.command("osd-msg show-progress") end)
    else
        mp.command("osd-msg show-progress")
    end
end) ]]
-- mp.observe_property("eof-reached", "bool", function(name, value)
--     mp.osd_message(" ")
-- end)

mp.observe_property("chapter", "number", function(name, value)
    if mp.get_property_number("chapter") ~= nil then
        local str = "Chapter: (" .. mp.get_property_number("chapter") + 1 ..
                    "/" .. mp.get_property_number("chapter-list/count") ..
                    ") " .. mp.get_property("chapter-list/" ..
                    mp.get_property("chapter") .. "/title", "")
        msg.verbose(str .. " @ " .. mp.get_property("chapter-list/" ..
                    mp.get_property("chapter") .. "/time", ""))
        mp.osd_message(str)
    end
end)
mp.observe_property("volume", "number", function()
    local vol = mp.get_property_number("volume")
    if vol ~= 100 then
        local message = "Volume: " .. vol .. "% | " ..
            ((vol > 100) and "+" or "") ..
            ((vol == 0) and "∞" or string.format("%0.5f",
                math.log10(math.pow(vol/100, 3)) * 20) .. " dB") ..
            (mp.get_property_bool("mute") and " (Muted)" or "")
        msg.debug(message)
        mp.osd_message(message)
    end
end)

if opts.rmp then
    mp.add_hook("on_load", 50, function()
        local path = mp.get_property("path")
        local playlist_pos_1 = mp.get_property("playlist-pos-1")
        local playlist_count = mp.get_property("playlist-count")
        if mp.get_property_number("playlist/count", 0) >= 2 then
            msg.verbose(playlist_pos_1, "/", playlist_count)
        end
    end)
    mp.observe_property("load-stats-overlay", "bool", function(name, value)
        local termosd = value and mp.get_property_bool("vo-configured")
        mp.set_property("term-osd", termosd and "auto" or "force")
    end)
    mp.observe_property("vo-configured", "bool", function(name, value)
        local termosd = value and mp.get_property_bool("load-stats-overlay")
        mp.set_property("term-osd", termosd and "auto" or "force")
    end)
end
mp.register_event("playback-restart", function()
    if mp.get_property_bool("audio-exclusive") then
        msg.warn("Exclusive Audio Output")
    end
end)
mp.observe_property("audio-exclusive", "bool", function(name, value)
    if value then msg.warn("Exclusive Audio Output") end
end)

--[[mp.observe_property("vo-configured", "bool", function(name, value)
    mp.commandv("change-list", "script-opts", "set",
                "stats/persistent_overlay=" .. (value and "yes" or "no"))
    msg.verbose("stats/persistent_overlay=" ..
                mp.get_opt("stats/persistent_overlay"))
end)]]
local fraction = mp.get_property_bool("osd-fractions")
-- local framestep = false
--[[ mp.observe_property("osd-fractions", "bool", function(name, value)
    if not mp.get_property_bool("pause") then
        fraction = value
    end
end) ]]
--[[ function step_fraction()
    framestep = true
    mp.set_property_bool("osd-fractions", true)
    mp.add_timeout(0.16, function() framestep = false end)
end
mp.add_key_binding(nil, "step", function()
    mp.command("frame-step")
    step_fraction()
end)
mp.add_key_binding(nil, "backstep", function()
    mp.command("frame-back-step")
    step_fraction()
end) ]]
mp.register_script_message('switch-ms', function()
    fraction = not fraction
    mp.set_property_bool("osd-fractions", mp.get_property_bool("core-idle") or fraction)
    mp.osd_message("osd-fraction(non-idle): " .. (fraction and "yes" or "no"))
end)
mp.observe_property("core-idle", "bool", function(name, value)
    mp.set_property_bool("osd-fractions", fraction or value)
    -- mp.command(value and 'osd-msg show-progress' or 'show-text ""')
end)
mp.add_key_binding(nil, "pause", function()
    if mp.get_property_bool("eof-reached") then
        msg.debug("EOF seek: 0%")
        mp.command("no-osd seek 0 absolute-percent")
    end
    mp.command("cycle pause")
    -- framestep = false
    -- mp.set_property_bool('osd-fractions', fraction or mp.get_property_bool("pause"))
end)
--[[mp.add_key_binding(nil, "pause", function()
    mp.command("cycle pause")
    msg.debug("cycled pause")
    -- if mp.get_property_bool("pause") then
        -- mp.command("osd-msg-bar show-progress")
    -- else
    -- mp.command("osd-msg show-progress")
    -- mp.add_timeout(0.16, function() mp.command("osd-msg show-progress") end)
    -- end
end)]]
-- mp.add_key_binding(nil, "mpv-status-auto", function() enabled = true; pause_status() end)
-- mp.add_key_binding(nil, "mvi-status-off", function() enabled = false; pause_status() end)
