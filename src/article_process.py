'''Provides some article content operations'''

import re


def get_paths(string):
    '''Gets images paths in article'''

    img_reg = re.compile(r'!\[.*?\]\(.*?\)')
    path_reg = re.compile(r'(?<=\()http[s]{0,1}.*?(?=\))')

    imgs = img_reg.findall(string)

    paths = []

    for img in imgs:
        res = path_reg.search(img)
        if res:
            paths.append(res.group())

    return paths


def rm_first_line(string):
    '''Removes first line from string'''

    return string[string.find('\n') + 1:]


def get_article_title(string):
    '''Gets article title'''

    header = ''

    if string[0] == '#':
        header = string.split('\n')[0]
        while header[0] == '#' or header[0] == ' ':
            header = header[1:]
        header += '.md'
        header = header.replace(' ', '_')

    return header


def replace_article_paths(string, orig_paths, res_paths):
    '''Replaces all web links with downloaded ones'''

    for i, val in enumerate(res_paths):
        print(val[2:])
        string = string.replace(orig_paths[i], '/articles/' + val[2:])

    return string
