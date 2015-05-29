import png
import extras

proc write_png*(screen: Screen) =
    var image = open("traced.png", mode=fmWrite)
    var pngptr: png_structp = png_create_write_struct(PNG_LIBPNG_VER_STRING, nil, nil, nil)
    if pngptr == nil:
        error("pngptr is nil")
    var infoptr = png_create_info_struct(pngptr)
    if infoptr == nil:
        error("infoptr is nil")
    
    png_init_io(pngptr, image)

    let width: uint32 = screen.width().uint32
    let height: uint32 = screen.height().uint32
    echo "width, ", width, "height: ", height

    # write header
    let bit_depth: cint = 24
    png_set_IHDR(pngptr, infoptr, width, height, bit_depth,
        PNG_COLOR_TYPE_RGB, PNG_INTERLACE_NONE,
        PNG_COMPRESSION_TYPE_BASE, PNG_FILTER_TYPE_BASE)

    var row = newSeq[png_byte](0)
    for line in screen:
        for vec in line:
            
