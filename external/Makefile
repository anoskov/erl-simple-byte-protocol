all: 	 computing computing_drv.so

computing:  computing.c erl_comm.c computing_driver.c
	gcc -o computing computing.c erl_comm.c computing_driver.c

computing_drv.so:  computing.c
	gcc -o computing_drv.so -fpic -shared computing.c

clean:
	rm computing computing_drv.so
