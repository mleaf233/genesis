SMODS.current_mod.optional_features = function()
    return {
        retrigger_joker = true,
    }
end

local NFS = SMODS.NFS
local mod_path = SMODS.current_mod.path or ''
if mod_path:sub(-1) ~= '/' then
    mod_path = mod_path .. '/'
end

local function collect_lua_files(dir, files)
    local abs_dir = mod_path .. dir
    local info = NFS.getInfo(abs_dir)
    if not info or info.type ~= 'directory' then
        return
    end

    for _, item in ipairs(NFS.getDirectoryItems(abs_dir)) do
        local rel_path = dir .. item
        local abs_path = mod_path .. rel_path
        local item_info = NFS.getInfo(abs_path)

        if item_info and item_info.type == 'directory' then
            collect_lua_files(rel_path .. '/', files)
        elseif item_info and item_info.type == 'file' and item:match('%.lua$') then
            files[#files + 1] = rel_path
        end
    end
end

local function load_folder(dir)
    local files = {}
    collect_lua_files(dir, files)
    table.sort(files)

    for _, file in ipairs(files) do
        assert(SMODS.load_file(file))()
    end
end

local src_dir = mod_path .. 'src/'
local src_info = NFS.getInfo(src_dir)
if src_info and src_info.type == 'directory' then
    local folders = {}

    for _, item in ipairs(NFS.getDirectoryItems(src_dir)) do
        local item_info = NFS.getInfo(src_dir .. item)
        if item_info and item_info.type == 'directory' and not item:match('^_') then
            folders[#folders + 1] = 'src/' .. item .. '/'
        end
    end

    table.sort(folders)
    for _, folder in ipairs(folders) do
        load_folder(folder)
    end
end
