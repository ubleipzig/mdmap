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

class PerseusRecordsController < ApplicationController
  before_action :set_perseus_record, only: [:show, :edit, :update, :destroy]

  # GET /perseus_records
  # GET /perseus_records.json
  def index
    @perseus_records = PerseusRecord.all
  end

  # GET /perseus_records/1
  # GET /perseus_records/1.json
  def show
    @perseus_record = PerseusRecord.find(params[:id])
    if params[:download] == "mods"
      send_data(@perseus_record.mods, :filename => @perseus_record.urn+".xml", :type => "text/html")
    else
      respond_to do |format|
        format.html
        format.json {render json: @perseus_record}
      end
    end
  end

  # GET /perseus_records/new
  def new
    @perseus_record = PerseusRecord.new
  end

  # GET /perseus_records/1/edit
  def edit
  end

  # POST /perseus_records
  # POST /perseus_records.json
  def create
      @perseus_record = PerseusRecord.new(perseus_record_params.permit(:urn, :edition_id))
    # @oclc = Oclc.new(params[:oclc].permit(:marc, :number))

    respond_to do |format|
      if @perseus_record.save
        format.html { redirect_to @perseus_record, notice: 'Perseus record was successfully created.' }
        format.json { render action: 'show', status: :created, location: @perseus_record }
      else
        format.html {redirect_to new_perseus_record_path, alert: "Could not find any metadata for given identifier" }
      end
    end
  end

  # PATCH/PUT /perseus_records/1
  # PATCH/PUT /perseus_records/1.json
  def update
    @perseus_record = PerseusRecord.find(params[:id])

    respond_to do |format|
      if @perseus_record.update(perseus_record_params.permit(:urn, :edition_id))
        format.html { redirect_to @perseus_record, notice: 'Perseus record was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @perseus_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /perseus_records/1
  # DELETE /perseus_records/1.json
  def destroy
    @perseus_record.destroy
    respond_to do |format|
      format.html { redirect_to perseus_records_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_perseus_record
      @perseus_record = PerseusRecord.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def perseus_record_params
      params[:perseus_record]
    end
end
