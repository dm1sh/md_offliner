local args = {}

function args.read_config(argv, path, print_err)
    local function file_exists(file_path)
        local f = io.open(file_path, "rb")

        if f then
            f:close()
        end
        return f ~= nil
    end

    if file_exists(path) then
        for line in io.lines(path) do
            local key, value = line:match("([^=]+)=([^=]+)")
            if not (key and value) then
                print_err:error("Wrong config file syntax")
            end

            argv[key] = value
        end
    end

    return argv
end

function args.parse()
    local Argparse = require("lib.argparse")

    local parser = Argparse("md-parser",
                       "Command line utility for saving markdown document online assets locally and upload it to server with scp")

    parser:argument("input", "Input file.")

    parser:option("-o --output", "Output directory.", "./")
    parser:option("-s --server", "Username and hostname in username@hostname notation.")
    parser:option("-c --config",
        "Configuration file like\n\t\t\tpath= Output path on server\n\t\t\thost= Server username and hostname in username@hostname notation")

    parser:flag("-u --upload", "If sould upload to server")

    local arguments = parser:parse()

    if not arguments.input:find('[^%.]+%.md$') then
        parser:error("You can't process non-markdown file")
    end

    if ((arguments.output or arguments.server) and arguments.config) then
        parser:error("You can't use both command line parameters and configuration file")
    end

    if (arguments.config) then
        arguments = args.read_config(arguments, arguments.config, parser)
    end

    if arguments.upload and not (arguments.output and arguments.server) then
        parser:error("You should specify output directory and server credentials for upload")
    end

    if arguments.output[arguments.output:len()] ~= '/' then
        arguments.output = arguments.output .. '/'
    end

    return arguments
end

return args
