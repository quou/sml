#pragma once

#ifndef pi
#define pi 3.14159265358f
#endif

#include <stdint.h>

typedef int8_t   i8;
typedef int16_t  i16;
typedef int32_t  i32;
typedef int64_t  i64;
typedef uint8_t  u8;
typedef uint16_t u16;
typedef uint32_t u32;
typedef uint64_t u64;

double torad(double deg);
double todeg(double rad);

typedef struct {
	float x;
	float y;
} v2f;

v2f v2f_normalised(v2f v);
float v2f_magnitude(v2f v);
v2f make_v2f(float x, float y);
v2f v2f_sub(v2f a, v2f b);
float v2f_dot(v2f a, v2f b);
v2f v2f_mul(v2f a, v2f b);
v2f v2f_scale(v2f v, float s);
v2f v2f_div(v2f a, v2f b);
v2f v2f_add(v2f a, v2f b);

