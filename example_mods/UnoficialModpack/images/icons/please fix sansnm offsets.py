import xml.etree.ElementTree as ET
import os

path = 'SansNM.xml'

if os.path.exists("SansNM UnfixedOffsets.xml"):
    path = "SansNM UnfixedOffsets.xml"

tree = ET.parse(path)
root = tree.getroot()

for subtexture in root.findall('SubTexture'):
    name = subtexture.attrib['name']
    frameX = int(subtexture.attrib['frameX'])
    frameY = int(subtexture.attrib['frameY'])
    if "ICON SANSNM" in name:
        subtexture.attrib['frameX'] = str(frameX + 70)
        subtexture.attrib['frameY'] = str(frameY + 70)
    else:
        subtexture.attrib['frameX'] = str(frameX - 35)
        subtexture.attrib['frameY'] = str(frameY + 25)
    

tree.write('SansNM.xml')