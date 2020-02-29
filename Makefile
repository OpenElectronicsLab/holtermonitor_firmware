default: check

menuconfig: main/test.c
	../esp-idf/tools/idf.py menuconfig

build: menuconfig
	../esp-idf/tools/idf.py build

flash: build
	../esp-idf/tools/idf.py flash

check: flash ./run-tests.pl
	./run-tests.pl

clean:
	rm -rfv build `cat .gitignore | sed -e 's/#.*//'`
