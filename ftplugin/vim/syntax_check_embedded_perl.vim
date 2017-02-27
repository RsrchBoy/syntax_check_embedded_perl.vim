" Vim plugin to check the syntax of embedded perl code in a vim script on save
" Last Change: 2011 Jan 9
" Maintainer:  Britton Kerin <britton.kerin@gmail.com>
" License:     This file is placed in the public domain.

" vim:foldmethod=marker

" Starting Vim Module Boilerplate {{{1

let s:save_cpo = &cpo
set cpo&vim

if exists("loaded_syntax_check_embedded_perl")
  finish
endif
let loaded_syntax_check_embedded_perl = 1

" Interface {{{1

augroup embedded_perl_syntax_check
    au!

    autocmd BufWritePre *.vim,*.vimrc :perl Syntaxcheckembeddedperl::backup_perl

    " It would be somewhat cute to use silent in this autocommand so saving would
    " appear to work normally if the syntax check worked.  But that raises the
    " question of what is normal: after all, the user has to press enter if they
    " have syntax errors.  And since it seems that somehow the version of the
    " error message that contains the line number somehow isn't ending up in the
    " generated vim error but in a message immediately following it, we don't try
    " to do this.
    autocmd BufWritePost *.vim,*.vimrc :call s:RunSyntaxCheckScript()
augroup END

" Implementation {{{1

function! s:RunSyntaxCheckScript() "{{{2
  execute
        \ ':!~/.vim/syntax_check_embedded_perl.perl ' .
        \   expand("%:p") . ' ' .
        \   eval("s:syntaxcheckembeddedperl_tfn")
endfunction

if has('perl')
perl <<EOF
# line 47 "~/work/vim/syntax_check_embedded_perl.vim/ftplugin/vim/syntax_check_embedded_perl.vim"

package Syntaxcheckembeddedperl;

use strict;
use warnings FATAL => 'all';
no warnings 'redefine';

use File::Temp qw( tempfile );

sub backup_perl
{
    my $fn = VIM::Eval('expand("%:p")');   # File being edited.

    my ($tfh, $tfn) = tempfile();   # Temp file handle and name.
    close($tfh) or die "couldn't close temp file handle";

    not system("cp $fn $tfn") or die "couldn't copy $fn to $tfn";

    # Record the name of the pre-save version of the file.
    VIM::DoCommand("let s:syntaxcheckembeddedperl_tfn = '$tfn'");
}

EOF
else
  throw "Error: syntax_check_embedded_perl.vim requires perl support to be " .
        \ "compiled into vim"
  finish
endif


" See also the associated perl script.

