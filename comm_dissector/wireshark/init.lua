disable_lua = false

-- Change dji_script_path to point to the directory where you have copied
-- the Lua scripts. Do not place them in the Wireshark Lua directory.
-- Please see the README file for more information.
-- This path should be an absolute path and end with a "/"
--
-- Linux/MacOS example:
--   local dji_script_path = "/path/to/scripts/"
-- Windows example:
--   local dji_script_path = "C:\\path\\to\\scripts\\"

-- Auto-detect the real path of this script, resolving symlinks via package.
-- Falls back to the symlink location (unreliable) or CWD if detection fails.
local function script_dir()
    -- Try to get the real source path via debug info
    local src = debug.getinfo(1, 'S').source
    if src:sub(1,1) == '@' then
        local path = src:sub(2)
        -- Resolve symlink on POSIX
        local resolved = io.popen('readlink -f "' .. path .. '" 2>/dev/null'):read('*l')
        if resolved and resolved ~= '' then
            return resolved:match("^(.+[\\/])") or ""
        end
        return path:match("^(.+[\\/])") or ""
    end
    return ""
end

local dji_script_path = script_dir()

local function dofile_if_exists(path)
    local f = io.open(path, 'r')
    if f then
        f:close()
        dofile(path)
    end
end

dofile(dji_script_path .. 'dji-dumlv1-proto.lua')

-- Extended DUML dissectors with additional command parsing
dofile_if_exists(dji_script_path .. 'dji-dumlv1-flyc-ext.lua')
dofile_if_exists(dji_script_path .. 'dji-dumlv1-camera-ext.lua')
dofile_if_exists(dji_script_path .. 'dji-dumlv1-gimbal-ext.lua')
dofile_if_exists(dji_script_path .. 'dji-dumlv1-battery-ext.lua')
dofile_if_exists(dji_script_path .. 'dji-dumlv1-hdlink-ext.lua')

dofile(dji_script_path .. 'dji-p3-flyrec-proto.lua')
dofile(dji_script_path .. 'dji-p3-batt-proto.lua')
dofile(dji_script_path .. 'dji-p3.lua')

dofile(dji_script_path .. 'dji-mavic-flyrec-proto.lua')
dofile(dji_script_path .. 'dji-mavic.lua')

dofile(dji_script_path .. 'dji-spark-flyrec-proto.lua')
dofile(dji_script_path .. 'dji-spark.lua')

dofile(dji_script_path .. 'dji-write-kml.lua')
