→ why did the quoted and unquoted prints differ
quotes keep exact value format, 
→ why did the digit-prefixed name fail
quotes keep exact value format 
you cant start a variable starting with a number

Without local: the function modifies the same variable that exists outside the function.
With local: the function creates a separate variable that does not affect the variable outside the function. The local variable is destroyed when the function ends.
plain shell variable (non exported) only exists in the current shell subshells cannot see it because it isnt an environment variable 

my_function() {
    # commands
}
to call you do 
my_function
without the call the function wont run 

!/bin/bash

status="stopped"
echo "$status"

my_function(){

        status="running"
}

my_function
echo "$status"


You use this when a variable might not have a value or you want to give a variable a fallback value:
${variable:-fallback}  → give me a backup value if var is empty or doesn't exist
${variable:=fallback}  → give me a backup value and save it if var is empty or doesn't exist
${variable:?error}     → show an error and stop if var is empty or doesnt exist missing
${variable:+value}     → use this value only if var exists 


"$@" (quoted) — each argument stays whole, even if it has spaces in it. If you passed "web fleet" as one argument, the loop sees it as one item: web fleet.
$@ (unquoted) — Bash ignores the argument boundaries and splits everything on spaces. That same "web fleet" argument gets torn into two items: web and fleet.
Same variable, same input — quoting is the only thing that changes whether spaces stay together or get split apart.
Rule: always loop with "$@", quoted. Unquoted $@ (or $*) is the version that silently breaks the moment someone passes an argument with a space in it.
**`"$@"`** = each argument stays separate → use this when looping over arguments.
**`"$*"`** = all arguments get joined into one big string → almost never what you want in a loop.
That's it. Default to `"$@"`, always.

c="$a$b" → one assignment with two expansions next to each other.
c="$a $b" → one assignment with a literal space in between.
In Bash, string concatenation is just adjacent text inside the same quoted string—there is no + or other concatenation operator.


Don't quote variables inside $(( )). Math works with numbers, not strings.
Bash doesn't complain when you do arithmetic with a non-numeric variable—it treats it as 0


Eventually it becomes muscle memory: array append = +=().

e.g. 
echo "${server[@]}"
echo "${server[0]}"
the curly brackets define the start and endpoint of the array for correct accessing  so what do I. change for this


you cant get the last element in the array using index -1 this mean we dont need to know the length of the array to access the last element 

echo "${#server[@]}" this is to count how many elements there are in the array

to remove an element we use 
unset 'server[2]'

array slicing
"${array[@]:start:length}"
${server[@]:2:3}
        |  |
        |  └── take 3 elements
        └──── start at index 2
when the result isnt a whole number and you divide it removes the fraction and only keeps the whole integer.



++counter → incremenets the original value first (in other words updates the original value), then use it (in other words outputs the updated version)
counter++ → use it first(in other words outputs the original version of the  ), then increase it

Think of < and > like a mouth opening toward the bigger/later thing.
<	string comes before another (alphabetically)	[ "$a" \< "$b" ] in this case b comes after a 
>	string comes after another (alphabetically)	[ "$a" \> "$b" ] in this case a comes after b 
-z	string is empty (length is zero)	[ -z "$name" ]
-n	string is not empty	[ -n "$name" ]


-f checks if the file exists - specifically a file only
-d checks if the directory exists - specifically a directory only
-e - checks if this exists - it doesnt care whether it is a file or directory (you dont need to be specific for this whether its a directory or file)
-w - checks if we have permission to edit this file if we are talking about file or for a directory "Can I create, delete, or modify files inside this directory?"
-x - checks if we can run this script file is it excutable or for a directory can i cd into the directory (access or traverse)? 
-r - checks if we can view the file or for a directory can we ls it? 


${#variable} - give me the length of this variable
${variable:start} - Extract from a position to the end


${variable^^} - this is how you can uppercase a variable's value