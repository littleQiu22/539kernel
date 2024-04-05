# build: file1.c file2.c
# 	gcc -o out file1.c file2.c

# ========================================

# file1.o: file1.c
# 	gcc -c file1.c

# file2.o: file2.c
# 	gcc -c file2.c

# build: file1.o file2.o
# 	gcc -o out file1.o file2.o

# clean:
# 	rm *.o out

# ========================================

c_compilier = gcc
bin_filename = out
build_dependencies = file1.o file2.o
file1_dependencies = file1.c
file2_dependencies = file2.c

file1.o: $(file1_dependencies)
	$(c_compilier) -c $(file1_dependencies)

file2.o: $(file2_dependencies)
	$(c_compilier) -c $(file2_dependencies)

build: $(build_dependencies)
	$(c_compilier) -o $(bin_filename) $(build_dependencies)

clean:
	rm $(bin_filename) *.o