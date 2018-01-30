# godot_balloon_text

<img src="https://raw.githubusercontent.com/marcosbitetti/godot_balloon_text/master/assets/balloon/ico.png" alt="logo" style="width: 128px; height: 128px; display: block;" />

For anyone that love comics/manga.
A asset to handle text in a comic balloon.

## Usage

See here the <a href="https://www.youtube.com/watch?v=TpI_OnYCyU8" target="_blank">tutorial in YouTube</a> to view usage an instalation.

## API

#### say( text:String [, duration:Float])

Draw text on screen.

#### say_with_stream( text:String, stream:AudioStreamPlay )

Draw text on screen, and plays an audio stream for the character's voice.

#### ask( text:String, okText:String, okFunc:String [, calcelText:String, cancelFunc:String] )

Draw text, and wait for user interaction.

#### target( objectPath:String )

Set object to be pointed by the arrow. If null the balloon appears without an arrow.


## License
<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>.<br />Based on a work at <a xmlns:dct="http://purl.org/dc/terms/" href="https://github.com/marcosbitetti/godot_balloon_text" rel="dct:source">https://github.com/marcosbitetti/godot_balloon_text</a>.
