local Arguments = require("src.arg_proc")
local ProcessMD = require("src.process_md")
local NetwOps = require("src.netw_ops")

local function get_document_info(filename, upload)
    local status, content = pcall(ProcessMD.get_file_content, filename)
    if not status then
        print('Error: ' .. content)
        os.exit(1)
    end

    local document_name
    content, document_name = ProcessMD.get_header(content, upload)

    local urls = ProcessMD.get_web_imgs_path(content)

    return document_name, content, urls
end

local function compose_document_destination_folder(upload, path, document_name)
    if upload or not path then
        path = './'
    end
    path = path .. document_name

    return path
end

local function download_netw_assets(urls, dest)
    local dict = {}
    for _, path in ipairs(urls) do
        local status, res_file = pcall(NetwOps.download_to, path, dest)
        if not status then
            print('Error: ' .. res_file)
            os.exit(1)
        end

        dict[path] = res_file
    end
    return dict
end

local function upload_to_server(local_article_directory, server_cred, server_path, document_name)
    local status, err = pcall(NetwOps.upload_dir, local_article_directory, server_cred, server_path .. document_name)
    if not status then
        print('Error: ' .. err)
        os.exit(1)
    end

    local status, err = pcall(NetwOps.download_db, server_cred, server_path, local_article_directory)
    if not status then
        print('Error: ' .. err)
        os.exit(1)
    end

    NetwOps.insert_article(local_article_directory, document_name)

    local status, err = pcall(NetwOps.upload_db, server_cred, server_path, local_article_directory)
    if not status then
        print('Error: ' .. err)
        os.exit(1)
    end

    os.execute('rm -rf "' .. local_article_directory .. '"')
end

local params = Arguments.parse()

local document_name, content, urls = get_document_info(params.input, params.upload)

local local_article_directory = compose_document_destination_folder(params.upload, params.output, document_name)

local dict = download_netw_assets(urls, local_article_directory)

content = ProcessMD.replace_paths(content, dict)

local status, err = pcall(ProcessMD.save_document, local_article_directory, document_name, content)
if not status then
    print('Error: ' .. err)
    os.exit(1)
end

if params.upload then
    upload_to_server(local_article_directory, params.server, params.output, document_name)
end
