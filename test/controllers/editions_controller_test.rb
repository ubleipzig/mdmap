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

class EditionsControllerTest < ActionController::TestCase
  setup do
    @edition = editions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:editions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create edition" do
    assert_difference('Edition.count') do
      post :create, edition: { best_match: @edition.best_match, oclc: @edition.oclc, xoclc: @edition.xoclcs }
    end

    assert_redirected_to edition_path(assigns(:edition))
  end

  test "should show edition" do
    get :show, id: @edition
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @edition
    assert_response :success
  end

  test "should update edition" do
    patch :update, id: @edition, edition: { best_match: @edition.best_match, oclc: @edition.oclcs, xoclc: @edition.xoclc }
    assert_redirected_to edition_path(assigns(:edition))
  end

  test "should destroy edition" do
    assert_difference('Edition.count', -1) do
      delete :destroy, id: @edition
    end

    assert_redirected_to editions_path
  end
end
