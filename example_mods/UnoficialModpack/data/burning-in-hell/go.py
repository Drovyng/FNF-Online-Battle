content = ""

with open("burning-in-hell-hard.json", "r") as file: content = file.read()


for i in range(8, 16):
    content = content.replace(f",\n						{i},\n						0", f",\n						{i-8},\n						0,\n						\"SansBlue\"")

for i in range(16, 24):
    content = content.replace(f",\n						{i},\n						0", f",\n						{i-16},\n						0,\n						\"SansOrange\"")


with open("burning-in-hell-hard.json", "w") as file: file.write(content)