" File: grin.vim
" Author: Lechee.Lai
" Version: 1.0
"
" Goal:
"   grin style in ViM
"
" Command: :Grin for grep under cursor            ( Alt-' )
"          :Vlist for lister and select by ENTER  ( [F11] )
"
" Operator:
"          <Enter>		EditFile
"          o	   		EditFile
"          <2LeftMouse>	EditFile
"          <Esc>		Quit/Close
" Require:
"		+viminfo feature must enable
"
"
" History:
"    1.0 Initial Revision
"        for grin with --fte patch
"        Add standard grin format with grin_mode = 1
"


if exists("loaded_grin") || &cp
    finish
endif
let loaded_grin = 1
let grin = 0
let ag = 1

" "=== S e t  Y o u r  O p t i o n   H e r e  ==="

let grin_mode = 0  " (0/1)
let g:Grin_Default_Options = ''

" "=== End of Option ============================"


if grin_mode == 1
    let Grin_Path = 'grin'
else
    let	Grin_Path = 'grin --fte'
endif

if g:ag == 1
    let Grin_Path = 'ag --fte'
endif

"let Grin_Path = 'grin '

" you can use "CTRL-V" for mapping real key in Quote
if !exists("Vlist_Key")
    let Vlist_Key = "<F11>"
endif

" you can use "CTRL-V" for mapping real key in Quote
if !exists("Grin_Key")
	let Grin_Key = "<M-'>"
endif

"============================================================

let Grin_Output = $HOME . '/fte.grp'
let g:Grin_Shell_Quote_Char = '"'
let g:VGRIN_MASK = '*'


if !exists("VGRIN_DIRS")
    if $bhome == ""
	let g:VGRIN_DIRS=getcwd()
    else
	let g:VGRIN_DIRS=$bhome
    endif
endif

if !exists("Grin_Null_Device")
    if has("win32") || has("win16") || has("win95")
	let Grin_Null_Device = 'NUL'
    else
	let Grin_Null_Device = '/dev/null'
    endif
endif


" Map a key to invoke grep on a word under cursor.
exe "nnoremap <unique> <silent> " . Grin_Key . " :call <SID>RunGrin()<CR>"
exe "inoremap <unique> <silent> " . Grin_Key . " <C-O>:call <SID>RunGrin()<CR>"
exe "nnoremap <unique> <silent> " . Vlist_Key . " :call <SID>RunVlist()<CR>"
exe "inoremap <unique> <silent> " . Vlist_Key . " <C-O>:call <SID>RunVlist()<CR>"


function! s:GetDocLocations()
    let dp = ''
    for p in split(&rtp,',')
        let p = p.'/doc/'
        if isdirectory(p)
            let dp = p.'*.txt '.dp
        endif
    endfor
    return dp
endfunction

function! s:GrinHelp(cmd,args)
    let args = a:args.' '.s:GetDocLocations()
    call s:RunGrin(a:cmd,args)
endfunction

" DelGrinClrDat()
"
function! s:RunGrinClrDat()
    let tmpfile = g:Grin_Output
    if filereadable(tmpfile)
	let del_str = 'del ' . tmpfile
	if (g:ag == 1) || g:grin == 1
	    let del_str = 'rm -f ' . tmpfile
	endif
	call delete(tmpfile)
    endif


endfunction

" RunGrinCmd()
" Run the specified grep command using the supplied pattern
function! s:RunGrinCmd(cmd, pattern)

    let cmd_output = system(a:cmd)
    if cmd_output == ""
	echohl WarningMsg |
		    \ echomsg "Error: Pattern " . a:pattern . " not found" |
		    \ echohl None
	return
    endif
    let tmpfile = g:Grin_Output
    let old_verbose = &verbose
    set verbose&vim

    silent echon cmd_output
endfunction

