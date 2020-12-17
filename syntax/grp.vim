" Vim syntax file
" Language: vGrin

" Add following in your .vimrc
" au BufRead,BufNewFile *.grp set filetype=grp

if exists("b:current_syntax")
	finish
endif


syn match grpLine				"^[0-9]\+:"		contains=grpSep
syn match grpNum				"^[0-9]\+\d"
syn match grpSep	contained	":"

syn match grpFile				"^File:"
syntax region potionString start=/\v"/ skip=/\v\\./ end=/\v"/
syn match parens /[(){}]/

highlight link parens       Type
highlight link potionString String

hi def link grpFile			Statement
hi def link grpLine			Constant
hi def link grpNum			Number

let b:current_syntax = "grp"
" vim: ts=4 sw=4
