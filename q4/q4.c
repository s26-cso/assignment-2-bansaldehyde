#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef int (*op_func)(int, int);

int main() {
  char op[6]; // at max 5 chars + \0
  int num1, num2;

  while (scanf("%5s %d %d", op, &num1, &num2) ==
         3) { // so that we exit the loop when user does not provide 3 args
    char libpath[15]; // total size of the string will be 14

    snprintf(libpath, sizeof(libpath), "./lib%s.so",
             op); // joining text and putting the string in libpath char array

    // Load the shared library
    // RTLD_LAZY tells it to resolve symbols only when the code is executed
    void *lib = dlopen(libpath, RTLD_LAZY);

    // Locate the memory address of the function within the loaded library
    op_func fn = (op_func)dlsym(lib, op);

    if (fn) {
      // calculate the operation using the op function
      int result = fn(num1, num2);
      printf("%d\n", result);
    }
    dlclose(lib);
  }
}
