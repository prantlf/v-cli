all: check test

check:
	v fmt -w .
	v vet .

test:
	v -use-os-system-to-run test .
	v -use-os-system-to-run run src/write_flag_test.v
	v -use-os-system-to-run run src/write_val_test.v
	v -use-os-system-to-run run src/write_arg_test.v

clean:
	rm -rf src/*_test src/*.dSYM
