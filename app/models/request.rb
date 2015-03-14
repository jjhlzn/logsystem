#encoding: utf-8
class Request < ActiveRecord::Base
  self.table_name = "logsystem_requests_testordersystem"

  attr_accessor :isError
end
