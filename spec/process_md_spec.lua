local ProcessMD = require("src.process_md")
local Utils = require("spec.utils")

local assets_dir = './spec/assets/'

describe("process_md", function()
    describe("get_file_content", function()
        it("Gets content of file test.txt", function()
            assert.equal(
                "![Tux, the Linux mascot](http://test.ml/tux.png) and even ![](http://w3.impa.br/~diego/software/luasocket/luasocket.png)",
                ProcessMD.get_file_content("test.txt"))
        end)
        it("Throws error on wrong filename", function()
            assert.has_error(function()
                ProcessMD.get_file_content("foo.bar")
            end, "foo.bar: No such file or directory")
        end)
    end)

    describe("get_web_imgs_path", function()
        it("Gets img path from markdown img string", function()
            assert.are.same({'https://github.com/adam-p/markdown-here/raw/master/src/common/images/icon48.png'},
                ProcessMD.get_web_imgs_path(
                    '![alt text](https://github.com/adam-p/markdown-here/raw/master/src/common/images/icon48.png)'))
        end)
        it("Doen't return local paths", function()
            assert.are.same({}, ProcessMD.get_web_imgs_path('![alt text](logo)'))
        end)
        it("Gets img path from makrdown text", function()
            assert.are.same({'https://github.com/adam-p/markdown-here/raw/master/src/common/images/icon48.png'},
                ProcessMD.get_web_imgs_path(
                    'Tesing text, only simple ![img](https://github.com/adam-p/markdown-here/raw/master/src/common/images/icon48.png) img passed'))
        end)
        it("Doesn't return links paths", function()
            assert.are.same({}, ProcessMD.get_web_imgs_path(
                'My favorite search engine is [Duck Duck Go](https://duckduckgo.com).'))
        end)
        it("Works for multiple images links", function()
            assert.are.same({'http://test.ml/tux.png', 'http://w3.impa.br/~diego/software/luasocket/luasocket.png'},
                ProcessMD.get_web_imgs_path(
                    '![Tux, the Linux mascot](http://test.ml/tux.png) and even ![](http://w3.impa.br/~diego/software/luasocket/luasocket.png)'))
        end)
    end)

    describe("replace_paths", function()
        it("Replaces original paths with passed", function()
            assert.equal('![Tux, the Linux mascot](./tux.png) and even ![](./luasocket.png)', ProcessMD.replace_paths(
                '![Tux, the Linux mascot](http://test.ml/tux.png) and even ![](http://w3.impa.br/~diego/software/luasocket/luasocket.png)',
                {
                    ["http://test.ml/tux.png"] = "./tux.png",
                    ["http://w3.impa.br/~diego/software/luasocket/luasocket.png"] = "./luasocket.png"
                }))
        end)
    end)

    describe("get_header", function()
        it('Gets header of md file', function()
            local f = io.open(assets_dir .. 'tmp_dir/some file.md', 'r')

            local content = f:read('a')

            local header
            content, header = ProcessMD.get_header(content, assets_dir .. 'tmp_dir/some file.md', true)
            f:close()

            assert.equal('Header_:D', header)
        end)

        it("Returns empty line if no header", function()
            local f = io.open(assets_dir .. 'tmp_dir/and one more.md', 'r')

            local content = f:read('a')

            local header
            _, header = ProcessMD.get_header(content, assets_dir .. 'tmp_dir/and one more.md', true)
            f:close()

            assert.equal('and_one_more', header)
        end)
    end)

    describe("save_document", function()
        local function clean()
            Utils.clean_assets({'Article_name.md'})
        end

        setup(clean)
        teardown(clean)

        it('Saves markdown document into file', function()
            local temp_content = 'Test document'
            ProcessMD.save_document(assets_dir, 'Article_name', temp_content)

            local f = io.open(assets_dir .. 'Article_name.md', 'r')
            assert.is_not_nil(f)

            local f_content = f:read('a')
            assert.equal(temp_content, f_content)

            f:close()
        end)
    end)
end)
