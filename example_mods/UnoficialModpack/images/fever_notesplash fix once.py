import xml.etree.ElementTree as ET
import os

path = 'fever_notesplash.xml'

if os.path.exists("fever_notesplash save.xml"):
    path = "fever_notesplash save.xml"

tree = ET.parse(path)
root = tree.getroot()

for subtexture in root.findall('SubTexture'):
    name = subtexture.attrib['name']
    frameX = int(subtexture.attrib['frameX'])
    frameY = int(subtexture.attrib['frameY'])
    subtexture.attrib['frameY'] = str(frameY - 72)
    subtexture.attrib['frameX'] = str(frameX - 56)
    

tree.write('fever_notesplash.xml')