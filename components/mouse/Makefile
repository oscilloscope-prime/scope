CFLAGS = -Wall

OBJECTS = mouse.o usbmouse.o read_mouse.o

TARFILES = Makefile mouse.c \
	usbmouse.h usbmouse.c \
	read_mouse.h read_mouse.c

mouse : $(OBJECTS)
	cc $(CFLAGS) -o mouse $(OBJECTS) -lusb-1.0 -pthread

mouse.tar.gz : $(TARFILES)
	rm -rf mouse
	mkdir mouse
	ln $(TARFILES) mouse
	tar zcf mouse.tar.gz mouse
	rm -rf mouse

mouse.o : mouse.c usbmouse.h read_mouse.h
usbmouse.o : usbmouse.c usbmouse.h
read_mouse.o : 	read_mouse.c read_mouse.h usbmouse.h

.PHONY : clean
clean :
	rm -rf *.o mouse
