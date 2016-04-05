class WorkPolicy < ApplicationPolicy
  permit %i(index new create  edit update)
end
