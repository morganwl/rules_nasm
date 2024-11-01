#include "libadd/add.h"
#include "libeq/eq.h"

#include "compsum.h"

int compsum(int a, int b, int c) {
    return eq_func(
            add_func(a, b),
            c);
}
