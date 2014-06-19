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

class Edition < ActiveRecord::Base

	belongs_to :oclc, :class_name => "Oclc", :foreign_key => :oclc_id
	belongs_to :marc_record, :class_name => "MarcRecord", :foreign_key => :marc_record_id
	belongs_to :best_match, :class_name => "MarcRecord", :foreign_key => :best_match_id
	has_many :xoclcs, dependent: :destroy
	has_many :oclcs, through: :xoclcs

	#for later use: cleans unused Oclc numbers
	def cleanOclcs
		for oclc in Oclc.all
			unless ((Xoclc.find_by(:oclc_id => oclc.id)) || Edition.find_by(:oclc_id => oclc.id))
				oclc.destroy
			end
		end
	end

	# http://xisbn.worldcat.org/xisbnadmin/xoclcnum/index.htm
	def getNumbers
		oclc = Oclc.find(self.oclc_id)
		require "net/http"
		serviceurl = "http://xisbn.worldcat.org/webservices/xid/oclcnum/"
		options = "format=txt&fl=oclcnum"
		url = serviceurl + oclc.number.to_s + "?" + options
		uri = URI.parse(url)
		req = Net::HTTP::Get.new( uri.to_s )
		res = Net::HTTP.start(uri.host, uri.port) {|http|
		  http.request(req)
		} 

		body = res.body
		oclclist = body.split(/\n/)
		oclclist.shift
		oclclist  
	end 

	def saveNumbers
		for num in self.getNumbers
			Oclc.create(:number => num) unless Oclc.exists?(:number => num)
			oclc_id = Oclc.where(:number => num).first.id
			unless Xoclc.exists?({:edition_id => self.id, :oclc_id => oclc_id})
				Xoclc.create ({:edition_id => self.id, :oclc_id => Oclc.where(:number => num).first.id})
			end
		end
		Xoclc.where(:edition_id => self.id)
	end

	def getFincMarcXml(url)
		require "open-uri"
		suffix = "/Export?style=MARCXML"
		o = open(url + suffix).read
		o.unpack('U*').pack('U*')
	end

	def getFincRecords
		domain = "katalog.ub.uni-leipzig.de"
		path = "/Search/Results?type=AllFields&SearchForm_submit=Finden&view=rss&lookfor="

		path += "oclc_num%3A\"" + Oclc.find(self.oclc_id).number.to_s + "\"+OR+"

		path += Xoclc.where(:edition_id => self.id).map { |k| "oclc_num%3A\"#{Oclc.find(k.oclc_id).number}\"" }.join("+OR+") 

		http = Net::HTTP.new(domain, 443)  
		http.use_ssl = true  
		resp = http.get(path)  
		xml_doc = Nokogiri::XML(resp.body)
		array = []
		xml_doc.children.xpath(".//item").each do |item|
			array.push item.xpath("link").text
		end
		array
	end

	def saveFincRecords
		for record in self.getFincRecords
			unless FincRecord.exists?(:url => record)
				f = FincRecord.new
				f.url = record
				marc_record = MarcRecord.new
				marc_record.marc = getFincMarcXml(record)
				marc_record.save
				f.marc_record_id = marc_record.id
				f.save
			end
			finc_record_id = FincRecord.where(:url => record).first.id
			unless Finc.exists?({:edition_id => self.id, :finc_record_id => finc_record_id})
				x = Finc.new
				x.edition_id = self.id
				x.finc_record_id = FincRecord.where(:url => record).first.id
				x.save
			end
		end
		Finc.where(:edition_id => self.id)
	end

	def getRecords
		# make a list of all records
		records = []
		records.push( [self.best_match_id, "matched metaData selected", "best match"] ) if self.best_match_id
		records.push( [self.marc_record_id, "original metaData", "original"] ) if self.marc_record_id
		records.push( [Oclc.find(self.oclc_id).marc_record_id, "oclc metaData", "oclc"] ) if self.oclc_id

		Finc.where(:edition_id => self.id).find_each do |finc|
			finc_record = FincRecord.find finc.finc_record_id
			record = MarcRecord.find(finc_record.marc_record_id).id
			records.push [record, "finc metaData", "finc"]
		end

		Xoclc.where(:edition_id => self.id).find_each do |xoclc|
			oclc = Oclc.find xoclc.oclc_id
			record = MarcRecord.find(oclc.marc_record_id).id
			records.push [record, "xoclc metaData", "xoclc"]
		end

		PerseusRecord.where(:edition_id => self.id).find_each do |perseus|
			record = MarcRecord.find(perseus.marc_record_id).id
			records.push [record, "perseus metaData", "perseus"]
		end
		records
	end

	def getRowKeys (records)
		rowKeys = []
		for marcId in records
			rowKeys = maxArray(rowKeys, MarcRecord.find(marcId[0]).keyArray )
		end
		puts rowKeys
		rowKeys
	end

	private

	# takes two arrays and returns an array with the maximum amount of every element
	# e.g.:
	# a =             [ 100, 100, 200,      300, 300, 300 ]
	# b =             [ 100,      200, 200, 300           ]
	# maxArray(a,b) = [ 100, 100, 200, 200, 300, 300, 300 ]
	# this is needed for computing the needed amount of every MARC field in the table
	def maxArray(a,b)
		for el in (a+b)
			sizea = (a.select {|num| num==el}).length
			sizeb = (b.select {|num| num==el}).length

			max = [sizea,sizeb].max
			b=b-[el]
			max.times do |x|
				b.push(el)
			end
		end
		if b[0].is_a? Hash
			b.sort_by { |k| k["tag"] } 
		else
			b.sort
		end
	end

end
