#!/bin/sh

nvim --headless -c "PlenaryBustedDirectory tests/ { minimal_init = 'test/init.vim' }"
