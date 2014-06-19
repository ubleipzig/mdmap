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

function save_edition(edition_id, exit) {
  var ajax_url = "/editions/" + edition_id + "/save_best_match";

  // creating following json-structure:
  // http://bit.ly/1lhJbrR
  var marcHash = {};
  // is that ok?
  marcHash["leader"] = "      Z   22        4500"
  var fields = [];
  $("td.input").each(function(j) {
    var fieldHash = {};
    var field = $(this).data("field");
    var isControlField = (Number(field) < 10) ? true : false;
    var isEmpty = true;

    // control field
    if(isControlField && $(this).find("input.text_field").val() !== ""){
      var val = $(this).find("input.text_field").val();
      hash = {};
      hash[field] = val;
      isEmpty = false;
    }
    // not control field
    else {
      var ind1 = $(this).data("ind1").toString();
      var ind2 = $(this).data("ind2").toString();
      var subfields = [];
      $(this).find("input.text_field").each(function(k){
      var subfieldHash = {};
      // only store fields that are not empty
        if ($(this).val() !== "") {
          isEmpty = false;

          var subfield = $(this).data("subfield");
          var val = $(this).val();
          subfieldHash[subfield] = val;
          subfields.push(subfieldHash);
        }
      });

      fieldHash["subfields"] = subfields;
      fieldHash["ind1"] = ind1;
      fieldHash["ind2"] = ind2;
      hash = {}
      hash[field] = fieldHash;

    }
    // endif

    if (!isEmpty) fields.push(hash)
  });

  marcHash["fields"] = fields;

  ajaxHash = {};
  ajaxHash["marcHash"] = JSON.stringify(marcHash);
  
  $.ajax({
    url: ajax_url,
    data: ajaxHash,
    type: "POST",
    dataType: "JSON"
  }).success(function(json) {
    if (exit) {
      window.location.href = '/editions';
    }
    else {
      window.location.reload();
    }
  });
}

function buildHash(arr) {
  var obj = {};
  for (var i = 0, j = arr.length; i < j; i++) {
    if (obj[arr[i]]) {
      obj[arr[i]]++;
    } else {
      obj[arr[i]] = 1;
    }
  }
  return obj;
}

function sortHash(hash) {
  var sortable = [];
  for (var key in hash) {
    sortable.push([key, hash[key]]);
  }
  return sortable.sort( function(a, b) {
    return b[1] - a[1];
  });
}

// write data from selected field to input
function select(el) {
  var key = el.data("key");
  var number = el.data("number");
  var values = el.children("span");
  var parent = el.parent();
  var fields = $(".map input[data-key='" + key + "'][data-number='" + number + "']");
  fields.each(function(n) {
    var span = values.get(n);
    $(this).val($(span).data("value"));
    $(this).attr("title", $(span).data("value"));

  });
  parent.find(".selected").removeClass("selected");
  el.addClass("selected");

  var progressbar = $(".progress-bar[data-key='" + key + "'][data-number='" + number + "']");
  // title = "[" + key + "] " + val;
  // progressbar.attr("title", title);
  // progressbar.attr("data-value", val);
}

function getScrollValue(el) {
  var scroll = el.offset().top;
  scroll += el.height();
  scroll -= $(".dataTables_scrollBody").height();
  scroll += $(".dataTables_scrollBody").scrollTop();
  return scroll;
}

function appendProgressBar(key, number, field) {
  // calculate the size per row = number of sources that have a value for the field
  var row = $("tr[data-key='" + key + "'][data-number='" + number + "']").get(1);
  var amount = $(row).find("td:has(span)").length;
  var sources = $("table.map").data("sources");
  var size = 50 * amount / sources;
  // size="";
  $(".progress").append("<div style='display: table-cell;float:left;'><div class='progress-bar' data-key='" + key + "' data-number='" + number + "' title='" + key + " in " + amount + " of " + sources + "' data-size='" + size + "' style='border-bottom-width:" + size + "px;'><span>" + field + "</span></div></div>");
}

