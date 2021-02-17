require 'mp.options'
local opt = {
    active = false,
    patterns = {
        "OP","[Oo]pening$", "^[Oo]pening:", "[Oo]pening [Cc]redits",
        "ED","[Ee]nding$", "^[Ee]nding:", "[Ee]nding [Cc]redits",
        "[Pp]review$",
    },
}
read_options(opt)

function check_chapter(_, chapter)
    if not chapter then
        return
    end
    for _, p in pairs(opt.patterns) do
        if string.match(chapter, p) then
            print("Skipping chapter:", chapter)
            mp.command("no-osd add chapter 1")
            return
        end
    end
end

function activation()
    if opt.active then
        mp.observe_property("chapter-metadata/by-key/title", "string", check_chapter)
        mp.osd_message("Skip-chapters activate")
    else
        mp.unobserve_property(check_chapter)
        mp.osd_message("Skip-chapters deactivate")
    end
    return opt.active
end

var = opt.active and activation();

mp.add_key_binding(nil, "toggle", function() opt.active = not opt.active; activation() end)