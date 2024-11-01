/**
 * @file
 * Test the compsum function.
 */

#include <assert.h>
#include "libcompsum/compsum.h"

int main(void) {
    assert(compsum(1, 2, 3));
    assert(!compsum(2, 2, 3));
    assert(compsum(1, -1, 0));
}
