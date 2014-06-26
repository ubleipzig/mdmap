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

require 'test_helper'

class PerseusRecordsControllerTest < ActionController::TestCase
  setup do
    @perseus_record = perseus_records(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:perseus_records)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create perseus_record" do
    assert_difference('PerseusRecord.count') do
      post :create, perseus_record: {  }
    end

    assert_redirected_to perseus_record_path(assigns(:perseus_record))
  end

  test "should show perseus_record" do
    get :show, id: @perseus_record
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @perseus_record
    assert_response :success
  end

  test "should update perseus_record" do
    patch :update, id: @perseus_record, perseus_record: {  }
    assert_redirected_to perseus_record_path(assigns(:perseus_record))
  end

  test "should destroy perseus_record" do
    assert_difference('PerseusRecord.count', -1) do
      delete :destroy, id: @perseus_record
    end

    assert_redirected_to perseus_records_path
  end
end
