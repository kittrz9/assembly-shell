# assembly shell
just a very simple shell written in x86 assembly  
  
I made this basically just to learn how to write x86 assembly. this really should not be used in any normal way  
  
currently this is only capable of executing programs with either their full path (i.e. `/bin/ls`) or just their name if they are in /bin/, sending different arguments to a program like `ls -alsh`, and a few built in commands like `cd` and `exit`.  

it will also copy all of the environment variables from the previous shell, but it is incapable of actually changing any of them currently, making this functionality kinda useless at the moment lmao  
  
---

## dependencies
 - NASM : <https://nasm.us/>  
 - LD : <https://www.gnu.org/software/binutils/>  
 - Linux (this will only work with linux, as it depends on all the specific syscalls it provides)  
 - any posix compliant shell like [dash](http://gondor.apana.org.au/~herbert/dash/) or [bash](https://www.gnu.org/software/bash/) to run `./build.sh`  

---

## building

you should be able to build this by just executing the `./build.sh` script if you have everything this depends on  
