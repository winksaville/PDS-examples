# Empty

This is the same code as Debug_Aux
but Empty.ino is empty and all of the
code is in main.cpp. This works and
the only difference is between Debug_Aux.ino
and main.cpp is including <Arduino.h> and
have main invoke setup and then repeatedly
invoke loop() in a while loop.

So functionality is the same but I had to
change the Makefile so that when compiling
I always touch the <Sketch>.ino file so changes
to main.cpp are noticed. Maybe <Sketch>.yaml
might be an option but this is good enough for
now.

## Compile and upload

Use `make upload S=Empty` to compile and upload
or `make c S=Empty` to compile only.
```
$ make u S=Empty
```

