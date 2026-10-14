#!/usr/bin/python
import SimpleHTTPServer
import SocketServer

PORT=31337

Handler=SimpleHTTPServer.SimpleHTTPRequestHandler
Handler.extensions_map.update({
'.webapp.':'application/x-web-app-manifest+json',
});

httpd=SocketServer.TCPServer(("",PORT),Handler)

print "Serving at port",PORT
httpd.serve_forever()
