/**
 * @file
 * Test libadd.
 */

#include <assert.h>

#include "libadd/add.h"

int main(void) {
    assert(add_func(1, 2) == 3);
    assert(add_func(2, 2) == 4);
    assert(add_func(-1, 1) == 0);
}
