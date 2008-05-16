# Inspired by GitNub's ImageLoadOperation
require 'osx/cocoa'

class LoadOperation < OSX::NSOperation
  include OSX
  
  def initWithURL_delegate(url, delegate)
    init
    
    @url = url
    @delegate = delegate
    @executing = false
    @finished = false
    self
  end
  
  def isConcurrent
    true
  end
  
  def start
    request = NSURLRequest.requestWithURL(@url)
    @connection = NSURLConnection.connectionWithRequest_delegate(request, self)
    puts @connection.inspect
    setExecuting true
  end
  
  def cancel
    super
    @connection.cancel
    setExecuting false
  end
  
  def isExecuting
    @executing
  end
  
  def isFinished
    @finished
  end
  
  # NSURLConnection Delegate methods
  def connection_didFailWithError(connection, error)
    @delegate.load_url_failed(@url, error)
    setExecuting false
    setFinished true
  end
  
  def connection_didReceiveResponse(connection, response)
    length = response.expectedContentLength
    @data = NSMutableData.dataWithCapacity(length < 0 ? 0 : length)
  end
  
  def connection_didReceiveData(connection, data)
    @data.appendData(data)
  end
  
  def connectionDidFinishLoading(connection)
    xml = @data.mutableBytes
    @delegate.url_finished(@url, xml)
    setExecuting false
    setFinished true
  end
  
  def connection_willSendRequest_redirectResponse(connection, request, redirectResponse)
    request
  end
  
  def connection_didReceiveAuthenticationChallenge(connection, challenge)
    newCredential = NSURLCredential.credentialWithUser_password_persistence(username, password, NSURLCredentialPersistenceNone)
    challenge.sender.useCredential_forAuthenticationChallenge newCredential, challenge
  end
  
  private
  
  def setExecuting(bool)
    self.willChangeValueForKey("isExecuting")
    @executing = bool
    self.didChangeValueForKey("isExecuting")
  end
  
  def setFinished(bool)
    self.willChangeValueForKey("isFinished")
    @finished = bool
    self.didChangeValueForKey("isFinished")
  end
end