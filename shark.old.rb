require 'digest'
require 'rest-client'
require 'json'


def config
  OpenStruct.new(:client => "jsplayer",
                 :clientRevision => "20120124.05",
                 :secretKey => "needsMoarFoodForSharks",
                 :country => {
                   :ID => "223",
                   :CC1 => "0",
                   :CC2 => "0",
                   :CC3 => "0",
                   :CC4 => "2147483648"
                 })
end

URL_INITIATE = 'http://grooveshark.com/more.php?initiateSession'
URL_GETTOKEN = 'https://grooveshark.com/more.php?getCommunicationToken'
URL_GETSTREAMKEY = 'http://grooveshark.com/more.php?getStreamKeyFromSongIDEx'


def hashtoken(method, token)
  randomizer = (0..2).map { rand(256).to_s(16) }.join
  token = "#{method}:#{token}:#{config.secretKey}:#{randomizer}"
  hash = Digest::SHA1.hexdigest(token)
  randomizer + hash
end
def hashsession(session)
  Digest::MD5.hexdigest(session)
end
def uuid
  #  '2d931510-d99f-494a-8c67-87feb05e1594'
  [4,2,2,2,6].map do |x|
    (1..x).map { rand(256).to_s(16) }.join
  end.join('-')
end

def init_session(uuid = uuid)
  res = RestClient.post(URL_INITIATE,
                        :header => {
                          :client => config.client,
                          :clientRevision => config.clientRevision,
                          :uuid => uuid
                        },
                        :parameters => nil,
                        :method => 'initiateSession')
  JSON.parse(res)['result']
end

def get_token(session, uuid)
  res = RestClient.post(URL_GETTOKEN,
                        :header => {
                          :client => config.client,
                          :clientRevision => config.clientRevision,
                          :uuid => uuid,
                          :session => session
                        },
                        :parameters => {
                          :secretKey => hashsession(session)
                        },
                        :method => 'initiateSession')
  JSON.parse(res)['result']
end

def get_streamkey(session, token, uuid, song_id)
  res = RestClient.post(URL_GETTOKEN,
                        :header => {
                          :client => config.client,
                          :clientRevision => config.clientRevision,
                          :uuid => uuid,
                          :session => session,
                          :token => hashtoken('getStreamKeyFromSongIDEx', token)
                        },
                        :parameters => {
                          :prefetch => false,
                          :type => 0,
                          :mobile => false,
                          :songID => song_id,
                          :country => config.country,
                          :secretKey => hashsession(session)
                        },
                        :method => 'initiateSession')
  JSON.parse(res)['result']['streamKey']
end

def streamkey_to_url(streamkey)
  "http://#{streamkey['ip']}/stream.php?streamKey=#{streamkey['streamKey']}"
end

gs = config.dup
gs['songID'] = 35988886