// document.ready
$(function() {

  $(".loading").remove();
  // codemirror for marc records
  if ($("#marc_record_marc").length > 0) {
    CodeMirror.fromTextArea(document.getElementById("marc_record_marc"), {});
  }

  // search for xoclc connections
  $(".runXOclc").on("click", function() {
    $(this).addClass("disabled");
    $(this).text("running xOclc");
    $.get($(this).data('path') + "/xOclc.json", function(data) {
      window.location.reload();
    });
  });

  // search for xoclc-finc connections

  $(".runFinc").on("click", function() {
    $(this).addClass("disabled");
    $(this).text("running finc");
    $.get($(this).data('path') + "/finc.json", function(data) {
      window.location.reload();
    });
  });

  // write selected value to input fields
  $(".map tr").each(function() {
    var selected = $(this).find(".selected");
    select($(selected));
  });

  // datatable and options
  var oTable = $("#map").dataTable({
    "bPaginate": false,
    // "sDom": 'T<"clear">lfrtip',
    // "sDom": 'Rlfrtip',
    // no filter because it does not work with input fields in the table
    "sDom": 'Rlrt',
    "sScrollX": "60%",
    "sScrollY": "680px",
    "bSort": false,
    "bScrollCollapse": true
    // ,"oColReorder": {
    //              "iFixedColumns": 2
    //          }
  });

  // navigation with keys
  // not working
  // var keys = new KeyTable( {
  //  "table": document.getElementById('map'),
  //  "datatable": oTable
  // } );

  // two fixed columns
  new FixedColumns(oTable, {
    "iLeftColumns": 3,
    "iLeftWidth": 286
  });


  // make toolbar
  // var width = 100/$(".map input").length + "%";
  $(".map td.input").each(function() {
    parent = $(this).parent();
    var key = $(parent).data("key");
    var field = $(parent).data("field");
    var number = $(parent).data("number");
    var val = $(parent).attr("title");
    appendProgressBar(key, number, field);
    // $(".progress").append("<div class='progress-bar' data-key='"+key+"' data-number='"+number+"' title='"+title+"'>"+key+"</div>");
  });

  // enable tooltip for long strings, progress-bar and input fields
  $(".map, .progress, input").tooltip();

  // show current position in progress-bar
  // highlight current tr
  $('.map').on("mouseenter", "tr",
    function() {
      key = $(this).data("key");
      number = $(this).data("number");
      $(".progress-bar[data-key='" + key + "'][data-number='" + number + "']").addClass("progress-bar-info");
      $("tr[data-key='" + key + "'][data-number='" + number + "']").addClass("hover");
    }).on("mouseleave", "tr",
    function() {
      key = $(this).data("key");
      $(".progress-bar[data-key='" + key + "'][data-number='" + number + "']").removeClass("progress-bar-info");
      $("tr[data-key='" + key + "'][data-number='" + number + "']").removeClass("hover");
    });

  $('.map').on("mouseenter", ".statbar", function() {
    var value = $(this).attr("value").toString();
    $("tr").find("[data-value='" + value + "']").addClass("hover");
  }).on("mouseleave", ".statbar", function() {
    var value = $(this).attr("value").toString();
    $("tr").find("[data-value='" + value + "']").removeClass("hover");
  });

  $('.map').on("mouseenter", "td.metaData", function() {
    var value = $(this).attr("data-value");
    $("tr").find(".statbar[value='" + value + "']").addClass("hover");
  }).on("mouseleave", "td.metaData", function() {
    var value = $(this).attr("data-value");
    $("tr").find(".statbar[value='" + value + "']").removeClass("hover");
  });

  // fill text fields with data from chosen field
  $(".map").on("click", "td.metaData", function() {
    select($(this));
  });

  // fill text fields with data from chosen column
  $(".map").on("click", "th.metaData", function() {
    $("td[data-marc-record=" + $(this).data("marc-record") + "]").each(function() {
      select($(this));
    });
  });

  // fill text fields with data from chosen statbar
  $(".map").on("click", ".statbar", function() {
    var td = $("<td>").hide();
    var key = $(this).parent().parent().data("key");
    $(td).attr("data-key", key);
    var number = $(this).parent().parent().data("number");
    $(td).attr("data-number", number);
    var values = JSON.parse($(this).prop("value"));

    for (var value in values) {
      var span = $("<span>");
      $(span).attr("data-value", values[value]);
      $(span).append(values[value]);
      $(td).append(span);
    }

    var row = $(".dataTables_scrollBody tr[data-key='" + key + "'][data-number='" + number + "']");
    $(row).append(td);
    select($(td));
    $(td).remove();
  });


  // when input value changed, remove 'selected class'
  $('.map').on('keyup input paste change', 'input.value', function() {
    var el = $(this);
    var key = el.data("key");
    var number = el.data("number");
    var val = el.val();
    el.attr("title", val);
    $(".map").find("tr[data-key='" + key + "'][data-number='" + number + "'] td.selected").removeClass("selected");
  });

  // highlight search result
  $("#map_filter").on('keyup input paste change', 'input', function() {
    $('#map').removeHighlight();
    $("#map").highlight($(this).val());
  });

  // clicked on table row = progress
  $(".map").on("click", "tr", function() {
    var el = $(this);
    var key = el.data("key");
    var number = el.data("number");
    $(".progress-bar[data-key='" + key + "'][data-number='" + number + "']").addClass("progress-bar-success");
  });

  $(".form-actions").on("click", ".save", function(evt) {
    edition_id = $(this).data("edition-id");
    exit = false;
    save_edition(edition_id, exit);
  });

  $(".form-actions").on("click", ".saveandexit", function(evt) {
    edition_id = $(this).data("edition-id");
    exit = true;
    save_edition(edition_id, exit);
  });

  // go to table row when clicking on progress-bar
  $(".progress").on("click", ".progress-bar", function() {
    var key = $(this).data("key");
    var number = $(this).data("number");
    var row = $("tr[data-key='" + key + "'][data-number='" + number + "']");
    var tds = $(row).find("td");
    var tdsNext = $(tds).parent().next().find("td");
    var flashColor = '#eee';
    setTimeout(function() {
      $(tds).css("border-top", "1px solid " + flashColor);
      $(tdsNext).css("border-top", "1px solid " + flashColor);
    }, 200);
    setTimeout(function() {
      $(tds).css("border", "");
      $(tdsNext).css("border", "");
    }, 700);

    scroll = getScrollValue(row);
    $(".dataTables_scrollBody").animate({
      scrollTop: scroll
    }, 'fast');
  });
  // add row
  // $('.addRow').keydown(function(e) {
  //   if (e.keyCode == 13) {
  //     var key = $(this).val();
  //     number = $("tbody:first").find("tr[data-key='" + key + "']").length + 1;
  //     $(this).val("");
  //     $("tbody").each(function() {
  //       var tr = $(this).find("tr").eq(-2).clone();
  //       tr.find(".label .badge").text(key);
  //       tr.attr("data-key", key);
  //       tr.find("input").attr("data-key", key);
  //       tr.attr("data-number", number);
  //       tr.find("input").attr("data-number", number);
  //       tr.find("input").val("");
  //       tr.find("input").attr("name", key);
  //       tr.find(".metaData").remove();
  //       $(this).find("tr:last").after(tr);
  //       scroll = getScrollValue(tr);
  //       tr.find("input:first").focus();
  //       $(".dataTables_scrollBody").animate({
  //         scrollTop: scroll
  //       }, 'fast');
  //     });
  //     appendProgressBar(key, number, "[" + key + "]");
  //   }
  // });

  // add statistics
  $(".DTFC_LeftWrapper tr").each(function() {
    var height = $(this).height() - 6;
    var stats = $(this).find("td.stats");
    var field = $(this).data("field");
    var key = $(this).data("key");
    var number = $(this).data("number");
    var sources = $("table.map").data("sources");
    var tr = $(".dataTables_scrollBody tr[data-field=" + field + "][data-key='" + key + "'][data-number=" + number + "]");
    var array = [];
    $(tr).find("td").each(function() {
      var title = $(this).attr("title");
      "" !== title && array.push(title);
    });
    var hash = buildHash(array);

    for (var pair in sortHash(hash).slice(0, 5)) {
      var value = sortHash(hash)[pair][0];
      var amount = sortHash(hash)[pair][1];
      var fraction = amount / sources;
      var percent = Math.round(fraction * 100);
      var bar = fraction * height;
      var div = $("<div class='statbar' style='border-bottom-width:" + bar + "px; height:" + height + "px'>" + amount + "</div>");
      $(div).attr("title", value + " " + percent + "%");
      $(div).attr("value", value);
      $(stats).append(div);
    }
  });

  //////
  // add row - not really working yet
  /////
  // $(".progress").after('<input class="newKey" type="text" placeholder="Add Field" style="background: url(/images/todo/done.png) no-repeat 96%;"><div class="addRow" style="position: relative;top: -40px;left: 177px;width: 20px;height: 20px;margin: 0px;padding: 0px;cursor:pointer;"></div>');

  // $("body").on("click", ".addRow", function(){
  //  // clone next-to-last row
  //  var row = new Array(2);
  //  var key = $(".newKey").val();
  //  row[0] = $(".DTFC_Cloned tr").eq(-2).clone();
  //  row[0].find(".label").text(key);
  //  row[0].find("input").val("");
  //  row[1] = $(".dataTable tr").eq(-2).clone();
  //  row[1].text("");

  //  // add after last row
  //  $(".DTFC_Cloned tr:last").after(row[0]);
  //  $(".dataTable tr:last").after(row[1]);

  //  // add progress bar
  //  var key = $(this).data("key");
  //  var number = $(this).data("number");
  //  var val = $(this).attr("title");
  //  title = "[" + key + "] " + val;
  //  $(".progress").append("<div class='progress-bar' data-key='"+key+"' data-number='"+number+"' title='"+title+"'>"+key+"</div>");
  // });
});
