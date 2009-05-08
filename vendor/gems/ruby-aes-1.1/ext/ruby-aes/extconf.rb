require 'mkmf'

dir_config('aes_alg')
have_library('c', 'main')
have_header('aes_cons.h')

create_makefile('aes_alg')
