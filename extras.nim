import vec3

type
    Line* = seq[Vec3]
    Screen* = seq[Line]

proc width*(s: Screen): int =
    result = s[0].len()

proc height*(s: Screen): int =
    result = s.len()

template error*(msg: string) =
    raise newException(Exception, msg)
