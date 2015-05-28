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

# test
proc test_intersection() =
    let sphere = Sphere(material: Diffuse,
                        radius: 100,
                        position: createVec(0, 0, 200),
                        emission: createVec(),
                        color: createVec())
    # TEST 1
    let ray = Ray(origin: createVec(),
                  direction: createVec(0, 0, 1))
    let intersectResult: OptionFloat64 = sphere.intersect(ray)
    assert(not intersectResult.empty, "intersection result should not be empty")
    assert abs(100.0 - intersectResult.value) < 0.001, "hit result distance is wrong"

    # TEST 2
    let ray2 = Ray(origin: createVec(),
                   direction: createVec(0, 1, 0))
    let intersectResult2 = sphere.intersect(ray2)
    assert(intersectResult2.empty, "intersection should be empty")

type
    HitRecord = object
        sphere: Sphere
        dist: float64

proc intersectAll(scene: openArray[Sphere], ray: Ray): seq[HitRecord] =
    result = @[]
    for sph in scene:
        let hit: OptionFloat64 = sph.intersect(ray)
        if not hit.empty:
            result.add(HitRecord(sphere: sph, dist: hit.value))

