local tm = require("tilemap")

local N = 1
local S = 2
local W = 3
local E = 4

local rows = tonumber(arg[1])
local cols = tonumber(arg[2])
--local start_col = tonumber(arg[3])
local export_file = arg[3]

math.randomseed(os.time())

local function init_maze(rows, cols)
    local maze = {}

    local max_rows = rows*2+1
    local max_cols = cols*2+1

    for r = 1,max_rows do
        maze[r] = {}
        for c = 1,max_cols do
            if (r == 1) and (c == 1)  then
                maze[r][c] = tm.NW_WALL
            elseif (r == 1) and (c == max_cols)  then
                maze[r][c] = tm.NE_WALL
            elseif (r == max_rows) and (c == 1)  then
                maze[r][c] = tm.SW_WALL
            elseif (r == max_rows) and (c == max_cols)  then
                maze[r][c] = tm.SE_WALL
            elseif (r == 1 or r == max_rows) then
                maze[r][c] = tm.H_WALL
            elseif (c == 1 or c == max_cols) then
                maze[r][c] = tm.V_WALL
            elseif (r % 2 == 1 or c % 2 == 1) then
                maze[r][c] = tm.WALL
            else
                maze[r][c] = tm.UNVISITED
            end
        end
    end

    return maze
end

local function shuffleTable( t )
    local rand = math.random 
    assert( t, "shuffleTable() expected a table, got nil" )
    local iterations = #t
    local j
    
    for i = iterations, 2, -1 do
        j = rand(i)
        t[i], t[j] = t[j], t[i]
    end
end

local function create_maze_recursive_backtracker(maze, cur_row, cur_col)
    local rows, cols = #maze, #maze[1]
    -- Mark this cell as visited
    maze[cur_row][cur_col] = tm.VISITED

    -- Get randomly sorted list of directions
    local directions = { N, S, W, E }
    shuffleTable(directions)

    for i = 1,#directions do
        local dir = directions[i]

        --
        -- Get coords for the wall in the selected direction
        --
        local wall_row = cur_row
        local wall_col = cur_col
        local next_row = cur_row
        local next_col = cur_col

        if (dir == N) then
            wall_row = wall_row - 1 
            next_row = wall_row - 1
        elseif (dir == S) then
            wall_row = wall_row + 1 
            next_row = wall_row + 1 
        elseif (dir == W) then
            wall_col = wall_col - 1 
            next_col = wall_col - 1 
        else
            wall_col = wall_col + 1 
            next_col = wall_col + 1 
        end

	--print(" cur row", cur_row,  " cur col", cur_col)
	--print("next row", next_row, "next col", next_col)
	--print("wall row", wall_row, "wall col", wall_col)
    --export_maze(maze)

        if tm.isWall(maze[wall_row][wall_col]) then

            if (next_row > 0 and next_row <= rows) and (next_col > 0 and next_col <= cols) then
                if maze[next_row][next_col] == tm.UNVISITED then

                    if (wall_col == next_col) then
                        maze[wall_row][wall_col] = tm.V_PASS -- Turn wall into passage
                    else
                        maze[wall_row][wall_col] = tm.H_PASS -- Turn wall into passage
                    end

                    create_maze_recursive_backtracker(maze, next_row, next_col)
                end
            end

        end
    end
end


local function export_maze(maze, outfile)
    local f, errmsg

    if (outfile == nil) then
        f = io.stdout
    else
        f, errmsg = io.open(export_file, "w")
    end

    if f == nil then
        error(errmsg)
    end

    f:write("local maze = {\n")

    local rows = #maze
    local cols = #maze[1]
    
    for r = 1,rows do
        f:write("  {")
        for c = 1,#maze[r] do
            if (maze[r][c] < 10) then
                f:write(string.format(" %d,", maze[r][c]))
            else 
                f:write(string.format("%d,", maze[r][c]))
            end
            --f:write(maze[r][c], ",")
        end
        f:write(" },\n")
    end

    f:write("}\n")
    f:write("\nreturn maze")
    f:flush()
    f:close()
end


local function show_maze_ascii(m)
    io.write(" ")
    print(string.rep("_", #m[1]-2))

    for r = 1,#m do
        if (r % 2 == 0) then
            io.write("|")
            for c = 1,#m[r] do
                if (c % 2 == 0) then
                    if tm.isWall(m[r+1][c]) then -- south wall
                        io.write("_")    
                    else
                        io.write(" ")    
                    end

                    if tm.isWall(m[r][c+1]) then -- east wall
                        io.write("|")    
                    else 
                        --if not is_wall(m[r+1][c+1]) or not is_wall(m[r][c+2]) then
                        --if is_wall(m[r+1][c+1]) and not is_wall(m[r+1][c+2]) then
                        if tm.isWall(m[r+1][c+1]) and tm.isWall(m[r+1][c+2]) then
                            io.write("_")
                        else
                            io.write(" ")
                        end
                    end
                end
            end
            print()
        end
    end
end

local maze = init_maze(rows, cols)
--export_maze(maze)
create_maze_recursive_backtracker(maze, 2, 2)
show_maze_ascii(maze)
io.write("Export to file? [y/n]: ")
local response = io.read()

if response == "y" then
    print("exporting to", export_file)
    export_maze(maze, export_file)
end
