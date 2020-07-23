local NetwOps = require("src.netw_ops")
local Utils = require("spec.utils")

local assets_dir = './spec/assets/'

describe('netw_ops', function()
    describe('download_to', function()
        local function clean()
            Utils.clean_assets({'reference.html', 'Readme.html', 'tux.png'})
        end

        before_each(clean)
        after_each(clean)

        it('Saves file into output', function()
            NetwOps.download_to('http://w3.impa.br/~diego/software/luasocket/reference.html', assets_dir)

            local f = io.open(assets_dir .. 'reference.html', 'r')
            local reference = io.open(assets_dir .. 'ref.html', 'r')

            local content = f:read('a')
            local ref_content = reference:read('a')

            assert.truthy(f)
            assert.equal(ref_content, content)

            f:close()
            reference:close()
        end)

        it('Works with HTTPS protocol', function()
            NetwOps.download_to('https://raw.githubusercontent.com/Dm1tr1y147/thetriangle/master/Readme.txt',
                assets_dir)

            local f = io.open(assets_dir .. 'Readme.txt', 'r')
            local reference = io.open(assets_dir .. 'Rref.txt', 'r')

            local content = f:read('a')
            local ref_content = reference:read('a')

            assert.truthy(f)
            assert.equal(ref_content, content)

            f:close()
            reference:close()
        end)

        it('Works with binary files', function()
            NetwOps.download_to(
                'https://d33wubrfki0l68.cloudfront.net/e7ed9fe4bafe46e275c807d63591f85f9ab246ba/e2d28/assets/images/tux.png',
                assets_dir)

            local f = io.open(assets_dir .. 'tux.png', "r")

            assert.truthy(f)

            f:close()
        end)
    end)

    describe('get_file_name', function()
        it('Gets last element of path', function()
            assert.equal('tux.png', NetwOps.get_file_name('https://test.com/tux.png'))
        end)

        it("Doesn't return anything if no filename", function()
            assert.equal('', NetwOps.get_file_name('https://test.com/'))
        end)
    end)

    describe('scp_wrap', function()
        local function clean()
            Utils.clean_assets({'downloaded.txt'})
        end

        before_each(clean)
        after_each(clean)

        it('Downloads file from server', function()
            local res = NetwOps.scp_wrap(
                            'dm1sh@192.168.0.18:/mnt/hdd/Work/Development/Lua/md-offliner/spec/assets/Rref.txt',
                            assets_dir .. 'downloaded.txt')

            assert.is_not_nil(res)

            local orig_f = io.open(assets_dir .. 'Rref.txt')
            local dest_f = io.open(assets_dir .. 'downloaded.txt')

            assert.is_not_nil(dest_f)

            local orig_content = orig_f:read('a')
            local dest_content = dest_f:read('a')

            orig_f:close()
            dest_f:close()

            assert.equal(orig_content, dest_content)
        end)
    end)

    describe('upload_dir', function()
        local function clean()
            Utils.clean_assets({'output_dir/'})
        end

        before_each(clean)
        after_each(clean)

        it('Uploads all files in directory to server', function()
            NetwOps.upload_dir(assets_dir .. 'tmp_dir/', 'dm1sh@192.168.0.18',
                '/mnt/hdd/Work/Development/Lua/md-offliner/spec/assets/output_dir/')

            local ref_dir = Utils.list_dir(assets_dir .. 'tmp_dir')
            local dest_dir = Utils.list_dir(assets_dir .. 'output_dir')

            assert.are.same(ref_dir, dest_dir)
        end)
    end)

    describe('download_config', function()
        local function clean()
            Utils.clean_assets({'tmp_dir/list.db'})
        end

        before_each(clean)
        after_each(clean)
        teardown(clean)

        it('Downloads database file from server', function()
            NetwOps.download_db('dm1sh@192.168.0.18', '/mnt/hdd/Work/Development/Lua/md-offliner/spec/assets/',
                assets_dir .. '/tmp_dir')

            local ref_file = io.open(assets_dir .. 'list.db', 'r')
            local file = io.open(assets_dir .. 'tmp_dir/list.db', 'r')

            assert.is_not_nil(file)

            local ref_content = ref_file:read('a')
            local content = file:read('a')

            assert.equal(ref_content, content)

            ref_file:close()
            file:close()
        end)
    end)

    describe('insert_article', function()
        local function clean()
            Utils.clean_assets({'ref_list.db'})
        end

        setup(function()
            Utils.copy_file(assets_dir .. 'list.db', assets_dir .. 'ref_list.db')
        end)

        before_each(function()
            Utils.copy_file(assets_dir .. 'ref_list.db', assets_dir .. 'list.db')
        end)

        teardown(function()
            Utils.copy_file(assets_dir .. 'ref_list.db', assets_dir .. 'list.db')
            clean()
        end)

        it('Adds article to file', function()
            NetwOps.insert_article(assets_dir, 'Test_article')

            local ref_list = io.open(assets_dir .. 'ref_list.db', 'r')
            local list = io.open(assets_dir .. 'list.db', 'r')

            assert.equal(ref_list:read('a') .. math.floor(os.time()) .. ' Test_article', list:read('a'))

            ref_list:close()
            list:close()
        end)
        it('Updates if entry exists', function()
            local list = io.open(assets_dir .. 'list.db', 'a')
            list:write('5647546 Test_article\n')
            list:close()

            NetwOps.insert_article(assets_dir, 'Test_article')

            local ref_list = io.open(assets_dir .. 'ref_list.db', 'r')
            list = io.open(assets_dir .. 'list.db', 'r')

            assert.equal(ref_list:read('a') .. math.floor(os.time()) .. ' Test_article', list:read('a'))

            ref_list:close()
            list:close()
        end)
    end)
end)
