sub RunScreenSaver()
    print "getting ready"
    port = CreateObject("roMessagePort")
    ' screen = CreateObject("roScreen")
    ' screen.SetMessagePort(port)
    ' screen.Clear(&hddfd00) ' Black background

    images = RetrieveAndIterateTextFile("http://192.168.1.245:8888/index.txt")

    while true
        image_name=GetRandomElementFromArray(images)
        imageUrl = "http://192.168.1.245:8888/" + image_name ' Replace with your image URL
        screen = loadremoteimage(imageUrl, port, image_name)
        ' print "got bitmap "
        ' if bitmap <> invalid then
        '     screen.DrawObject(0, 0, GetScaledImage(bitmap, 1920, 1080))
        ' else 
        '     print "bitmap not valid"
        ' end if
        DrawCenteredBottomText(screen, getImageMetadata("http://192.168.1.245:8888/." + image_name ))
        print "drawed text"
        screen.SwapBuffers()
        'screen.finish()
        print "swapped buffers"
        msg = wait(5000, port)
        screen.swapBuffers()
    end while
    print "fine"
end sub

function GetRandomElementFromArray(arr as Object) as Dynamic
    if arr <> invalid and arr.Count() > 0 then
        randomIndex = Rnd(arr.Count())
        return arr[randomIndex]
    end if
    return invalid
end function

sub DrawCenteredBottomText(screen as Object, text as String)
    font = CreateObject("roFontRegistry").GetDefaultFont()
    width = font.GetOneLineWidth(text,1920)
    height = font.GetOneLineHeight()
    screenWidth = 1920 ' Adjust for different resolutions
    screenHeight = 1080
    x = (screenWidth - width) / 2
    y = screenHeight - height - 50 ' Position above the bottom edge
    screen.DrawText(text, x, y, &hFFFFFF, font)
end sub

function loadremoteimage(url as String, port as Object, filename as String) as Object
    print "load image called " + url
    http = CreateObject("roUrlTransfer")
    http.SetUrl(url)
    http.SetCertificatesFile("common:/certs/ca-bundle.crt")
    http.AddHeader("X-Roku-Reserved-Dev-Id", "")
    http.InitClientCertificates()
    http.EnableFreshConnection(true)

    result = http.GetToFile("cachefs:/" + filename)
    print "fool";
    print result;


    screen = CreateObject("roScreen", true)
    screen.SetMessagePort(port)
 '   screen.Clear(&hddfd00) ' Black background
    screen.SwapBuffers()
    bitmap = CreateObject("roBitmap", "cachefs:/" + filename)

    ' print "bitmap:"
    ' print bitmap
    ' print

    ' fs = CreateObject("roFileSystem")
    ' print fs.stat("cachefs:/" + filename)
    ' print
    
    if bitmap <> invalid then
        screen.DrawObject(0, 0, GetScaledImage(bitmap, 1920, 1080))
    else 
        print "bitmap not valid here : " + filename
        print CreateObject("roBitmap", "cachefs:/" + filename)
    end if


    return screen
    
    ' response = http.GetToFile("pkg:/image")
    ' print "ok"
    ' if response <> invalid then
    '     bitmap = CreateObject("roBitmap", "image") ' Adjust format if needed
    '     print "got image"
    '     return bitmap
    ' end if
    ' print "got no image"
    ' return invalid
end function

sub DrawText(screen as Object, text as String, x as Integer, y as Integer)
    font = CreateObject("roFontRegistry").GetDefaultFont()
    screen.DrawText(text, x, y, &hFFFFFF, font) ' White text color
end sub

function GetScaledImage(bitmap, w, h)
	if bitmap <> invalid
		scaledBitmap = CreateObject("roBitmap", {width: w, height: h, AlphaEnable: true})
		if scaledBitmap <> invalid
			if scaledBitmap.DrawScaledObject(0, 0, w/bitmap.GetWidth(), h/bitmap.GetHeight(), bitmap) = true
				return scaledBitmap
			end if
		end if
	end if
    print "could not scale, image was inbalid!"
	return invalid
end function

function getImageMetadata(url as String)
    http = CreateObject("roUrlTransfer")
    http.SetUrl(url)
    http.SetCertificatesFile("common:/certs/ca-bundle.crt")
    http.InitClientCertificates()
    
    response = http.GetToString()
    if response <> invalid then
        return response
    end if
end function

function RetrieveAndIterateTextFile(url as String)
    http = CreateObject("roUrlTransfer")
    http.SetUrl(url)
    http.SetCertificatesFile("common:/certs/ca-bundle.crt")
    http.InitClientCertificates()
    
    response = http.GetToString()
    if response <> invalid then
        lines = response.Split(Chr(10)) ' Split by newline
        ' for each line in lines
        '     print line
        ' next
        return lines
    end if
end function

function GetConfiguredImageUrl() as String
    
    registry = CreateObject("roRegistrySection", "ScreensaverSettings")
    url = registry.Read("imageUrl")
    if url = invalid or url = "" then
        url = "https://gratisography.com/wp-content/uploads/2025/02/gratisography-when-pigs-fly-800x525.jpg" ' Default URL
    end if
    return url
    print "got url " + url
end function

sub RunScreenSaverSettings()
    screen = CreateObject("roMessagePort")
    screen.SetTitle("Screensaver Settings")
    screen.SetText("Enter image URL:")
    screen.AddButton(1, "OK")
    screen.AddButton(2, "Cancel")
    
    response = screen.Show()
    if response = 1 then
        input = screen.GetResponse()
        registry = CreateObject("roRegistrySection", "ScreensaverSettings")
        registry.Write("imageUrl", input)
        registry.Flush()
    end if
end sub
