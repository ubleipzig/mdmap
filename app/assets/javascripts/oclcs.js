// Copyright 2014 Library of Billion Words, Leipzig University
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


function updateProgressbar(percent) {
	$(".progress .bar").css("width", percent + "%");
}

function getMarc(oclcbutton, callback) {
	$.get( $(oclcbutton).data('path') + "/marc.json", function( data ) {
		if(callback != undefined && typeof callback == 'function') callback();
	});
}

$(document).ready(function() {
	$(".getMarcXml").on("click", function() {
		getMarc(this, function() {
			window.location.reload();
		});
	});

	$(".getAllMarcXml").on("click", function() {
		$(this).addClass("disabled");
		len = $(".getMarcXml").length;
		lenCurrent = len;
		scale = 100/len;

		$(".getMarcXml").each(function() {
			getMarc(this, function(){
				lenCurrent = lenCurrent-1;
				percent = 100-lenCurrent*scale;
				updateProgressbar(percent);
				if (percent==100){
					window.location.reload();
				}
			})
		});
	});
});