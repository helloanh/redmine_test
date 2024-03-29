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

class Member < ActiveRecord::Base
  belongs_to :user
  belongs_to :principal, :foreign_key => 'user_id'
  has_many :member_roles, :dependent => :destroy
  has_many :roles, :through => :member_roles
  belongs_to :project

  validates_presence_of :principal, :project
  validates_uniqueness_of :user_id, :scope => :project_id
  validate :validate_role

  before_destroy :set_issue_category_nil

  def role
  end

  def role=
  end

  def name
    self.user.name
  end

  alias :base_role_ids= :role_ids=
  def role_ids=(arg)
    ids = (arg || []).collect(&:to_i) - [0]
    # Keep inherited roles
    ids += member_roles.select {|mr| !mr.inherited_from.nil?}.collect(&:role_id)

    new_role_ids = ids - role_ids
    # Add new roles
    new_role_ids.each {|id| member_roles << MemberRole.new(:role_id => id) }
    # Remove roles (Rails' #role_ids= will not trigger MemberRole#on_destroy)
    member_roles_to_destroy = member_roles.select {|mr| !ids.include?(mr.role_id)}
    if member_roles_to_destroy.any?
      member_roles_to_destroy.each(&:destroy)
    end
  end

  def <=>(member)
    a, b = roles.sort.first, member.roles.sort.first
    if a == b
      if principal
        principal <=> member.principal
      else
        1
      end
    elsif a
      a <=> b
    else
      1
    end
  end

  def deletable?
    member_roles.detect {|mr| mr.inherited_from}.nil?
  end

  def destroy
    if member_roles.reload.present?
      # destroying the last role will destroy another instance
      # of the same Member record, #super would then trigger callbacks twice
      member_roles.destroy_all
      @destroyed = true
      freeze
    else
      super
    end
  end

  def include?(user)
    if principal.is_a?(Group)
      !user.nil? && user.groups.include?(principal)
    else
      self.user == user
    end
  end

  def set_issue_category_nil
    if user_id && project_id
      # remove category based auto assignments for this member
      IssueCategory.where(["project_id = ? AND assigned_to_id = ?", project_id, user_id]).
        update_all("assigned_to_id = NULL")
    end
  end

  # Find or initialize a Member with an id, attributes, and for a Principal
  def self.edit_membership(id, new_attributes, principal=nil)
    @membership = id.present? ? Member.find(id) : Member.new(:principal => principal)
    @membership.attributes = new_attributes
    @membership
  end

  # Finds or initilizes a Member for the given project and principal
  def self.find_or_new(project, principal)
    project_id = project.is_a?(Project) ? project.id : project
    principal_id = principal.is_a?(Principal) ? principal.id : principal

    member = Member.find_by_project_id_and_user_id(project_id, principal_id)
    member ||= Member.new(:project_id => project_id, :user_id => principal_id)
    member
  end

  protected

  def validate_role
    errors.add_on_empty :role if member_roles.empty? && roles.empty?
  end
end
