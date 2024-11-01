/**
 * @file
 * Test libeq.
 */

#include <assert.h>

#include "libeq/eq.h"

int main(void) {
    assert(!eq_func(1, 2));
    assert(eq_func(2, 2));
    assert(!eq_func(-1, 1));
}
