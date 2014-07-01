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

class MarcRecord < ActiveRecord::Base

	require 'nokogiri'

	serialize :keyArray
	serialize :fingerprintHash

	has_many :editions, dependent: :destroy
	has_many :oclc, dependent: :destroy

	has_one :perseus_record

	before_save :update_valid, :saveFingerprints


	def parseMarc
		File.open('marc_tmp', 'w') { |f| f.write(self.marc)}
		reader = MARC::XMLReader.new('marc_tmp')
		# File.delete('marc_tmp')
		reader
	end

	def getMarcArray
		m = parseMarc
		for record in m
			r = record.to_hash
		end
		if r
			r["fields"]
		else
			{}
		end
	end

	def getMarcHash
		JSON.parse(marcHash)
	end

	def self.import(file)
		MarcRecord.create! marc: file.read
	end

	def saveFingerprints
		fingerprints = {}
		allKeys = []
		for entry in self.getMarcArray
			keyString = entry.keys[0]
			keyString += "|" + entry[entry.keys.first]["ind1"] + entry[entry.keys.first]["ind2"] if entry[entry.keys.first]["ind1"]
			if entry[entry.keys.first]["subfields"]
				keyString += "|" + entry[entry.keys.first]["subfields"].flat_map(&:keys).join("|")
			end
			unless fingerprints[keyString]
				fingerprints[keyString] = []
			end
			allKeys.push keyString
			if subfields = entry[entry.keys.first]["subfields"]
				fingerprints[keyString].push subfields.flat_map(&:values)
			else
				# entry = {"001"=>"9675323"}
				fingerprints[keyString].push entry.values
			end
		end
		self.keyArray = allKeys
		self.fingerprintHash = fingerprints
	end


	def validMarcXml?(schema_path = "lib/MARC21slim.xsd")
		schema   = Nokogiri::XML::Schema(File.read(schema_path))
		document = Nokogiri::XML(self.marc)
		schema.valid?(document)
	end

	def validateMarcXml(schema_path = "lib/MARC21slim.xsd")
		schema   = Nokogiri::XML::Schema(File.read(schema_path))
		document = Nokogiri::XML(self.marc)
		schema.validate(document)
	end

	def marc2mods(stylesheet_path = "lib/MARC21slim2MODS3.xsl")
		xslt = Nokogiri::XSLT(File.read(stylesheet_path))
		document = Nokogiri::XML(self.marc)
		xslt.transform(document)
	end

	
	def getMarcKeys
		keys = []
		for hash in getMarcArray
			keys.push hash.keys[0]
		end
		keys.sort
	end

	def getMarcIndicators(key)
		indicators = []
		for el in getMarcArray
			if el.values[0]["ind1"]
				indicators.push el.values[0]["ind1"]
				indicators.push el.values[0]["ind2"]
				indicators
			end
		end
		indicators
	end

	private

	def update_valid
		self.isValidMarcXml = self.validMarcXml?
	  	true
	end

end