# Copyright 2014 Library of Billion Words, Leipzig University
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

class FincRecordsController < ApplicationController
  before_action :set_finc_record, only: [:show, :edit, :update, :destroy]

  # GET /finc_records
  # GET /finc_records.json
  def index
    @finc_records = FincRecord.all
  end

  # GET /finc_records/1
  # GET /finc_records/1.json
  def show
  end

  # GET /finc_records/new
  def new
    @finc_record = FincRecord.new
  end

  # GET /finc_records/1/edit
  def edit
  end

  # POST /finc_records
  # POST /finc_records.json
  def create
  end

  # PATCH/PUT /finc_records/1
  # PATCH/PUT /finc_records/1.json
  def update
    respond_to do |format|
      if @finc_record.update(finc_record_params)
        # also update Finc
        finc_record_id = params[:id]
        edition_id = params[:edition_id].to_i
        finc = Finc.find_by(:finc_record_id => finc_record_id)
        finc.edition_id = edition_id
        finc.save
        # 
        format.html { redirect_to @finc_record, notice: 'Finc record was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @finc_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /finc_records/1
  # DELETE /finc_records/1.json
  def destroy
    @finc_record.destroy
    respond_to do |format|
      format.html { redirect_to finc_records_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_finc_record
      @finc_record = FincRecord.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def finc_record_params
      params[:finc_record]
    end
end
