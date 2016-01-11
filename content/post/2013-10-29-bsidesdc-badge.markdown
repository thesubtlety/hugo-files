---
author: noah
comments: false
date: 2013-10-29 01:19:19+00:00
layout: post
slug: bsidesdc-badge
title: 'BSidesDC Badge '
wordpress_id: 106
tags:
- BSides
- Python
---

I recently attended my first security conference: BSidesDC. This isn't a write up of that experience, although it was quite interesting and I learned a lot via some great sessions. One talk I really enjoyed by [@grecs](https://twitter.com/grecs) was [Malware Analysis 101](https://www.novainfosec.com/2013/10/19/malware-analysis-slides-from-bsidesdc/). Very well presented with lots of great getting started material.

{{< figure src="/img/bsides-150x150.jpg" >}} 

Anyways, the badges. Pretty cool badges; bottle openers in fact, with fourteen binary bytes all with leading zeroes around the circumference: ascii encoded [binary](https://en.wikipedia.org/wiki/Binary_code). The message is trivially found via google, but where's the fun in that? And wanting to play around with Python some more I decided to write something that could decode the binary. My first stab looks like this.

    
    #!/usr/bin/python
    # This was a quick and dirty excercise in Python without googling the answer. 
    # No error checking, etc... Check out the Python unicode page and the BitManipulation
    # page for more info and probably the proper way to do this. 
    
    import argparse
    
    def main():
    
        #argparse is overkill for this, but was fun to play around with
        parser = argparse.ArgumentParser(description="Convert between ascii and binary "
                                                      and vice verse.")
        group = parser.add_mutually_exclusive_group(required=True)
        group.add_argument('--to_binary', action="store", dest="ascii", nargs="+")
        group.add_argument('--to_ascii', action="store", dest="bin", nargs="+")
        args = parser.parse_args()
    
        #Sends user input to the appropriate function
        if args.ascii is not None:
            to_binary(args.ascii)
        elif args.bin is not None:
            to_ascii(args.bin)
    
    def to_binary(args):
        chars_bin = [bin(ord(each)) for each in [item for sublist in args for item in \
                    sublist]] 
        print " ".join([each[2:].zfill(8) for each in chars_bin])
        ### The Stack Overflow way
        ### print ''.join('{:08b}'.format(ord(each)) for each in args) 
    
    def to_ascii(args):
        print "".join([(chr(int(str(each),2))) for each in args])
        ### The Stack Overflow way
        ### print "".join(chr(args[i:i+8],2)) for i in xrange(0, len(args), 8)) 
    
    if __name__ == "__main__": main()


And running this with our badge's binary:

    
    python binary_ascii.py --to_ascii 01101001 01101110 01100010 01100101 01100101 \
    01110010 01110111 01100101 01110100 01101000 01101001 01110010 01110011 01110100 
    inbeerwethirst
    
    python binary_ascii.py --to_ascii 01100010 01110011 01101001 01100100 01100101 \
    01110011 01110011 01100101 01100011 01110101 01110010 01101001 01110100 01111001 
    bsidessecurity


Much cleverness by the organizers. One side says "BSides Security" and the other "In Beer We Thirst"...
