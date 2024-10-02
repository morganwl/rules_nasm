/*
 * Call a function from an object file.
 */

#include <assert.h>

int return_16(void);

int main(void) {
    assert(return_16() == 16);
}
