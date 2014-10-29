# Copyright 2014 Rico Simke, Leipzig University Library
# http://www.ub.uni-leipzig.de
#
# This code is the result of the project "Die Bibliothek der Milliarden Wörter".
# This project is funded by the European Social Fund. "Die Bibliothek der
# Milliarden Wörter" is a cooperation project between the Leipzig University
# Library, the Natural Language Processing Group at the Institute of Computer
# Science at Leipzig University, and the Image and Signal Processing Group
# at the Institute of Computer Science at Leipzig University.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

class MarcRecordsController < ApplicationController

  require 'open-uri' 

  def index
  	@marc_records = MarcRecord.all

  	respond_to do |format|
  	  format.html # index.html.erb
  	  format.json { render json: @marc_records }
  	end
  end

  def show
  	@marc_record = MarcRecord.find(params[:id])
    if params[:download] == "marcxml"
        send_data(@marc_record.marc, :filename => @marc_record.id.to_s+".xml", :type => "text/html")
    elsif params[:download] == "mods"
        send_data(@marc_record.marc2mods, :filename => @marc_record.id.to_s+".mods.xml", :type => "text/html")
    else
    	respond_to do |format|
    	  format.html # show.html.erb
    	  format.json { render json: @marc_record }
    	end
    end
  end

  def new
  	@marc_record = MarcRecord.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @marc_record }
    end
  end

  def create
    @marc_record = MarcRecord.new(params[:marc_record].permit(:marc))

  	respond_to do |format|
  	  if @marc_record.save
  	    format.html { redirect_to @marc_record, notice: 'MarcRecord was successfully created.' }
  	    format.json { render json: @marc_record, status: :created, location: @marc_record }
  	  else
  	    format.html { render action: "new" }
  	    format.json { render json: @marc_record.errors, status: :unprocessable_entity }
  	  end
  	end
  end

  def edit
    @marc_record = MarcRecord.find(params[:id])
  end

  def update
    @marc_record = MarcRecord.find(params[:id])

    respond_to do |format|
      if @marc_record.update_attributes(params[:marc_record].permit(:marc))
        format.html { redirect_to @marc_record, notice: 'MarcRecord was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @marc_record.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
  	@marc_record = MarcRecord.find(params[:id])

  	if !(Edition.where(:marc_record_id => @marc_record.id).exists? || Oclc.where(:marc_record_id => @marc_record.id).exists?)
  	  if @marc_record.destroy
    	  respond_to do |format|
    	    format.html { redirect_to marc_records_url, notice: 'MarcRecord was successfully destroyed.'  }
    	    format.json { head :no_content }
    	  end
      else
        respond_to do |format|
          format.html { redirect_to marc_records_url, alert: 'MarcRecord could not be destroyed due to dependencies.'  }
          format.json { head :no_content }
        end
      end
  	else
  		respond_to do |format|
  			format.html { redirect_to marc_records_url, alert: 'MarcRecord could not be destroyed due to dependencies.'  }
  			format.json { render json: @marc_record.errors, status: :unprocessable_entity }
  		end
  	end
  end

  def import
    MarcRecord.import(params[:file])
    redirect_to marc_records_url, notice: "marc Record imported."
  end

  def importWithId(query, url, source)
    begin
      content = open(URI.parse(url))
    rescue OpenURI::HTTPError
      false
    else
      begin
        marcxml = content.string
      rescue NoMethodError
        false
      else
        MarcRecord.create :marc => marcxml.unpack('U*').pack('U*')
      end
    end
  end

  def archiveOrgId
    query = params[:q]
    link = "https://archive.org/download/"
    suffix = "_archive_marc.xml"
    source = "Archive.org ID"
    url = link + query + "/" + query + suffix
    record = importWithId query, url, source
    if record
      redirect_to record, notice: "created MARCXML record from " + source + " " + query
    else
      redirect_to new_marc_record_path, alert: "Could not find any metadata for given identifier"
    end
  end

  def fincId
    query = params[:q]
    edition_id = params[:finc][:edition_id].to_i
    record = nil
    link = "http://data.ub.uni-leipzig.de/marcxml/"
    url = link + query
    source = "finc ID"
    if query == ""
      redirect_to new_marc_record_path, alert: "No identifier provided"
    else
      record = importWithId query, url, source
      if record
        f = FincRecord.create :url => query, :marc_record_id => record.id
        Finc.create :edition_id => edition_id, :finc_record_id => f.id
        redirect_to record, notice: "created MARCXML record from " + source + " " + query
      else
        redirect_to new_marc_record_path, alert: "Could not find any metadata for given identifier"
      end
    end
  end

end
