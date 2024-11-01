/**
 * @file
 * Implementation of libadd.
 */

#include "eq.h"
#include "x86/eq_asm.h"

/**
 * Return the sum of two integers.
 *
 * Wraps an assembly routine to perform the actual addition.
 */
int eq_func(int a, int b) {
    return eq_asm(a, b);
}

