package = "md-offliner"
version = "1.0-1"
source = {
   url = "git://github.com/Dm1tr1y147/md_offliner",
   tag = "v1.0",
}
description = {
   summary = "Markdown article online assets downloader.",
   detailed = [[
      This tool helps to download all images in markdown document and put them into one folder with changed paths.
   ]],
   license = "MIT/X11"
}
dependencies = {
   "lua >= 5.1, <= 5.4",
   "luasocket >= 2.0.2-6",
   "luasec >= 0.9-1",
}
build = {
   type = "builtin",
   modules = {
      main = "src/main.lua",
      ["src.arg_proc"] = "src/arg_proc.lua",
      ["src.netw_ops"] = "src/netw_ops.lua",
      ["src.process_md"] = "src/process_md.lua",
      ["lib.argparse"] = "lib/argparse.lua"
   },
   copy_directories = { "spec" }
}