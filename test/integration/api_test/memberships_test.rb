# Redmine - project management software
# Copyright (C) 2006-2014  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

require File.expand_path('../../../test_helper', __FILE__)

class Redmine::ApiTest::MembershipsTest < Redmine::ApiTest::Base
  fixtures :projects, :users, :roles, :members, :member_roles

  def setup
    Setting.rest_api_enabled = '1'
  end

  test "GET /projects/:project_id/memberships.xml should return memberships" do
    get '/projects/1/memberships.xml', {}, credentials('jsmith')

    assert_response :success
    assert_equal 'application/xml', @response.content_type
    assert_tag :tag => 'memberships',
      :attributes => {:type => 'array'},
      :child => {
        :tag => 'membership',
        :child => {
          :tag => 'id',
          :content => '2',
          :sibling => {
            :tag => 'user',
            :attributes => {:id => '3', :name => 'Dave Lopper'},
            :sibling => {
              :tag => 'roles',
              :child => {
                :tag => 'role',
                :attributes => {:id => '2', :name => 'Developer'}
              }
            }
          }
        }
      }
  end

  test "GET /projects/:project_id/memberships.json should return memberships" do
    get '/projects/1/memberships.json', {}, credentials('jsmith')

    assert_response :success
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_equal({
      "memberships" =>
        [{"id"=>1,
          "project" => {"name"=>"eCookbook", "id"=>1},
          "roles" => [{"name"=>"Manager", "id"=>1}],
          "user" => {"name"=>"John Smith", "id"=>2}},
         {"id"=>2,
          "project" => {"name"=>"eCookbook", "id"=>1},
          "roles" => [{"name"=>"Developer", "id"=>2}],
          "user" => {"name"=>"Dave Lopper", "id"=>3}}],
     "limit" => 25,
     "total_count" => 2,
     "offset" => 0},
     json)
  end

  test "GET /projects/:project_id/memberships.xml should succeed for closed project" do
    project = Project.find(1)
    project.close
    assert !project.reload.active?
    get '/projects/1/memberships.json', {}, credentials('jsmith')
    assert_response :success
  end

  test "POST /projects/:project_id/memberships.xml should create the membership" do
    assert_difference 'Member.count' do
      post '/projects/1/memberships.xml', {:membership => {:user_id => 7, :role_ids => [2,3]}}, credentials('jsmith')

      assert_response :created
    end
  end

  test "POST /projects/:project_id/memberships.xml should create the group membership" do
    group = Group.find(11)

    assert_difference 'Member.count', 1 + group.users.count do
      post '/projects/1/memberships.xml', {:membership => {:user_id => 11, :role_ids => [2,3]}}, credentials('jsmith')

      assert_response :created
    end
  end

  test "POST /projects/:project_id/memberships.xml with invalid parameters should return errors" do
    assert_no_difference 'Member.count' do
      post '/projects/1/memberships.xml', {:membership => {:role_ids => [2,3]}}, credentials('jsmith')

      assert_response :unprocessable_entity
      assert_equal 'application/xml', @response.content_type
      assert_tag 'errors', :child => {:tag => 'error', :content => "Principal can't be blank"}
    end
  end

  test "GET /memberships/:id.xml should return the membership" do
    get '/memberships/2.xml', {}, credentials('jsmith')

    assert_response :success
    assert_equal 'application/xml', @response.content_type
    assert_tag :tag => 'membership',
      :child => {
        :tag => 'id',
        :content => '2',
        :sibling => {
          :tag => 'user',
          :attributes => {:id => '3', :name => 'Dave Lopper'},
          :sibling => {
            :tag => 'roles',
            :child => {
              :tag => 'role',
              :attributes => {:id => '2', :name => 'Developer'}
            }
          }
        }
      }
  end

  test "GET /memberships/:id.json should return the membership" do
    get '/memberships/2.json', {}, credentials('jsmith')

    assert_response :success
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(response.body)
    assert_equal(
      {"membership" => {
        "id" => 2,
        "project" => {"name"=>"eCookbook", "id"=>1},
        "roles" => [{"name"=>"Developer", "id"=>2}],
        "user" => {"name"=>"Dave Lopper", "id"=>3}}
      },
      json)
  end

  test "PUT /memberships/:id.xml should update the membership" do
    assert_not_equal [1,2], Member.find(2).role_ids.sort
    assert_no_difference 'Member.count' do
      put '/memberships/2.xml', {:membership => {:user_id => 3, :role_ids => [1,2]}}, credentials('jsmith')

      assert_response :ok
      assert_equal '', @response.body
    end
    member = Member.find(2)
    assert_equal [1,2], member.role_ids.sort
  end

  test "PUT /memberships/:id.xml with invalid parameters should return errors" do
    put '/memberships/2.xml', {:membership => {:user_id => 3, :role_ids => [99]}}, credentials('jsmith')

    assert_response :unprocessable_entity
    assert_equal 'application/xml', @response.content_type
    assert_tag 'errors', :child => {:tag => 'error', :content => /member_roles is invalid/}
  end

  test "DELETE /memberships/:id.xml should destroy the membership" do
    assert_difference 'Member.count', -1 do
      delete '/memberships/2.xml', {}, credentials('jsmith')

      assert_response :ok
      assert_equal '', @response.body
    end
    assert_nil Member.find_by_id(2)
  end

  test "DELETE /memberships/:id.xml should respond with 422 on failure" do
    assert_no_difference 'Member.count' do
      # A membership with an inherited role can't be deleted
      Member.find(2).member_roles.first.update_attribute :inherited_from, 99
      delete '/memberships/2.xml', {}, credentials('jsmith')

      assert_response :unprocessable_entity
    end
  end
end
