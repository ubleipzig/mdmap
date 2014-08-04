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

class PerseusRecord < ActiveRecord::Base
	require 'net/http'
	require 'uri'

	belongs_to :edition
	belongs_to :marc_record, dependent: :destroy

	# validates :edition_id, presence: true
	validates :urn, presence: true
	validates :urn, uniqueness: true

	before_save :updater

	def open(url)
		Net::HTTP.get(URI.parse(URI.encode(url)))
	end

	def save_mods
		# url = "http://catalog.perseus.org/catalog/" + urn  + "?format=atom"	
		url = "http://data.perseus.org/catalog/" + urn  + "/atom"	
		content = open url
		self.mods = content
	end

	# def mods2marc(stylesheet_path = "lib/MODS2MARC21slim.xsl")
	# def mods2marc(stylesheet_path = "lib/MODS3-4_MARC21slim_XSLT1-0.xsl")
	def mods2marc(stylesheet_path = "lib/MODS3-4_MARC21slim_XSLT1-0_PERSEUSCATALOG.xsl")
		xslt = Nokogiri::XSLT(File.read(stylesheet_path))
		document = Nokogiri::XML(self.mods)
		# suppose, there is only one mods node per atom-feed
		begin
			node = document.xpath("//mods:mods")[0]
		rescue Nokogiri::XML::XPath::SyntaxError
			false
		else
			node.set_attribute("xmlns:mods", "http://www.loc.gov/mods/v3")
			mods = Nokogiri::XML(node.to_xml)
			xslt.transform(mods)
		end
	end

	def create_marc_record
		if (xml = self.mods2marc)
			# <marc:record> => <record>
			xml.remove_namespaces!
			record = xml.xpath("//record")[0]
			record.set_attribute("xmlns", "http://www.loc.gov/MARC21/slim")
			m = MarcRecord.create :marc => xml.to_xml
			self.marc_record_id = m.id
		else
			false
		end
	end

	def updater
		self.save_mods
		marc_record = MarcRecord.find self.marc_record_id if self.marc_record_id
		marc_record.destroy if marc_record
		self.save_mods
		self.create_marc_record
	end

end
