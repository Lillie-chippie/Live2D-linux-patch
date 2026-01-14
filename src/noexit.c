#include <unistd.h>

void exit(int status) {
    write(2, "Intercepted exit\n", 17);
    while(1) pause();
}

void _exit(int status) {
    write(2, "Intercepted _exit\n", 18);
    while(1) pause();
}

void _Exit(int status) {
    write(2, "Intercepted _Exit\n", 18);
    while(1) pause();
}
