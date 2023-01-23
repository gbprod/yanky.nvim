test: 
	@nvim --headless -u spec/init.lua -c "PlenaryBustedDirectory spec/ { minimal_init = 'spec//init.lua' }"


