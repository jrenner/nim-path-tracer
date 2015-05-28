import math
import vec3
import ray

randomize()

type
    Material* = enum
        Diffuse,
        Specular,
        Refractive

    Sphere* = object
        material*: Material
        radius*: float64
        position*: Vec3
        emission*: Vec3
        color*: Vec3

    OptionFloat64* = object
        empty*: bool
        value*: float64

proc option*(f: float64): OptionFloat64 =
    result = OptionFloat64(empty: false, value: f)

proc emptyOptionFloat64*(): OptionFloat64 =
    result = OptionFloat64(empty: true, value: 0)

### SPHERE PROCS ###

proc intersect*(sph: Sphere, ray: Ray): OptionFloat64 =
    result = OptionFloat64(empty: true, value: 0)
    let op = sph.position - ray.origin
    let b = op.dot(ray.direction)
    let determinant = b * b - op.dot(op) + sph.radius * sph.radius
    if determinant < 0:
        return emptyOptionFloat64()
    let determSqrt = determinant.sqrt()
    let t1 = b - determSqrt
    let t2 = b + determSqrt
    const EPSILON = 0.0001
    result =
        if t1 > EPSILON:
            t1.option()
        elif t2 > EPSILON:
            t2.option()
        else:
            emptyOptionFloat64()
    



