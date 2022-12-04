function GetErrors(filename)
	let norm_errors = system("norminette " .. a:filename)
	let norm_errors = norm_errors->split("\n")
	let regex = 'Error: \([A-Z_]*\)\s*(line:\s*\(\d*\), col:\s*\(\d*\)):\t\(.*\)'
	let errors = []
	for s in norm_errors
		if s =~# regex
			let groups = matchlist(s, regex)
			let groups = [groups[1], groups[2], groups[3], groups[4]]
			call add(errors, groups)
		endif
	endfor
	return errors
endfunction

function HighlightNorm(filename)
	call clearmatches("NormErrors")
	let errors = GetErrors(a:filename)
	hi def link NormErrors Underlined
	for error in errors
		call matchaddpos("NormErrors", [str2nr(error[1])])
	endfor
endfunction

function GetErrorDict(filename)
	let errors = GetErrors(a:filename)
	let error_dict = {}
	for error in errors
		eval error_dict->extend({error[1] : error[3]})
	endfor
	return error_dict
endfunction

function! s:empty_message(timer)
	echo ""
endfunction

function GetNormMessage(filename)
	let error_dict = GetErrorDict(a:filename)
	if error_dict->has_key(line('.'))
		echo get(error_dict, line('.'))
	endif
	" call timer_start(10000, funcref('s:empty_message'))
	" autocmd CursorMoved *.c funcref('s:empty_message')
endfunction

function GoToNextError(filename)
	let error_dict = GetErrorDict(a:filename)
	let my_line = line('.')
	" if error_dict->has_key(line('.'))
	" 	echo get(error_dict, line('.'))
	" endif
	let mykey = 100000
	for [key, value] in items(error_dict)
    if (key > my_line && key < mykey)
        let mykey = key
    endif
	endfor
	if mykey == 100000
	for [key, value] in items(error_dict)
    if key < mykey
        let mykey= key
    endif
	endfor
	endif
	execute mykey
endfunction

command Norm call HighlightNorm(expand("%:p"))
autocmd BufEnter,BufWritePost *.c Norm
autocmd BufLeave *.c call clearmatches("NormErrors")
autocmd BufEnter,BufWritePost *.h Norm
autocmd BufLeave *.h call clearmatches("NormErrors")

" command NormMessage call GetNormMessage(expand("%:p"))
" autocmd CursorHold *.c NormMessage
" autocmd CursorHold *.h NormMessage
autocmd Filetype c		nnoremap <Space>e :call GoToNextError(expand("%:p"))
