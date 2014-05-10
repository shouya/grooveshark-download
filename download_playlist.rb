require_relative 'shark'

if ARGV.length != 1
  puts "Usage: #{$0} [playlist_id]"
  puts "  Example: #{$0} 96131821 | tee aria2.down"
  exit
end

playlist_id = ARGV[0]
songs = GrooveShark.new(:web).list_playlist_songs(playlist_id)
GrooveShark.new(:jsplayer).generate_aria2_export_from_playlist(songs)
