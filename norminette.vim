nnoremap <leader>n :silent !norminette<cr>

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

command Norm call HighlightNorm("")
autocmd BufWritePost,BufRead *.c Norm
