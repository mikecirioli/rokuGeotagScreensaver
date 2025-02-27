sub RunScreenSaver()
    screen = CreateObject("roScreen")
    port = CreateObject("roMessagePort")
    screen.SetMessagePort(port)
    screen.Clear(&hddfd00) ' Black background
    print "getting ready"

    imageUrl = "https://gratisography.com/wp-content/uploads/2025/02/gratisography-when-pigs-fly-800x525.jpg" ' Replace with your image URL
   bitmap = loadremoteimage(imageUrl)
    print "got bitmap "
    if bitmap <> invalid then
        screen.DrawObject(100, 100, bitmap)
    else 
        print "bitmap not valid"
    end if
    text = "Hello, Roku Screensaver!" ' Customize this text
    DrawText(screen, text, 100, 400) ' Adjust position as needed
    print "drawed text"
    screen.SwapBuffers()
    print "swapped buffers"
    while true
        msg = wait(500, port)
    end while
    print "fine"
end sub

function loadremoteimage(url as String) as Object
    print "load image called " + url
    http = CreateObject("roUrlTransfer")
    http.SetUrl(url)
    http.SetCertificatesFile("common:/certs/ca-bundle.crt")
    http.AddHeader("X-Roku-Reserved-Dev-Id", "")
    http.InitClientCertificates()
    http.EnableFreshConnection(true)

    http.GetToFile("tmp:/image")
    print "fool"

    return CreateObject("roBitmap", "tmp:/image")
    
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

function RetrieveAndIterateTextFile(url as String)
    http = CreateObject("roUrlTransfer")
    http.SetUrl(url)
    http.SetCertificatesFile("common:/certs/ca-bundle.crt")
    http.InitClientCertificates()
    
    response = http.GetToString()
    if response <> invalid then
        lines = response.Split(Chr(10)) ' Split by newline
        for each line in lines
            print line
        next
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
