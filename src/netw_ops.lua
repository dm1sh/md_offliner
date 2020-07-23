local netw_ops = {}
local https = require("ssl.https")
local http = require("socket.http")

function netw_ops.download_to(url, output)
    local res = os.execute('mkdir -p "' .. output .. '"')

    if not res then
        error("Couldn't create output directory " .. output)
    end

    local filename = netw_ops.get_file_name(url)
    if not filename then
        error("Wrong url, if it is really an image, try to download it on your own: " .. url)
    end

    local response, code
    local _
    if url:match("^https://") then
        response, code, _, _ = https.request(url)
    else
        response, code, _, _ = http.request(url)
    end

    local ofile, err
    if code == 200 then
        ofile, err = io.open(output .. '/' .. filename, "wb")
    else
        error("Error downloading file. Server returned " .. code .. ' code')
    end

    if not ofile then
        error(err, 2)
    end

    ofile:write(response)
    ofile:close()

    return './' .. filename
end

function netw_ops.get_file_name(str)
    return str:match("/([^/]*)$")
end

function netw_ops.scp_wrap(from_path, to_path)
    return os.execute('scp -prq ' .. from_path .. ' ' .. to_path)
end

function netw_ops.upload_dir(local_path, server_cred, server_path)
    os.execute('ssh ' .. server_cred .. ' "rm -rf ' .. server_path .. '"')
    local res = netw_ops.scp_wrap(local_path .. '/', server_cred .. ':' .. server_path .. '/')

    if res then
        return res
    else
        error("Could't upload directory to server " .. server_cred)
    end
end

function netw_ops.download_db(server_cred, server_path, local_path)
    local res = netw_ops.scp_wrap(server_cred .. ':' .. server_path .. 'list.db', local_path)

    if res then
        return res
    else
        error("Could't download server" .. server_cred .. " articles database")
    end
end

function netw_ops.insert_article(local_path, document_name)
    local lines = ''
    local not_in = true
    local new_line = math.floor(os.time()) .. ' ' .. document_name
    local file_name = local_path .. '/list.db'
    local file = io.open(file_name, 'r')

    for line in file:lines() do
        if line:find(document_name) then
            line = new_line
            not_in = false
        end
        lines = lines .. (lines:len() > 0 and '\n' or '') .. line
    end

    if not_in then
        lines = lines .. (lines:len() > 0 and '\n' or '') .. new_line
    end

    file:close()
    file = io.open(file_name, 'w')
    file:write(lines)

    file:close()
end

function netw_ops.upload_db(server_cred, server_path, local_path)
    local res = netw_ops.scp_wrap(local_path .. '/' .. 'list.db', server_cred .. ':' .. server_path)

    if res then
        return res
    else
        error("Could't upload server " .. server_cred .. " articles database")
    end
end

return netw_ops
