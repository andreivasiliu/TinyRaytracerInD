
rename()
{
    for i in `seq 0 9`; do
        [ -e output$i.png ] && mv -vf output$i.png output00$i.png
    done
    
    for i in `seq 10 99`; do
        [ -e output$i.png ] && mv -vf output$i.png output0$i.png
    done
}

convert_to_tga()
{
    for file in `ls *.png`; do
        [ -e ${file%.png}.tga ] && continue
        echo "Converting $file..."
        convert $file ${file%.png}.tga
    done
}

mencode1()
{
    mencoder mf://*.tga -mf w=$WIDTH:h=$HEIGHT:fps=$FPS:type=tga -ovc \
             lavc -o output.avi -lavcopts vcodec=ffv1
}

mencode2()
{
    mencoder mf://*.tga -mf w=${WIDTH}:h=${HEIGHT}:fps=$FPS:type=tga -ovc \
             lavc -o output.avi -lavcopts vcodec=mpeg4
}

loop()
{
    mencoder -oac copy -ovc copy -o 'looped_output.avi' 'output.avi' \
             'output.avi' 'output.avi' 'output.avi' 'output.avi'
}

export FPS=30
export WIDTH=640
export HEIGHT=480

cd output
rename
convert_to_tga
mencode1
loop

#cd output && rename && convert_to_tga && mencode1 && loop
