" Vim syntax file
" Language: vGrep

" Add following in your .vimrc
" au BufRead,BufNewFile *.grp set filetype=grp

if exists("b:current_syntax")
	finish
endif

let s:cpo_save = &cpo
set cpo&vim

syn match grpLine	"^\<\d\+\>:"
syn match grpFile	"^File:*"

hi def link grpFile			Statement
hi def link grpLine			Number
hi def link grpComment		Comment

let b:current_syntax = "grp"
" vim: ts=4 sw=4
