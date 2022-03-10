
kaleido.bin: kaleido.asm include/bios.inc include/kernel.inc
	asm02 -b -L kaleido.asm

clean:
	-rm -f *.bin *.lst

