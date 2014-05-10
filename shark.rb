require 'digest'
require 'rest-client'
require 'json'
require 'ap'
require 'ostruct'


class GrooveShark
  URL_BASE = 'http://grooveshark.com/more.php'
  URL_INITIATE = 'http://grooveshark.com/more.php?initiateSession'
  URL_GETTOKEN = 'https://grooveshark.com/more.php?getCommunicationToken'
  URL_GETSTREAMKEY = 'http://grooveshark.com/more.php?getStreamKeyFromSongIDEx'

  CLIENT_WEB = '{"client":"htmlshark","clientRevision":"20130520","country":{"ID":110,"CC1":0,"CC2":35184372088832,"CC3":0,"CC4":0,"DMA":0,"IPR":0}}'
  CLIENT_JSPLAYER = '{"client":"jsplayer","clientRevision":"20120124.05","country":{"ID":"223","CC1":"0","CC2":"0","CC3":"0","CC4":"2147483648"}}'

  attr_accessor :config
  def initialize(conf = :web)
    case conf
    when :web then
      @config = OpenStruct.new(JSON.parse(CLIENT_WEB))
    when :jsplayer then
      @config = OpenStruct.new(JSON.parse(CLIENT_JSPLAYER))
    end
    @config.secretKey = 'needsMoarFoodForSharks'
  end


  def uuid
    @uuid ||= gen_uuid
  end

  def session
    @session ||= post_json(URL_INITIATE,
                           :header => {
                             :client => config.client,
                             :clientRevision => config.clientRevision,
                             :uuid => uuid
                           },
                           :parameters => nil,
                           :method => 'initiateSession')['result']
  end

  def token
    @token ||= post_json(URL_GETTOKEN,
                         :header => {
                           :client => config.client,
                           :clientRevision => config.clientRevision,
                           :uuid => uuid,
                           :session => session
                         },
                         :parameters => {
                           :secretKey => hash_session(session)
                         },
                         :method => 'getCommunicationToken')['result']
  end

  def get_streaming_url(song_id)
    sk = get_streamkey(song_id)
    "http://#{sk['ip']}/stream.php?streamKey=#{sk['streamKey']}"
  end
  def get_streamkey(song_id)
    request('getStreamKeyFromSongIDEx',
            :prefetch => false,
            :type => 0,
            :mobile => false,
            :songID => song_id,
            :country => config.country)['result']
  end

  def list_playlist_songs(playlist_id)
    request('playlistGetSongs', :playlistID => playlist_id)['result']['Songs']
  end

  ARIA2_CONF = {
    'continue' => 'true',
    'max-connection-per-server' => '5',
    'split' => '10',
    'parameterized-uri' => 'true'
  }

  def generate_aria2_export_from_playlist(songs)
    songs.each do |song|
      song_id = song['SongID']
      song_name = song['Name']
      song_url = get_streaming_url(song_id)
      puts song_url
      puts "  out=#{song_name}.mp3"
      ARIA2_CONF.each do |k,v|
        puts "  #{k}=#{v}"
      end
    end
  end


  private
  def post_json(url, req)
    begin
      resp = RestClient.post(url,
                             req.to_json,
                             :content_type => 'json',
                             :accept => 'json')
    rescue Exception
      raise
    else
      result = JSON.parse(resp.to_str)
      result.has_key? 'result' and result or raise resp
    end
  end
  def request(method, parameters)
    post_json(URL_BASE + "?#{method}",
              :header => {
                :client => config.client,
                :clientRevision => config.clientRevision,
                :uuid => uuid,
                :session => session,
                :token => hash_token(method, token)
              },
              :parameters => parameters,
              :method => method)
  end

  def hash_token(method, token)
    randomizer = (0..2).map { rand(256).to_s(16).rjust(2,'0') }.join
    token = "#{method}:#{token}:#{config.secretKey}:#{randomizer}"
    hash = Digest::SHA1.hexdigest(token).to_s
    randomizer + hash
  end
  def hash_session(session)
    Digest::MD5.hexdigest(session).to_s
  end
  def gen_uuid
    #  '2d931510-d99f-494a-8c67-87feb05e1594'
    [4,2,2,2,6].map do |x|
      (1..x).map { rand(256).to_s(16).rjust(2,'0') }.join
    end.join('-')
  end


end
