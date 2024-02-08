import tkinter
import sys
#information about rectpack is included in the text file
#supplied with this submission
from rectpack import newPacker

class CustomCanvas:
    #constructor for CustomCanvas which uses the Canvas object from Tkinter
    def __init__(self, height, width):
        #instantiate a Tkinter object
        self.master = tkinter.Tk()
        #create a canvas using that object
        self.canvas = tkinter.Canvas(self.master, height = height, width = width)
        #pack the canvas
        self.canvas.pack()

    #function to draw rectangles on CustomCanvas
    def drawRects(self, rects):
        for r in rects:
            #rectangles need 4 vertices specified to be drawn
            self.canvas.create_rectangle(r.x, r.y,
                                         r.x + r.width, r.y + r.height,
                                         outline='black', fill='chocolate')
        #mainloop keeps the window displaying the rectangles open
        self.master.mainloop()

class Rectangle:
    #constructor for Rectangle
    def __init__(self, height, width, x = 0, y = 0):
        self.height = height
        self.width = width
        self.x = x
        self.y = y

#allRect is a list of Rectangle objects and
#canvasSize is a tuple (height, width)
#this function returns a list of placed Rectangle objects
def pack(allRect, canvasSize):
    #make a packer and add our rectangles to it
    packer = newPacker()
    for r in allRect:
        packer.add_rect(r.width, r.height)
    #add the canvas information to the packer
    packer.add_bin(canvasSize[0],canvasSize[1])
    #pack the rectangles and get the results
    packer.pack()
    newRect = []
    #store the resulting packed rectangles in newRect
    #elements in packer.rect_list() are in the form:
    #0         1        2        3      4
    #binIndex, x-coord, y-coord, width, height
    for r in packer.rect_list():
        newRect.append(Rectangle(r[4],r[3],r[1],r[2]))
    return newRect

def main():
    #sys.argv is list of cmd line arguments
    #filepath is second argument given
    filePath = sys.argv[1]
    f = open(filepath, mode = 'r')
    #lines stores all of the lines of text from the file
    lines = f.readlines()
    #get the canvas size from the 0th line
    canvHeight, canvWidth = lines[0].split(",")
    canvSize = (int(canvHeight.strip()), int(canvWidth.strip()))
    #get the rectangle size information from lines 1-end
    rectangles = []
    for i in range(1,len(lines)):
        height, width = lines[i].split(",")
        height = int(height)
        width = int(width)
        rectangles.append(Rectangle(height, width))
    #pack the rectangles
    packedRect = pack(rectangles, canvSize)
    #create the canvas
    canv = CustomCanvas(canvHeight, canvWidth)
    #draw the rectangles on the canvas
    canv.drawRects(packedRect)

#code given in the lecture notes that calls main if this
#is run a standalone file but not if loaded as a library
if __name__ == "__main__":
    main()
