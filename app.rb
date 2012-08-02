require 'sinatra'
require 'sinatra/activerecord'
ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database =>  'db/sqlite3.db'

#Models
class Project < ActiveRecord::Base
  has_many :editors
end

class Editor < ActiveRecord::Base
  belongs_to :project
end

get '/' do
  @projects = Project.all

  erb :"projects/index", layout: :layout
end

get '/projects/new' do
  @projects = Project.all

  erb :"projects/new", layout: :layout
end

post '/projects' do
  @project = Project.new(params[:project])
  if @project.save
    redirect "/project/#{@project.id}"
    else
    "Cannot create project"
  end
end

get '/projects/:id/edit' do
  @project = Project.find(params[:id])
  erb :"projects/edit", layout: :layout
end

put '/projects/:id' do
  @project = Project.find(params[:id])
  if @project.update_attributes(params[:project])
    redirect "/projects/#{@project.id}"
    else
    erb :"projects/edit", layout: :layout
  end
end

get '/projects/:id' do
  @project = Project.find(params[:id])
  @editors = @project.editors
  erb :"projects/editors/index", layout: :editor_layout
end

get '/projects/_data/:id' do
  @project = Project.find(params[:id])
  params[:root] = '' if params[:root] == 'source'
  if !params[:root] || params[:root].empty?
    path = "/"
  else
    path = params[:root]
  end

  full_path = @project.path + sanitize_path(path)
  dir_list = Dir.entries(full_path)

  dirs = []
  files = []
  dir_list.each do |filename|
    if File.directory?("#{full_path}/#{filename}")
      next if filename == '..' || filename == '.'
      dirs << {"text" => filename,
                "id" => "#{sanitize_path(path)}/#{filename}",
                "hasChildren" => true }
    else
      files << {"text" => "<a href='#' onclick=\"fileClicked(jQuery(this))\" class=\"file\" data-file='#{path}/#{filename}'>#{filename}</a>",
                "hasChildren" => false }
    end
  end
  dirs.sort! {|a,b| a['text']<=>b['text']}
  files.sort! {|a,b| a['text']<=>b['text']}
  (dirs + files).to_json
end


get '/projects/:id/_data' do
  @project = Project.find(params[:id])
  full_path = @project.path + sanitize_path(params[:path])
  data = ''
  if File.readable?(full_path)
    f = File.new(full_path,'r')
    data = f.read
  else
    data "Unreadable file! Fail!!"
  end
  modified_time = File.mtime(full_path)
  {data: data, modified_time: modified_time}.to_json
end

get '/projects/:id/_data/mtime' do
  @project = Project.find(params[:id])
  full_path = @project.path + sanitize_path(params[:path])
  modified_time = File.mtime(full_path);
  {modified_time: modified_time}.to_json
end


#helpers
def sanitize_path(path)
  require "shellwords"
  Shellwords.shellwords(path).first.gsub('..','')
  #path.gsub(/(?=[^a-zA-Z0-9_.\/\-\x7F-\xFF\n])/n, '\\').gsub(/\n/, "'\n'").sub(/^$/, "''")
end
