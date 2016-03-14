--
-- Generic test theme the draws every wall as a box/crate
--
local tm = require("tilemap")

local theme = {

    [tm.NW_WALL] = "crate.png",
    [tm.SW_WALL] = "crate.png",
    [tm.NE_WALL] = "crate.png",
    [tm.SE_WALL] = "crate.png",
    [tm.V_WALL]  = "crate.png",
    [tm.H_WALL]  = "crate.png",
    [tm.WALL]    = "crate.png",

    -- Passages
    [tm.NW_PASS] = nil,
    [tm.SW_PASS] = nil,
    [tm.NE_PASS] = nil,
    [tm.SE_PASS] = nil,
    [tm.V_PASS]  = nil,
    [tm.H_PASS]  = nil,
}

return theme
