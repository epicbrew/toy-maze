
local tilemap = {

    -- Walls
    NW_WALL = 1,
    SW_WALL = 2,
    NE_WALL = 3,
    SE_WALL = 4,
    V_WALL = 5,
    H_WALL = 6,
    WALL = 7, -- generic wall

    -- Passages
    NW_PASS = 8,
    SW_PASS = 9,
    NE_PASS = 10,
    SE_PASS = 11,
    V_PASS = 12,
    H_PASS = 13,

    -- Only used in creator.
    VISITED = 14,
    UNVISITED = 15,
}

tilemap.isWall = function (val)
    return val < tilemap.NW_PASS
end

return tilemap
