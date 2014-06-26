# Copyright 2014 Rico Simke, Leipzig University Library
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

class OclcsController < ApplicationController

  # GET /oclcs
  # GET /oclcs.json
  def index
    @oclcs = Oclc.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @oclcs }
    end
  end

  # GET /oclcs/1
  # GET /oclcs/1.json
  def show
    @oclc = Oclc.find(params[:id])
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @oclc }
      end
  end

  def new
    @oclc = Oclc.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @oclc }
    end
  end

  # POST /oclcs
  # POST /oclcs.json
  def create
    @oclc = Oclc.new(params[:oclc].permit(:marc, :number))

    respond_to do |format|
      if @oclc.save
        format.html { redirect_to @oclc, notice: 'Oclc was successfully created.' }
        format.json { render json: @oclc, status: :created, location: @oclc }
      else
        format.html { redirect_to oclcs_url, alert: 'Oclc already exists' }
        format.json { render json: @oclc.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /oclcs/1/edit
  def edit
    @oclc = Oclc.find(params[:id])
    @xoclcs = @oclc.xoclcs
    
  end

  # PUT /oclcs/1
  # PUT /oclcs/1.json
  def update
    @oclc = Oclc.find(params[:id])

    respond_to do |format|
      if @oclc.update_attributes(params[:oclc].permit(:marc, :number))
        format.html { redirect_to action: "index" }
        # format.html { redirect_to @newsletter, notice: 'Newsletter was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @oclc.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /oclcs/1
  # DELETE /oclcs/1.json
  def destroy
    @oclc = Oclc.find(params[:id])

    respond_to do |format|

      unless Edition.where(:oclc_id => @oclc.id).exists?
        @oclc.destroy
        respond_to do |format|
          format.html { redirect_to oclcs_url }
          format.json { head :no_content }
        end
      else
        format.html { redirect_to action: "index" }
        format.json { render json: @oclc.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /oclcs/1/marc
  def marc
    @oclc = Oclc.find(params[:id])
    marcXml = @oclc.getMarcXml
    respond_to do |format|
      format.html { marcXml }
      format.json { render json: marcXml}
    end
  end



end