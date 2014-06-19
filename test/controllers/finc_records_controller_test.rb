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

require 'test_helper'

class FincRecordsControllerTest < ActionController::TestCase
  setup do
    @finc_record = finc_records(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:finc_records)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create finc_record" do
    assert_difference('FincRecord.count') do
      post :create, finc_record: {  }
    end

    assert_redirected_to finc_record_path(assigns(:finc_record))
  end

  test "should show finc_record" do
    get :show, id: @finc_record
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @finc_record
    assert_response :success
  end

  test "should update finc_record" do
    patch :update, id: @finc_record, finc_record: {  }
    assert_redirected_to finc_record_path(assigns(:finc_record))
  end

  test "should destroy finc_record" do
    assert_difference('FincRecord.count', -1) do
      delete :destroy, id: @finc_record
    end

    assert_redirected_to finc_records_path
  end
end
