#!/usr/bin/env python3

import re
import requests
import sys
import getopt
import os


def download_and_save(url, out_dir):

    file = requests.get(url)

    out_path = './' + out_dir + url.split('/')[-1]

    try:
        open(out_path, 'wb').write(file.content)
        return out_path
    except:
        print('Couldn\'t open file for write')
        raise 'Couldn\'t open file for write'


def get_paths(string):
    img_reg = re.compile(r'!\[.*?\]\(.*?\)')
    path_reg = re.compile(r'(?<=\()http[s]{0,1}.*?(?=\))')

    imgs = img_reg.findall(string)

    paths = []

    for img in imgs:
        res = path_reg.search(img)
        if res:
            paths.append(res.group())

    return paths


def parse_args(argv):
    input_file = ''
    output_directory = ''

    try:
        opts = getopt.getopt(argv, 'hi:o:')[0]
    except getopt.GetoptError:
        print('Usage: ./article_uploader -i <inputfile> -o <output directory>')
        sys.exit(2)

    for opt, arg in opts:
        if opt == '-h':
            print('Usage: ./article_uploader -i <inputfile> -o <output directory>')
            sys.exit()
        elif opt == '-i':
            input_file = arg
        elif opt == '-o':
            output_directory = arg

    if not (input_file and output_directory):
        print('Usage: ./article_uploader -i <inputfile> -o <output directory>')
        sys.exit(2)

    return input_file, output_directory


def get_article_header(string):

    header = ''

    if string[0] == '#':
        header = string.split('\n')[0]
        while header[0] == '#' or header[0] == ' ':
            header = header[1:]
        header += '.md'
        
    return header


def replace_article_paths(string, orig_paths, res_paths):
    for i in range(len(res_paths)):
        string = string.replace(orig_paths[i], (res_paths[i]).split('/')[-1])

    return string


def main(argv):
    input_file, output_directory = parse_args(argv)

    try:
        ifile = open(input_file, "r")
    except:
        print("Couldn't open file")
        sys.exit(2)

    string = ifile.read()

    if output_directory[-1] != '/':
        output_directory += '/'

    article_filename = get_article_header(string)

    if not article_filename:
        article_filename = input_file.split('/')[-1]

    article_path = output_directory + article_filename.split('.')[0] + '/'

    if not os.path.exists(article_path):
        os.makedirs(article_path)

    paths = get_paths(string)

    res_paths = []

    try:
        for url in paths:
            try:
                res_paths.append(download_and_save(url, article_path))
            except:
                paths.remove(url)
                print("Couldn't process image" + url)

        string = replace_article_paths(string, paths, res_paths)

        open(article_path + article_filename, "w").write(string)

    except:
        print("Couldn't process article")
        sys.exit(2)


if __name__ == '__main__':
    main(sys.argv[1:])