" EditFile()
"
function! s:EditFile()
    let Done = 0
    let chkerror = 0
    " memory the last location
    exe 'normal ' . 'mZ'

    " =============== Grin/ Semware Grep ===========
    if g:grin_mode == 0   " Semware style (fte)

	let chkline = getline('.')
	let foundln = stridx(chkline,':')
	let chk = strpart(chkline,0,foundln)
	if chk == "File"
	    let fname = strpart(chkline, foundln+2)
	    let fline = ""
	else
	    let fline = chk
	    if g:grin == 1 || g:ag == 1
		let fline = str2nr(fline)
	    endif

	    let fname = ""
	    while Done == 0
		execute "normal " . "k"
		let chkline = getline('.')
		let foundln = stridx(chkline,':')
		let chk = strpart(chkline,0,foundln)
		if chk == "File"
		    let fname = strpart(chkline, foundln+2)
		    let Done = 1
		endif
		let chkerror = line(".")
		if chkerror == 1 && fname == ""
		    break
		else
		    let chkerror = 0
		endif
	    endwhile
	endif
    endif


    if g:grin_mode == 1   " native grin style

	let chkline = getline('.')
	let foundln = stridx(chkline,':')
	let chk = strpart(chkline,0,foundln)
	if strlen(chkline)-1 == foundln
	    let fname = chk
	    let fline = ""
	else
	    let fline = chk
	    if g:grin == 1
		let fline = str2nr(fline)
	    endif

	    let fname = ""
	    while Done == 0
		execute "normal " . "k"
		let chkline = getline('.')
		let foundln = stridx(chkline,':')
		let chk = strpart(chkline,0,foundln)
		if strlen(chkline)-1 == foundln
		    let fname = chk
		    let Done = 1
		endif
		let chkerror = line(".")
		if chkerror == 1 && fname == ""
		    break
		else
		    let chkerror = 0
		endif
	    endwhile
	endif
    endif

    exe 'normal ' . '`Z'

    if chkerror == 1
	echo "Invaild Grep Format / NULL Line "
    else
	" Make suit for you
	" silent! bdelete
	echo fline
	let fline = substitute(fline, '\s*', '', "")

	if fline > 0  || fline == ""
	    if filereadable(fname)
		exe 'edit ' . fname
		if strlen(fline)
		    exe 'normal ' . fline . 'gg'
		endif
	    else
		echo "Invaild filename"
	    endif
	else
	    echo "Line Error"
	endif
    endif
endfunction


" RunGrin()
" Run the specified grep command
function! s:RunGrin(...)
    "    if a:0 == 0 || a:1 == ''
    let grin_opt = g:Grin_Default_Options
    let grin_path = g:Grin_Path

    " No argument supplied. Get the identifier and file list from user
    let pattern = input("grin for pattern: ", expand("<cword>"))
    if pattern == ""
	echo "Cancelled."
	return
    endif
    let pattern = g:Grin_Shell_Quote_Char . pattern . g:Grin_Shell_Quote_Char

"    if g:VGRIN_MASK == "*"
"	let ff = expand("%:e")
"	if ff != ""
"	    let g:VGRIN_MASK = "*.".ff
"	endif
"    endif

    let filenames = input("grin in files (*): ", g:VGRIN_MASK)
    if filenames == ""
	echo "Cancelled."
	return
    endif
    if filenames == "*"
	let filenames = ""
	let mmm=filenames
    else
	let mmm = "-I '".filenames."'"
    endif

"    let g:VGRIN_MASK = filenames
    let grindir = input("grin dir: ", g:VGRIN_DIRS)
    if grindir == ""
	echo "Cancelled."
	return
    endif
    let g:VGRIN_DIRS = grindir
    if g:grin == 1  || g:ag == 1
"	let cmd = grin_path . " " . pattern . " " . g:VGRIN_DIRS . " " . mmm . " " . grin_opt . ">" . g:Grin_Output
	let cmd = grin_path . " " . pattern . " " . mmm . " " . grin_opt . ">" . g:Grin_Output
    endif
    if g:grin == 1 || g:ag == 1
"	call s:RunGrinClrDat()
"	call s:RunGrinCmd(cmd, pattern)
"    else
	let last_cd = getcwd()
	exe 'cd ' . grindir
	call s:RunGrinClrDat()
	call s:RunGrinCmd(cmd, pattern)
	exe 'cd ' . last_cd
    endif

    if filereadable(g:Grin_Output)
	setlocal modifiable
	exe 'edit ' . g:Grin_Output
	setlocal nomodifiable
    endif

    nnoremap <buffer> <silent> <CR> :call <SID>EditFile()<CR>
    nmap <buffer> <silent> <2-LeftMouse> :call <SID>EditFile()<CR>
    nmap <buffer> <silent> o :call <SID>EditFile()<CR>
    nmap <buffer> <silent> <ESC> :bdelete<CR>
endfunction

function! s:RunVlist()
    setlocal modifiable
    exe 'edit ' . g:Grin_Output
    nnoremap <buffer> <silent> <CR> :call <SID>EditFile()<CR>
    nmap <buffer> <silent> <2-LeftMouse> :call <SID>EditFile()<CR>
    nmap <buffer> <silent> o :call <SID>EditFile()<CR>
    nmap <buffer> <silent> <ESC> :bdelete<CR>
    setlocal nomodifiable
endfunction

" Define the set of grep commands
command! -nargs=* Grin call s:RunGrin(<q-args>)
command! Vlist call s:RunVlist()
command! -bang -nargs=* -complete=help GrinHelp call s:GrinHelp('grep<bang>',<q-args>)

" vim:tabstop=4:sw=4
