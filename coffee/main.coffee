# init Spooky
Spooky = require('spooky');

class ScreenShot
    _urls = []

    constructor: (urls)->
        # ttl
        for id, url of urls
            _urls.push {
                id: id
                url: url
            }
        next.call(@)

    next = ()->
        url = _urls.pop()
        unless url.url == undefined or url.id == undefined
            analysis.call(@, url.url, url.id)
        else
            console.log "finish capture pages."

    analysis = (url, img_path)->
        img_path = "captures/#{img_path}.png"

        spooky = new Spooky({
                child: 
                    transport: 'http'
                ,
                casper: 
                    logLevel: 'info',
                    verbose: true
                
            }, (err)->
                if err
                    e = new Error('Failed to initialize SpookyJS')
                    e.details = err
                    throw e
         
                spooky.start(url)
                spooky.then([
                        img_path: img_path
                        url: url
                    , ()->
                        this.capture(img_path)
                        emit("finish", url)
                ])
                spooky.run ()->
                    this.exit()
            )
         
        spooky.on 'error', (e, stack)->
            console.error(e)
         
            if stack
                console.log(stack)
            
        spooky.on('console',  (line)->
            console.log(line)
        )

        spooky.on 'log', (log)->
            if log.space == 'remote'
                console.log log.message
        
        spooky.on('finish', (url)->
            console.log "> finish #{url}"
            next.call(@)
        )

urls = 
    135371: "http://juggly.cn/archives/135371.html",
    135370: "http://juggly.cn/archives/135370.html",
    135369: "http://juggly.cn/archives/135369.html",
    135368: "http://juggly.cn/archives/135368.html",
    135367: "http://juggly.cn/archives/135367.html"

captures = new ScreenShot(urls)
