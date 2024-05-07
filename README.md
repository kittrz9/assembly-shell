# assembly shell
just a very simple shell written in x86 assembly <br>
<br>
I made this basically just to learn how to write x86 assembly. this really should not be used as a serious shell <br>
<br>
currently this is only capable of executing programs with either their full path (i.e. `/bin/ls`) or just their name if they are in /bin/, sending different arguments to a program like `ls -alsh`, sending the ctrl+c interrupt to the current process, and running a few built in commands like `cd` and `exit`. <br>
<br>
it will also copy all of the environment variables from the previous shell, but it is incapable of actually changing any of them currently, making this functionality kinda useless at the moment lmao <br>

---

## dependencies
 - NASM : <https://nasm.us/> 
 - a linker, such as mold : <https://github.com/rui314/mold/>
 - Linux (this relies on all the specific syscalls it provides)
 - any posix compliant shell like [dash](http://gondor.apana.org.au/~herbert/dash/) or [bash](https://www.gnu.org/software/bash/) to run `./build.sh`
 - some implementation of the coreutils (such as [toybox](http://www.landley.net/toybox), [busybox](https://busybox.net/), or [the gnu one](https://www.gnu.org/software/coreutils/))

---

## building
you should be able to build this by just executing the `./build.sh` script if you have everything this depends on
