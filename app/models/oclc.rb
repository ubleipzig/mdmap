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

class Oclc < ActiveRecord::Base
	# include ActiveModel::Dirty

	belongs_to :marc_record, :class_name => "MarcRecord", :foreign_key => :marc_record_id
	has_many :xoclcs, :dependent => :destroy
	has_many :editions, :through => :xoclcs

	validates :number, uniqueness: true
	validates :number, presence: true

	before_save :update_marc

	def getMarcXml(change=false)
		if (self.marc_record_id.nil?||change==true)
			require "open-uri"
			serviceurl = "http://worldcat.org/webservices/catalog/content/"
			wskey = APP_CONFIG['wskey']
			url = serviceurl + self.number.to_s + "?wskey=" + wskey
			marc_record = MarcRecord.create({:marc => open(url).read})
			self.marc_record_id = marc_record.id
		end
		self.marc_record_id
	end

	private

	def update_marc
		if self.getMarcXml(true)
			true
		end
	end

end
