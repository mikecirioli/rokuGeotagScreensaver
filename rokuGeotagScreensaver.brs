sub RunScreenSaver()
    screen = CreateObject("roScreen")
    port = CreateObject("roMessagePort")
    screen.SetMessagePort(port)
    screen.Clear(&h000000) ' Black background
    
    imageUrl = "https://example.com/image.jpg" ' Replace with your image URL
    bitmap = LoadRemoteImage(imageUrl)
    
    if bitmap <> invalid then
        screen.DrawObject(100, 100, bitmap)
    end if
    
    text = "Hello, Roku Screensaver!" ' Customize this text
    DrawText(screen, text, 100, 400) ' Adjust position as needed
    
    screen.SwapBuffers()
    
    while true
        msg = wait(500, port)
    end while
end sub

function LoadRemoteImage(url as String) as Object
    http = CreateObject("roUrlTransfer")
    http.SetUrl(url)
    http.SetCertificatesFile("common:/certs/ca-bundle.crt")
    http.InitClientCertificates()
    
    response = http.GetToBuffer()
    if response <> invalid then
        bitmap = CreateObject("roBitmap", response, "image/png") ' Adjust format if needed
        return bitmap
    end if
    return invalid
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
        url = "https://example.com/default.jpg" ' Default URL
    end if
    return url
end function

sub ShowConfigurationScreen()
    screen = CreateObject("roMessageDialog")
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
