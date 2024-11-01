/**
 * @file
 * Implementation of libadd.
 */

#include "add.h"
#include "x86/add_asm.h"

/**
 * Return the sum of two integers.
 *
 * Wraps an assembly routine to perform the actual addition.
 */
int add_func(int a, int b) {
    return add_asm(a, b);
}
