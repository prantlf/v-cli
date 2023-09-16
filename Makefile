all: check test

check:
	v fmt -w .
	v vet .

test:
	v test .

clean:
	rm -rf src/*_test src/*.dSYM
