# Make directories in $HOME accessible from everywhere
export CDPATH=$CDPATH:.:$HOME

# Editor variables
VIM=/usr/bin/vim
if [ -e $VIM ]; then
 export EDITOR=$VIM
 export VISUAL=$VIM
fi
