# diff image
```shell
compare image1 image2 -compose src diff.png
compare image1 image2 -compose src diff.pdf
compare -density 300 image1 image2 -compose src diff.jpeg
compare \
        porsche-with-scratch.pdf  porsche-original.pdf \
       -compose src \
        diff-compose-default.pdf

compare \
        porsche-with-scratch.pdf  porsche-original.pdf \
       -compose src \
       -highlight-color seagreen \
        diff-compose-default.pdf

compare \
        porsche-with-scratch.pdf  porsche-original.pdf \
       -highlight-color blue \
        diff-compose-default.pdf


convert '(' file1.png -flatten -grayscale Rec709Luminance ')' \
        '(' file2.png -flatten -grayscale Rec709Luminance ')' \
        '(' -clone 0-1 -compose darken -composite ')' \
        -channel RGB -combine diff.png
```


```ruby
baseline_resize_command = "convert #{input_file.shellescape} -background white -extent #{canvas[:width]}x#{canvas[:height]} #{output_file.shellescape}"
test_size_command = "convert #{input_file.shellescape} -background white -extent #{canvas[:width]}x#{canvas[:height]} #{output_file.shellescape}"
compare_command = "compare -alpha Off -dissimilarity-threshold 1 -fuzz #{fuzz} -metric AE -highlight-color '##{highlight_colour}' #{baseline_file.shellescape} #{compare_file.shellescape} #{diff_file.shellescape}"
Open3.popen3("#{baseline_resize_command} && #{test_size_command} && #{compare_command}") { |_stdin, _stdout, stderr, _wait_thr| stderr.read }
```