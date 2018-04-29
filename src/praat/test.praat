# praat scipt which takes a filename as the argument, 
#opens it, creates a sound object, a pitch object 
# and exports the pitch contour as a text file with the same name as the input filename

form Open file
    word fileName c.mp3
endform
writeInfoLine: fileName$
Read from file... 'fileName$'
object_name$ = selected$ ("Sound")

