# Markdown article online assets downloader

This tool helps to download all images in markdown document and put them into one folder with changed paths

**Warning**: lua 5.2 version is required

## Dependency installation:

```bash
luarocks install luasec
```

## Usage:

```bash
md-parser [-o <output>] [-s <server>] [-c <config>] [-u] [-h]
       <input>

Command line utility for saving markdown document online assets locally and upload it to server with scp

Arguments:
   input                 Input file.

Options:
         -o <output>,    Output directory. (default: ./)
   --output <output>
         -s <server>,    Username and hostname in username@hostname notation.
   --server <server>
         -c <config>,    Configuration file like
   --config <config>     			path= Output path on server
                         			host= Server username and hostname in username@hostname notation
   -u, --upload          If sould upload to server
   -h, --help            Show this help message and exit.
```

It also has integrated functional to upload this article over ssh. As for MIT licence you can freely fork it and modify code for your own usage cases.

## Example:

```
lua src/main.lua spec/assets/tmp_dir/some\ file.md -u -s dm1sh@localhost -o /tmp/art
```
