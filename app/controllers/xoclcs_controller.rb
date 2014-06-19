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

class XoclcsController < ApplicationController
	# GET /oclcs
	# GET /oclcs.json
	def index
	  @xoclcs = Xoclc.all

	  respond_to do |format|
	    format.html # index.html.erb
	    format.json { render json: @xoclcs }
	  end
	end

	def show
	  @xoclc = Xoclc.find(params[:id])
	    respond_to do |format|
	      format.html # show.html.erb
	      format.json { render json: @xoclc }
	    end
	end

	def edit
	  @xoclc = Xoclc.find(params[:id])
	end

	def update
		@xoclc = Xoclc.find(params[:id])

		 respond_to do |format|
		    if @xoclc.update_attributes(params[:edition].permit(:edition_id, :oclc_id))
		      format.html { redirect_to action: "index" }
		      format.json { head :no_content }
		    else
		      format.html { render action: "edit" }
		      format.json { render json: @xoclc.errors, status: :unprocessable_entity }
	    	end
		end
	 end
end
