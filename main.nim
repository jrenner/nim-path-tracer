import vec3
import ray
import model
import extras
import math
import png
import pngwriter

randomize()

echo " ---------- start ----------- "

proc main() =
    var samps = 1
    let width = 20
    let height = 20
    let output_filename = "image.png"
    let num_threads = 1
    let seed = 0x193a6754
    # skip arg parsing part
    samps = samps div 4
    if samps < 1:
        samps = 1
    const BLACK = createVec(0, 0, 0)
    const RED = createVec(0.75, 0.25, 0.25)
    const BLUE  = createVec(0.25, 0.25, 0.75)
    const GREY = createVec(0.75, 0.75, 0.75)
    const WHITE = createVec(0.999, 0.999, 0.999)
    var scene: seq[Sphere] = @[]
    scene.add(createSphere(Diffuse, 1e5, createVec(1e5+1.0, 40.8, 81.6), BLACK, RED))
    scene.add(createSphere(Diffuse, 1e5, createVec(-1e5+99.0, 40.8, 81.6), BLACK, BLUE))
    # add more later

    let camera_pos = createVec(50, 52, 295.6)
    let camera_dir = createVec(0, -0.042612, -1.0).norm()
    let camera_x = createVec(width.float64 * 0.5135 / height.float64, 0, 0)
    let camera_y = camera_x.cross(camera_dir).norm() * 0.5135

    var screen: Screen = newSeq[Line](0)
    for y in 0..height:
        var line: Line = newSeq[Vec3](0)
        for x in 0..width:
            echo "rendering: ", x, ", ", y
            var sum = createVec()
            for sx in 0..2:
                for sy in 0..2:
                    var r = createVec()
                    for i in 0..samps:
                        let dx = randomSamp()
                        let dy = randomSamp()
                        let sub_x = (sx.float64 + 0.5 + dx) / 2.0
                        let dir_x = (sub_x + x.float64) / width.float64 - 0.5
                        let sub_y = (sy.float64 + 0.5 + dy) / 2.0
                        let dir_y = (sub_y + (height - y - 1).float64) / height.float64 - 0.5
                        let dir = (camera_x * dir_x + camera_y * dir_y + camera_dir).norm()
                        let jittered_ray = Ray(origin: camera_pos + dir * 140.0, direction: dir)
                        let sample = radiance(scene, jittered_ray, 0)
                        r = r + (sample / (samps.float64))
                    sum = sum + (r.clamp() * 0.25)
            line.add(sum)
        screen.add(line)

    write_png(screen)

main()
