local process_md = {}

function process_md.get_file_content(path)
    local f, err = io.open(path, "r+")
    assert(f, err)

    local content = f:read("*a")

    f:close()
    return content
end

function process_md.get_web_imgs_path(str)
    local urls = {}

    for link in string.gmatch(str, '!%[[^%]]*%]%((http[^%)]+)%)') do
        table.insert(urls, link)
    end

    return urls
end

function process_md.replace_paths(str, dict)
    for key, value in pairs(dict) do
        str = string.gsub(str, key, value)
    end

    return str
end

function process_md.get_header(content, filename, upload)
    local first_line = content:match('([^\n]-)\n')

    local header
    if first_line then
        header = first_line:match("# (.*)")
    end

    if not header then
        return content, filename:match('/([^/]-).md$'):gsub(' ', '_')
    else
        if upload then
            content = process_md.remove_first_line(content)
        end
        return content, header:gsub(' ', '_')
    end
end

function process_md.remove_first_line(content)
    return content:match('[^\n]-\n+(.*)')
end

function process_md.save_document(dest, header, content)
    local filename = dest .. '/' .. header .. '.md'

    local output_file = io.open(filename, "w")
    if not output_file then
        error("Couldn't open output file: " .. filename)
    end

    output_file:write(content)
    output_file:close()
end

return process_md
