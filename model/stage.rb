#
#  stage.rb
#  macistrano
#
#  Created by Pom on 25.04.08.
#  Copyright (c) 2008 __MyCompanyName__. All rights reserved.
#

require 'osx/cocoa'
require 'builder'
require 'net/http'
require 'net/https'

class Stage
  attr_accessor :id, :project, :name, :tasks
  
  def default_header
    @default_header ||= { 'Content-Type' => 'text/xml' }
  end
  
  def build_request_headers(headers, host)
    authorization_header(host).update(default_header).update(headers)
  end
  
  # Sets authorization header; authentication information is pulled from credentials provided with site URI.
  def authorization_header(host)
    { 'Authorization' => 'Basic ' + ["#{host.username}:#{ host.password}"].pack('m').delete("\r\n") }
  end
  
  def run_stage task, comment
    url = URI.parse("#{project.host.url}/projects/#{project.id}/stages/#{self.id}/deployments.xml")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = url.is_a?(URI::HTTPS)
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE if http.use_ssl?
    http.post(url.path, new_deployment_as_xml(task, comment).to_s, build_request_headers({}, project.host)).value
  end
  
  def new_deployment_as_xml task, comment
    xml = Builder::XmlMarkup.new(:indent => 2)
    xml.instruct!
    xml.deployment do |xml|
      xml.task task
      xml.description comment
    end
    xml.target!
  end
  
  def read_xml path
    io = open("#{project.host.url}#{path}", :http_basic_authentication => [project.host.username, project.host.password])
    io.read
  end
  
  def fetch_tasks
    @tasks = []
    result = read_xml "/projects/#{project.id}/stages/#{id}/tasks.xml"
    doc = Hpricot.XML(result)
    (doc/'record').collect do |data|
      task = Task.new
      task.name = (data/:name).text
      task.description = (data/:description).text
      task.stage = self
      @tasks << task
    end
  end
end
