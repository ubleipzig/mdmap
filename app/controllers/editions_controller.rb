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

class EditionsController < ApplicationController

  # GET /editions
  # GET /editions.json
  def index
    @editions = Edition.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @editions }
    end
  end

  # GET /editions/start
  # GET /editions7start.json
  def start
    @editions = Edition.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @editions }
    end
  end

  # GET /editions/1
  # GET /editions/1.json
  def show
    @edition = Edition.find_by_id(params[:id])
    if !@edition.nil?
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @edition }
      end
    else
      respond_to do |format|
        format.html { redirect_to editions_url, alert: 'Edition '+params[:id]+' could not be found' }
      end
    end
  end

  def new
    @edition = Edition.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @edition }
    end
  end

  # POST /editions
  # POST /editions.json
  def create
    @edition = Edition.new(params[:edition].permit(:oclc_id, :best_match_id, :marc_record_id, :name))
    respond_to do |format|
      if @edition.save
        format.html { redirect_to @edition, notice: 'Edition was successfully created.' }
        format.json { render json: @edition, status: :created, location: @edition }
      else
        format.html { render action: "new" }
        format.json { render json: @edition.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /editions/1/edit
  def edit
    @edition = Edition.find(params[:id])
  end

  # PUT /editions/1
  # PUT /editions/1.json
  def update
    @edition = Edition.find(params[:id])

    respond_to do |format|
      if @edition.update_attributes(params[:edition].permit(:oclc_id, :best_match_id, :marc_record_id, :name))
        format.html { redirect_to action: "index" }
        # format.html { redirect_to @newsletter, notice: 'Newsletter was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @edition.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @edition = Edition.find(params[:id])

    if @edition.destroy
      respond_to do |format|
        format.html { redirect_to editions_url,  notice: 'Edition was successfully destroyed.'  }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to action: "index", alert: 'An error occurred.' }
        format.json { render json: @edition.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /editions/1/xOclc
  def xOclc
    @edition = Edition.find(params[:id])
    xOclcList = @edition.saveNumbers
    respond_to do |format|
      format.json { render json: xOclcList}
    end
  end

  # GET /editions/1/finc
  def finc
    @edition = Edition.find(params[:id])
    fincList = @edition.saveFincRecords
    respond_to do |format|
      format.json { render json: fincList}
    end
  end

  # GET /editions/1/map
  def map
    @edition = Edition.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @edition }
    end
  end

  def save_best_match
    @edition = Edition.find(params[:id])

    hash = JSON.parse params[:marcHash]
    record = MARC::Record.new_from_hash(hash)
    puts record
    writer = MARC::XMLWriter.new('marc.xml')
    writer.write(record)
    writer.close()
    file = File.new('marc.xml')
    @marc = file.read
    file.close
    File.delete('marc.xml')
    # save marc to new marc record
    @marc_record = MarcRecord.new(:marc => @marc)
    @marc_record.save
    MarcRecord.find(@edition.best_match_id).destroy if @edition.best_match_id
    @edition.best_match_id = @marc_record.id
    @edition.save

    respond_to do |format|
      format.json { render json: record }
    end
  end

end