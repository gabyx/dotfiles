# For manipulating the stack.
alias d='dirs -v'                # Show stack directories.
# Use `1` for an alias to jump to the current dir.
for index ({1..9}) alias "$index"="cd +${index}"; unset index
