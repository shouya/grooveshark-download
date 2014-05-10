grooveshark-download
====================

Download songs in a playlist from grooveshark in mp3 format.

Usage
===================
1. Extract the playlist ID from URL.

Example:

    http://grooveshark.com/#!/playlist/Anime/95866414  ==>  95866414

2. Generate aria2 importing file with the program `download_playlist.rb`.

Synopsis: `$ ruby download_playlist.rb <playlist_id>`

It will print the content of aria2 importing file in stdout.

Example:

    $ ruby download_playlist.rb 95866414 | tee /tmp/aria2.down

3. Download with aria2.

    $ aria2c -i <aria2_importing_file>

Example:

    $ aria2c -i /tmp/aria2.down

4. Edit ID3 tags if needed.

    $ easytags <music_file.mp3>

Development
======================

Any further improvement suggestion or bug reporting can be opened in [Issues](https://github.com/shouya/grooveshark-download/issues).

Pull requests are welcomed.


License
======================
The MIT License (MIT)

Copyright (c) 2014 Shou Ya

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.




