'''Provides network related operations'''

import subprocess
import os
import time
import requests


def download_and_save(url, out_dir):
    '''Downloads file from url and saves it into out_dir'''

    file = requests.get(url)

    out_path = './' + out_dir + url.split('/')[-1]

    try:
        open(out_path, 'wb').write(file.content)
        return out_path
    except IOError as ex:
        print(ex)
        raise 'Couldn\'t open file for write'


def scp_wrap(recursively, from_path, to_path):
    '''Downloads/uploads files from/to server using scp'''

    if recursively:
        proc = subprocess.Popen(["scp", "-r", from_path, to_path])
    else:
        proc = subprocess.Popen(["scp", from_path, to_path])

    sts = os.waitpid(proc.pid, 0)  # pylint: disable=unused-variable


def upload_to_server(server_cred, local_path, server_path):
    '''Uploads selected folder to server using scp'''

    scp_wrap(True, local_path, server_cred + ':' + server_path)


def add_to_list_on_server(server_cred, local_path, server_path):
    '''Reads list of articles on server and add new article to it'''

    article_name = local_path[:-1]

    scp_wrap(False, server_cred + ':' + server_path + 'list.db', './')

    articles_list_file = open('list.db', 'r+')
    articles_list = articles_list_file.read()

    articles_list_s = articles_list.split('\n')

    flag = True
    for i, val in enumerate(articles_list_s):
        if article_name in val:
            line_s = val.split(' ')
            line_s[0] = str(int(time.time()))
            articles_list_s[i] = ' '.join(line_s)

            flag = False

    if flag:
        articles_list_s.append(str(int(time.time())) + ' ' + article_name)

    articles_list = '\n'.join(filter(None, articles_list_s))

    articles_list_file.seek(0)
    articles_list_file.write(articles_list)
    articles_list_file.close()

    scp_wrap(False, 'list.db', server_cred + ':' + server_path)
