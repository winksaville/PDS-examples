# Empty

This is the same code as Empty but
I've refactored main.cpp into multiple files,
setup.{h/cpp}, loop.{h/cpp} and main.cpp as
well add an include/common.h file.

This represents a "real world" sketch
and it is working well. I tweaked Makefile
changeing the "build" target to a phony otherwise
there would be no build because the .ino target
never changes. So if I change main.cpp or
Complex/include/common.h or any other file
nothing would happen. Now with .PHONY buidit
we let arduino-cli decide what needs to be
built or not.

So the functionality of Debug_Aux, Empty and
Complex are identical and function the same
but Complex shows the Makefile we have is
pretty good.

## Compile and upload

Use `make upload S=Complex` to compile and upload
or `make c S=Complex` to compile only.
```
$ make u S=Complex
```

