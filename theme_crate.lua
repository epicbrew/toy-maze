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
    [tm.NW_PASS] = "crate.png",
    [tm.SW_PASS] = "crate.png",
    [tm.NE_PASS] = "crate.png",
    [tm.SE_PASS] = "crate.png",
    [tm.V_PASS]  = "crate.png",
    [tm.H_PASS]  = "crate.png",
}

return theme
