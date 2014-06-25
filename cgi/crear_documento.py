# soffice --headless "--accept=socket,host=127.0.0.1,port=2002;urp"

# En ubuntu 14.04
# sudo apt-get install libreoffice-script-provider-python
# usar python3 en vez de python

import uno
import unohelper
import string
import sys
import io
import os
from com.sun.star.beans import PropertyValue
from unohelper import Base
from com.sun.star.io import IOException, XOutputStream, XInputStream, XSeekable

currDir = os.path.dirname( os.path.realpath(__file__) )

# esto debe definirse sino intenta escribir temporales en /var/www
os.environ['HOME'] = '/tmp'

# Se obtiene el documento por stdin.
input = ""
for line in sys.stdin:
  input = input + line

# convertimos el string a un stream
inputStream = io.StringIO(input)

#Setup config
localContext = uno.getComponentContext()
resolver = localContext.ServiceManager.createInstanceWithContext(
	"com.sun.star.bridge.UnoUrlResolver", localContext )
ctx = resolver.resolve( "uno:socket,host=127.0.0.1,port=2002;urp;StarOffice.ComponentContext" )
smgr = ctx.ServiceManager
desktop = smgr.createInstanceWithContext( "com.sun.star.frame.Desktop",ctx)

# Se abre el encabezado
#document = desktop.loadComponentFromURL("file:///home/leonardo/Desarrollo/WebODF/programs/editor/header.odt", "_blank", 0, ())
# Se se modifican los campos
# para esto se va a usar Search and Replace

# se crea un documento desde la plantilla: "plantilla-original.ott" 
#document = desktop.loadComponentFromURL("private:factory/swriter", "_blank", 0, ())
document = desktop.loadComponentFromURL("file://" + currDir + "/templates/plantilla-original.ott", "_blank", 0, ())
text = document.Text
cursor = text.createTextCursor()


#cursor.gotoEnd(False)

cursor.insertDocumentFromURL("file://" + currDir + "/templates/header.odt", ());

cursor.gotoEnd(False)

class InputStream(unohelper.Base, XInputStream, XSeekable):
    """ Minimal Implementation of XInputStream """
    def __init__(self, inStream):
        self.stream = inStream
        self.stream.seek(0, os.SEEK_END)
        self.size = self.stream.tell()
       
    def readBytes(self, retSeq, nByteCount):
        retSeq = self.stream.read(nByteCount)
        return (len(retSeq), uno.ByteSequence(retSeq))
   
    def readSomeBytes(self, foo, n):
        return self.readBytes(foo, n)

    def skipBytes(self, n):
        self.stream.seek (n, 1)

    def available(self):
        return self.size - self.stream.tell();

    def closeInput(self):
        self.stream.close()

    def seek(self, posn):
        self.stream.seek(int(posn))

    def getPosition(self):
        return int(self.stream.tell())

    def getLength(self):
        return int(self.size)

inProps = (
    PropertyValue( "FilterName" , 0, "HTML" , 0 ),
    PropertyValue( "InputStream", 0, InputStream(inputStream), 0)
    )

cursor.insertDocumentFromURL("private:stream", inProps)

cursor.gotoEnd(False)

cursor.insertDocumentFromURL("file://" + currDir + "/templates/footer.odt", ());

class OutputStream( Base, XOutputStream ):
    def __init__( self ):
        self.closed = 0
    def closeOutput(self):
        self.closed = 1
    def writeBytes( self, seq ):
        sys.stdout.buffer.write( seq.value )
    def flush( self ):
        pass

filterName = "writer_pdf_Export"

outProps = (
    PropertyValue( "FilterName" , 0, filterName , 0 ),
    PropertyValue( "Overwrite" , 0, True , 0 ),
    PropertyValue( "OutputStream", 0, OutputStream(), 0)
    )
	   
try:
  document.storeToURL("private:stream", outProps)
except IOException as e:
  sys.stderr.write("Error: " + e.Message)

# se guarda el documento
document.dispose()

