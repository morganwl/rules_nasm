CFLAGS=-iquote. -g

tests/add_test: tests/add_test.o libadd/add.o libadd/x86/add_x86.o

libadd/x86/add_x86.o: libadd/x86/add_x86.asm libadd/x86/x86util.asm
	nasm libadd/x86/add_x86.asm -felf64 -Fdwarf
