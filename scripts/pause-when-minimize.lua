-- This script pauses playback when minimizing the window, and resumes playback
-- if it's brought back again. If the player was already paused when minimizing,
-- then try not to mess with the pause state.

-- disabled when vid=no.

local options = require("mp.options")

local opts = {
    rmp = false
}
options.read_options(opts)

local did_minimize = false

if opts.rmp then return end
mp.observe_property("window-minimized", "bool", function(name, value)
    local pause = mp.get_property_native("pause")
    local continuous = mp.get_property_native("keep-open")
    if value == true then
        mp.set_property_native("keep-open", "always")
        if pause == false then
            if mp.get_property("vid") ~= "no" then
                mp.set_property_native("pause", true)
            end
            did_minimize = true
        end
    elseif value == false then
        mp.set_property_native("keep-open", continuous)
        if did_minimize and (pause == true) then
            if mp.get_property("vid") ~= "no" then
                mp.set_property_native("pause", false)
            end
            did_minimize = false
        end
    end
end)