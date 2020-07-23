local utils = {}

local assets_dir = './spec/assets/'

function utils.list_dir(path)
    local files = {}
    local pfile = io.popen('ls -a "' .. path .. '"')
    for file in pfile:lines() do
        table.insert(files, file)
    end

    return files
end

function utils.clean_assets(files)
    local am = 0
    for _, file in ipairs(files) do
        os.execute('rm -rf ' .. assets_dir .. file)
        am = am + 1
    end

    return am
end

function utils.copy_file(from_path, dest_path)
    local from, dest = io.open(from_path, 'r'), io.open(dest_path, 'w')

    dest:write(from:read('a'))

    from:close()
    dest:close()
end

return utils
