#!/usr/bin/env python3
''' Main module '''

import os
import sys
import shutil

from get_args import parse_args
from article_process import get_article_title, get_paths, replace_article_paths, rm_first_line
from netw_ops import download_and_save, upload_to_server, add_to_list_on_server


def main(argv):
    '''Main function'''

    input_file = ''
    server_cred = ''
    output_directory = ''

    res = parse_args(argv)

    if len(res) == 2:
        input_file, output_directory = res  # pylint: disable=unbalanced-tuple-unpacking
    elif len(res) == 3:
        input_file, server_cred, output_directory = res

    try:
        ifile = open(input_file, "r")
    except IOError as ex:
        print("Couldn't open input file")
        print(ex)
        sys.exit(2)

    text = ifile.read()

    if output_directory[-1] != '/':
        output_directory += '/'

    article_filename = get_article_title(text)

    if not article_filename:
        article_filename = input_file.split('/')[-1]
    else:
        text = rm_first_line(text)

    article_folder = article_filename.split('.')[0] + '/'

    if not os.path.exists(article_folder):
        os.makedirs(article_folder)

    paths = get_paths(text)

    res_paths = []

    for url in paths:
        try:
            res_paths.append(download_and_save(url, article_folder))
        except Exception as ex:
            paths.remove(url)
            print("Couldn't process image:", ex, '\nurl:', url)
            raise "Couldn't process image"

    text = replace_article_paths(text, paths, res_paths)

    open(article_folder + article_filename, "w").write(text)

    if server_cred:
        upload_to_server(server_cred, article_folder, output_directory)

        shutil.rmtree(article_folder)

        add_to_list_on_server(
            server_cred, article_folder, output_directory)


if __name__ == '__main__':
    main(sys.argv[1:])
