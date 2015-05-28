# path tracer
# ported from: http://xania.org/201505/two-commutes-with-rust
#

import math

type
    Vec3* = object
        x*, y*, z*: float64

proc x*(v: Vec3): float64 =
    result = v.x

proc y*(v: Vec3): float64 =
    result = v.y

proc z*(v: Vec3): float64 =
    result = v.z


proc clamp*(f: float64): float64 =
    if f < 0:
        result = 0
    elif f > 1:
        result = 1
    else:
        result = f

proc `+`*(v: Vec3, other: Vec3): Vec3 =
    result = Vec3(x: v.x + other.x,
                  y: v.y + other.y,
                  z: v.z + other.z)

proc `-`*(v: Vec3, other: Vec3): Vec3 =
    result = Vec3(x: v.x - other.x,
                  y: v.y - other.y,
                  z: v.z - other.z)

proc `/`*(v: Vec3, f: float64): Vec3 =
    result = Vec3(x: v.x / f,
                  y: v.y / f,
                  z: v.z / f)

proc `*`*(v: Vec3, f: float64): Vec3 =
    result = Vec3(x: v.x * f,
                  y: v.y * f,
                  z: v.z * f)

proc `*`*(v: Vec3, other: Vec3): Vec3 =
    result = Vec3(x: v.x * other.x,
                  y: v.y * other.y,
                  z: v.z * other.z)

proc dot*(v: Vec3, other: Vec3): float64 =
    let mx = v.x * other.x
    let my = v.y * other.y
    let mz = v.z * other.z
    result = mx + my + mz

proc norm*(v: Vec3): Vec3 =
    result = v / v.dot(v).sqrt()

proc zero*(v: var Vec3): Vec3 =
    v.x = 0
    v.y = 0
    v.z = 0
    return v

proc cross*(v: Vec3, other: Vec3): Vec3 =
    result = Vec3(x: v.y * other.z - v.z * other.y,
                  y: v.z * other.x - v.x * other.z,
                  z: v.x * other.y - v.y * other.x)

proc max_component*(v: Vec3): float64 =
    if v.x > v.y and v.x > v.z:
        result = v.x
    elif v.y > v.x and v.y > v.z:
        result = v.y
    else:
        result = v.z

proc neg*(v: Vec3): Vec3 =
    result = Vec3(x: -v.x, y: -v.y, z: -v.z)

proc clamp*(v: Vec3): Vec3 =
    result = Vec3(x: v.x.clamp(), y: v.y.clamp(), z: v.z.clamp())

