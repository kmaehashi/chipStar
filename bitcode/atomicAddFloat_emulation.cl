/*
 * Copyright (c) 2023 chipStar developers
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

// Implementations for emulated 32-bit floating point atomic add operations.

#ifndef __opencl_c_generic_address_space
#error __opencl_c_generic_address_space needed!
#endif

#define OVERLOADED __attribute__((overloadable))

/* This code is adapted from AMD's HIP sources */
static OVERLOADED float __chip_atomic_add_f32(volatile local float *address,
                                              float val) {
  volatile local uint *uaddr = (volatile local uint *)address;
  uint old = *uaddr;
  uint r;

  do {
    r = old;
    old = atomic_cmpxchg(uaddr, r, as_uint(val + as_float(r)));
  } while (r != old);

  return as_float(r);
}

static OVERLOADED float __chip_atomic_add_f32(volatile global float *address,
                                              float val) {
  volatile global uint *uaddr = (volatile global uint *)address;
  uint old = *uaddr;
  uint r;

  do {
    r = old;
    old = atomic_cmpxchg(uaddr, r, as_uint(val + as_float(r)));
  } while (r != old);

  return as_float(r);
}

float __chip_atomic_add_f32(generic float *address, float val) {
  volatile global float *gi = to_global(address);
  if (gi)
    return __chip_atomic_add_f32(gi, val);
  volatile local float *li = to_local(address);
  if (li)
    return __chip_atomic_add_f32(li, val);
  return 0;
}

float __chip_atomic_add_system_f32(generic float *address, float val) {
  return __chip_atomic_add_f32(address, val);
}
