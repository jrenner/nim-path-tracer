import math
import vec3
import ray

randomize()

const RAND_HIGH* : float64 = 0xFF_FF_FF_FF_FF_FF_FF
const MAX_DEPTH = 100 # default 500

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
    HitRecord* = object
        sphere*: Sphere
        dist*: float64

proc intersect*(scene: openArray[Sphere], ray: Ray): seq[HitRecord] =
    result = @[]
    for sph in scene:
        let hit: OptionFloat64 = sph.intersect(ray)
        if not hit.empty:
            result.add(HitRecord(sphere: sph, dist: hit.value))

proc radiance*(scene: openArray[Sphere], ray: Ray, depth: int32): Vec3 =
    result = createVec() # black as default when no hits
    let hitRecords = scene.intersect(ray)
    for hit in hitRecords:
        let hitPos = ray.origin + ray.direction * hit.dist
        let hitNorm = (hitPos - hit.sphere.position).norm()
        let n1 =
            if hitNorm.dot(ray.direction) < 0.0:
                hitNorm
            else:
                hitNorm.neg()
        var color = hit.sphere.color
        let maxReflectance = color.max_component()
        var newDepth = depth + 1
        if newDepth > 5:
            let rand = random(RAND_HIGH)
            if rand < maxReflectance and depth < MAX_DEPTH:
                color = color * (1.0 / maxReflectance)
            else:
                return hit.sphere.emission
        case hit.sphere.material:
            of Diffuse:
            # get a random polar coordinate 
            # FIXME not sure what range to generate random numbers in
            let r1 = random(RAND_HIGH) * 2.0 * PI
            let r2 = random(RAND_HIGH)
            let r2s = r2.sqrt()
            # create coord system u,v,w local to the point, where w is the normal
            let w = n1
            # pick arbitrary non-zero preferred axis for u
            let u =
                if n1.x.abs() > 0.1:
                    createVec(0, 1, 0)
                else:
                    createVec(1, 0, 0).cross(w)
            let v = w.cross(u)
            # construct the new direction
            let newDir = u * r1.cos() * r2s + v * r1.sin() * r2s + w * (1.0 - r2).sqrt()
            color = color * radiance(scene, Ray(hitPos, newDir.norm()), newDepth)
            of Specular:
                let reflection = ray.direction - hitNorm * 2.0 * hitNorm.dot(ray.direction)
                let reflectedRay = Ray(origin: hitPos, direction: reflection)
                color = color * radiance(scene, reflectedRay, depth)
            of Refractive:
                let reflection = ray.direction - hitNorm * 2.0 * hitNorm.dot(ray.direction)
                let reflectedRay = Ray(origin: hitPos, direction: reflection)
                let into = hitNorm.dot(n1) > 0
                let nc = 1
                let nt = 1.5
                let nnt =
                    if into:
                        nc / nt
                    else:
                        nt / nc
                let ddn = ray.direction.dot(n1)
                let cos2t = 1 - nnt * nnt * (1.0 - ddn * ddn)
                if cos2t < 0:
                    # total internal reflection
                    color = color * radiance(scene, reflectedRay, depth)
                else:
                    var tbd = ddn * nnt + cos2t.sqrt()
                    if not into:
                        tbd = tbd * -1
                    let tdir = (ray.direction * nnt - hit_normal * tbd).norm()
                    let transmittedRay = Ray(origin: hitPos, direction: tdir)
                    let a = nt - nc;
                    let b = nt + nc;
                    let r0 = (a * a) / (b * b)
                    let minNum =
                        if into:
                            ddn * -1
                        else:
                            tdir.dot(hitNorm)
                    let c = 1.0 - minNum
                    let re = r0 + (1 - r0) * c * c * c * c * c
                    let tr = 1 - re
                    let p = 0.25 + 0.5 * re
                    let rp = re / p
                    let tp = tr / (1 - p)
                    let mulNum =
                        if depth > 2:
                            if random(RAND_HIGH) < p:
                                radiance(scene, reflectedRay, depth) * rp
                            else:
                                radiance(scene, transmittedRay, depth) * tp
                        else:
                            let rad1 = radiance(scene, reflectedRay, depth) * re
                            let rad2 = radiance(scene, transmittedRay, depth) * tr
                            rad1 + rad2
       result = hit.sphere.emission + color

proc randomSamp(): float64 =
    let r = 2.0 * random(RAND_HIGH)
    if r < 1.0:
        r.sqrt() - 1.0
    else:
        1 - (2 - r).sqrt()

# proc toInt(v: float64): uint8 =
# ....? needed?
