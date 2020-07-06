''' Module to get arguments passed into Main module'''

import getopt
import sys


def read_cfg_file(path):
    '''Reads config file'''

    cfg = open(path, 'r')
    buff = cfg.read()
    for line in buff.split('\n'):
        if line.split('=')[0] == 'output':
            output_directory = line.split('=')[1]
        elif line.split('=')[0] == 'host':
            server_cred = line.split('=')[1]
    if not (output_directory and server_cred):
        print("No config file provided")
        sys.exit(2)

    return output_directory, server_cred


def usage():
    '''Prints usage instructions'''

    print(''''Usage: ./article_uploader -i <inputfile> -o <output directory>
            or ./article_uploader -u -o <output_directory> -s <server username and hostname in username@hostname notation>
            or ./article_uploader -u -c <configuration file>
            with configuration file such as
            path=<output path on server>
            host=<server username and hostname in username@hostname notation>''')


def parse_args(argv):
    '''Parses arguments provided by user'''

    input_file = ''
    output_directory = ''
    upload_to_server = False
    server_cred = ''
    cfg_path = ''

    try:
        opts = getopt.getopt(argv, 'hi:o:us:c:')[0]
    except getopt.GetoptError:
        usage()
        sys.exit(2)

    for opt, arg in opts:
        if opt == '-h':
            usage()
            sys.exit()
        elif opt == '-i':
            input_file = arg
        elif opt == '-o':
            output_directory = arg
        elif opt == '-u':
            upload_to_server = True
        elif opt == '-s':
            server_cred = arg
        elif opt == '-c':
            cfg_path = arg

    if not (input_file and (output_directory or upload_to_server) or cfg_path):
        usage()
        sys.exit(2)

    if upload_to_server and not (server_cred and output_directory) and cfg_path:
        output_directory, server_cred = read_cfg_file(cfg_path)
    else:
        usage()
        sys.exit(2)

    if server_cred and output_directory:
        return input_file, server_cred, output_directory
    else:
        return input_file, output_directory
